import elliptic_curve_structs::*;

module ecdsa_sign(
    input logic clk,
    input logic master_reset,
    input logic init,
    input logic [95:0] message,
    input logic [255:0] priv_key,
    output signature_t my_signature,
    output logic done
);

logic reset, done_create_signature;
logic [255:0] chacha_key;
logic [127:0] chacha_nonce;
signature_t temp_signature;

reg_256 #(.size($bits(my_signature))) signature_reg
(
    .clk,
    .Load(done),
    .Data(temp_signature),
    .Out(my_signature)
);

// holy crap this sha interface sucks
logic start_hash, done_hash, load_hash;


ecdsa_sign_datapath ecdsa_sign_datapath ( .clk, .reset(reset | master_reset),	.message, .priv_key,
    .my_signature(temp_signature),
    .start_hash, .done_hash, .load_hash,
    .done_create_signature,
    .chacha_key, .chacha_nonce
);

ecdsa_sign_control ecdsa_sign_control (.clk, .master_reset, .reset,
    .created_signature(temp_signature), .done_create_signature,
    .done,
    .chacha_key, .chacha_nonce,
    .init, .start_hash, .done_hash, .load_hash
);

endmodule : ecdsa_sign
