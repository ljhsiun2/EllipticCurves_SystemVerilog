import elliptic_curve_structs::*;

module ecdsa_sign(
    input logic clk,
    input logic [95:0] message,
    input logic [255:0] priv_key,
    output signature_t my_signature,
    output curve_point_t pub_point,
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


ecdsa_sign_datapath ecdsa_sign_datapath ( .clk, .reset,	.message, .priv_key,
    .my_signature(temp_signature), .pub_point,
    .done_create_signature,
    .chacha_key, .chacha_nonce
);

ecdsa_sign_control ecdsa_sign_control (.clk, .reset,
    .pub_point, .created_signature(temp_signature), .done_create_signature,
    .done,
    .chacha_key, .chacha_nonce
);

endmodule : ecdsa_sign
