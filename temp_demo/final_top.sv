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
	input logic Reset
);

// Registers we need to hold the message (1 reg = 8 chars)
logic [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;

logic [2:0] b;
assign b = 3'd7;

/*logic [7:0] alice_outx, alice_outy, bob_outx, bob_outy, secret_x, secret_y;
logic [7:0] p, n, Gx, Gy, alice, bob;*/
logic [4:0] p, n, secret_x, secret_y, bob_outx, bob_outy, alice_outx, alice_outy;
logic [3:0] Gx;
logic Gy;
logic [1:0] alice;
logic [3:0] bob;
/*assign p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
assign n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
assign Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
assign Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
assign alice = 4'hffff;/* hard coded number here
assign bob = 4'hffaa; /* hard coded number here */
assign p = 5'd17;
assign n = 5'd19;
assign Gx = 3'd5;
assign Gy = 1'd1;
assign alice = 3'd5;
assign bob = 3'd7;

point_gen alice_point(.Clk, .Reset, .p, .priv_key(alice), .Gx, .Gy,
					  .outx(alice_outx), .outy(alice_outy));
point_gen bob_point(.Clk, .Reset, .p, .priv_key(bob), .Gx, .Gy,
					.outx(bob_outx), .outy(bob_outy));
point_gen secret(.Clk, .Reset, .p, .priv_key(alice), .Gx(bob_outx), .Gy(bob_outy),
				 .outx(secret_x), .outy(secret_y));

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
//assign EXPORT_DATA = 32'hFFFFFFFF;




endmodule
