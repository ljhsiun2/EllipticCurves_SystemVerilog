import elliptic_curve_structs::*;

/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module final_top (
	// Avalon Clock Input
	input logic clk,

	// Avalon-MM Slave Signals
	input logic [11:0] message,
	input logic [255:0] priv_key,
	output logic Done,
	output logic [255:0] decrypted_x, decrypted_y
);

// Registers we need to hold the message (1 reg = 8 chars)

//logic [255:0] P, n, Gx, Gy, alice, bob;
/*assign P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
assign n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
assign Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
assign Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;*/


signature ciphertext;

/* 7) return (r, s) */
logic done_sign, done_verify;
ecdsa_sign ecdsa_sign (.clk, .message, .priv_key,
					   .my_signature(ciphertext), .done(done_sign));

ecdsa_verify ecdsa_verify(.clk, .ciphertext, .pub_key, .done(done_verify));
//


//assign EXPORT_DATA = 32'hFFFFFFFF;




endmodule : final_top
