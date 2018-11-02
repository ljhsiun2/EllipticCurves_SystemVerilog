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
	input logic Clk,

	// Avalon Reset Input
	input logic Reset,

	// Avalon-MM Slave Signals
	input logic [255:0] P, Gx, Gy, message, alice, bob,
	output logic Done,
	output logic [255:0] decrypted_x, decrypted_y;
);

// Registers we need to hold the message (1 reg = 8 chars)
logic [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;

logic [3:0] b;
assign b = 4'h7;

logic [255:0] bob_outx, bob_outy;
//logic [255:0] P, n, Gx, Gy, alice, bob;
/*assign P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
assign n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
assign Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
assign Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;*/
//assign alice = /* hard coded number here TODO */
//assign bob = /* hard coded number here TODO */
logic done_alice, done_bob, done_encrypt, done_decrypt;
logic [255:0] Cx, Cy, Dx, Dy;

point_gen #(P) bob_point(.Clk, .Reset, .p, .priv_key(bob), .Gx, .Gy,
					.outx(bob_outx), .outy(bob_outy), .Done(done_bob));

elg_encrypt #(P) encrypt_message(.Clk, .Reset(Reset | ~done_bob), .priv(alice), .Gx, .Gy, .Qx(bob_outx), .Qy(bob_outy),
			.message, .Done(done_encrypt), .Cx, .Cy, .Dx, .Dy);

elg_decrypt #(P) decrypt_message(.Clk, .Reset(Reset | ~done_encrypt), .Cx, .Cy, .Dx, .Dy,
			.priv(bob), .Done(done_decrypt), .outx(decrypted_x), .outy(decrypted_y));

assign Done = done_decrypt;
//Internal logic and data
/* int main(){
	int alice = rand() % n;
	int bob = rand() % n;
	alice_x, alice_y = point_gen(p, alice, Gx, Gx);
	bob_x, bob_y = point_gen(p, bob, Gx, Gy);
	sym_key_x, sym_key_y = point_gen(p, alice, bob_x, bob_y);

	printf("here's our key please god i hope this is right");
}
*/

assign EXPORT_DATA = {D0[31:16], D3[15:0]};
//assign EXPORT_DATA = 32'hFFFFFFFF;




endmodule
