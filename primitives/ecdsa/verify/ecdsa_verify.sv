import elliptic_curve_structs::*;

module ecdsa_verify #(parameter MSG_SIZE=96)(
    input logic             clk,
    input logic             reset,
    input logic             init_verify,
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
logic start_hash, done_hash, load_hash;


ecdsa_verify_datapath ecdsa_verify_datapath (
	 .clk, .reset,
    .my_signature, .message, .pub_key,
    .done_verify, .invalid_error,
    .start_hash, .load_hash, .done_hash
);


ecdsa_verify_control ecdsa_verify_control (.clk, .reset,
    .done_verify,
    .done_hash, .load_hash, .start_hash,
    .init_verify
);


endmodule : ecdsa_verify
