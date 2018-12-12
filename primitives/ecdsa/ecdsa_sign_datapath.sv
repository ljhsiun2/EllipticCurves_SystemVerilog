import elliptic_curve_structs::*;

module ecdsa_sign_datapath #(parameter MSG_SIZE=96) (
    /* wires for signing */
    input   logic               clk,
    input   logic               reset,
    input   logic [95:0]        message,
    input   logic [255:0]       priv_key,

    /* wires to control */
    output  signature_t         my_signature,
    output  curve_point_t       pub_point,
    output  logic               done_create_signature,
    input   logic [255:0]       chacha_key,
    input   logic [127:0]       chacha_nonce
);

logic done_mod, done_hash, done_chacha, done_gen_point;
logic [255:0] hash, msg_hash_out;
logic [511:0] stream_out;
logic [512:0] mod_in;
logic [255:0] created_signature;
logic [255:0] inv_k;

initial begin
    done_mod = 1'b0;
    done_hash = 1'b0;
    done_chacha = 1'b0;

    hash = 0;
end

// load hash reg once sha256 is done
reg_256 hash_reg(.clk, .Load(done_hash), .Data(hash), .Out(msg_hash_out));

/* ---- SETUP ----- */
// some key d has already been created; see top_level_testbench
// TODO check if random is ok for testbench
logic [255:0] d;
assign d = priv_key;



/* 1) Calculate e = sha256(m) */
/* 2) set z = N-left most bits of e where N = # group order bits (just using hash itself here) */

// TODO make msg size parameterizable
logic [255:0] hash_init;
sha256_H_0 sha2_init_vals_1 (.H_0(hash_init));
sha256_block sha256_sign(
    .clk, .rst(reset), .input_valid(reset),
    .M_in({message, 416'd0}), .H_in(hash_init),
    .H_out(hash),
    .output_valid(done_hash)
);



/* 3) select random integer k from [1, n-1] (use chacha20) */
// TODO use real sources of entropy
chacha chacha20(.clk, .Reset(reset),
				.key(chacha_key), .nonce(chacha_nonce), .stream(stream_out), .Done(done_chacha));
reg_256 chacha_reg(.clk, .Load(done_chacha), .Data(stream_out[255:0]), .Out(blinding_k));
logic [255:0] blinding_k;



/* 4) calculate curve point (x, y) = k*G */
gen_point gen_point (
    .clk, .Reset(reset),
    .privKey(blinding_k),
    .in_point(params.base_point), .out_point(pub_point),
    .Done(done_gen_point)
);



/* 5) calculate r = x mod n. If r == 0, go to step 3 */
/* 6) calculate s = inv_k*(z + r*d_a) mod n. if s = 0, go back to 3. */

// TODO multiplication is very costly; reduce maybe?
assign mod_in = msg_hash_out + pub_point.x*d;
modular_inverse mod_inv_sign(
    .clk, .Reset(reset | ~done_gen_point), .in(blinding_k),
    .out(inv_k), .Done(done_mod)
);
// start multiplying when mod is finished
multiplier create_sig (
    .clk, .Reset(reset | (~done_mod)),
    .a(mod_in), .b(inv_k),
    .product(created_signature),
    .Done(done_create_signature)
);

assign my_signature = '{pub_point.x, created_signature};

endmodule : ecdsa_sign_datapath
