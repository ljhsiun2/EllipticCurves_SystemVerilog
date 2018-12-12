module ecdsa_verify #(parameter MSG_SIZE=96)(
    input logic             clk,
    input logic             reset,
    input signature_t       my_signature,
    input [95:0]            message,
    input curve_point_t     pub_key,
    output logic            done_verify,
    output logic            invalid_error
);
/* CHECKS */
/* -- pub_key is on curve (done in ecdsa sign) */
/* -- TODO check n * Q == O and Q != O; not done currently bc
      massive compilation times */

logic [255:0] r, s;
logic [255:0] msg_hash;
logic done_hash;
assign r = my_signature.r;
assign s = my_signature.s;

/* 1) verify r, s within bounds (done in control) */

/* 2) create hash and use #n-bits of hash */
// TODO parameterize msg

logic [255:0] hash_init;
sha256_H_0 sha2_init_vals_2 (.H_0(hash_init));
sha256_block sha256_verify(
    .clk, .rst(reset), .input_valid(reset),
    .M_in({message, 416'd0}), .H_in(hash_init),
    .H_out(msg_hash),
    .output_valid(done_hash)
);

/* 3) calculate inv_s */
logic [255:0] inv_s;
logic done_mod_inv;
modular_inverse mod_inv_verify (
    .clk, .Reset(reset),
    .in(s), .out(inv_s), .Done(done_mod_inv)
);

/* 4) calculate u = zw mod n and v = rw mod n */
logic [255:0] u, v;
logic done_u, done_v;
multiplier create_u (
    .clk, .Reset(reset | ~done_mod_inv),
    .a(inv_s), .b(msg_hash),
    .product(u),
    .Done(done_u)
);

multiplier create_v (
    .clk, .Reset(reset | ~done_mod_inv),
    .a(inv_s), .b(r),
    .product(v),
    .Done(done_v)
);

/* 5) calculate (x, y) = u*G + v*Q. If (x, y) = O, invalid */
// TODO implement using "shamir's trick"
curve_point_t uG, vQ;
logic done_gen_u, done_gen_v;
gen_point gen_u_point (
    .clk, .Reset(reset | ~(done_v && done_u)),
    .privKey(u),
    .in_point(params.base_point), .out_point(uG),
    .Done(done_gen_u)
);

gen_point gen_v_point (
    .clk, .Reset(reset | ~(done_v && done_u)),
    .privKey(v),
    .in_point(pub_key), .out_point(vQ),
    .Done(done_gen_v)
);

curve_point_t verified_point;
point_add validate_point (
    .clk, .Reset(reset | ~(done_gen_v & done_gen_u)),
    .P(uG), .Q(vQ),
    .R(verified_point),
    .Done(done_verify)
);


always_comb begin
	 invalid_error = 1'b0;
    if(verified_point.x != r)
        invalid_error = 1'b1;
end
endmodule : ecdsa_verify
