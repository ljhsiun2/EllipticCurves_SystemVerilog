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


module ecdsa_verify_datapath (.clk, .reset,
    .my_signature, .message, .pub_key,
    .done_verify, .invalid_error,
    .start_hash, .load_hash, .done_hash
);

logic start_hash, done_hash, load_hash;

module ecdsa_verify_control (.clk, .init_verify, .reset,
    .start_hash, .load_hash, .done_hash,

);


endmodule : ecdsa_verify
