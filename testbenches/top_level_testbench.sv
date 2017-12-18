module top_level_testbench();


timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic Clk, Reset, done_bob, done_encrypt, done_decrypt, Done;
logic [255:0] bob, Gx, Gy, bob_outx, bob_outy, alice, message;
logic [255:0] Cx, Cy, Dx, Dy, decrypted_x, decrypted_y;

final_top #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) final0(.*);
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always_ff @ (posedge Clk) begin
    Cx = final0.Cx;
    Cy = final0.Cy;
    Dx = final0.Dx;
    Dy = final0.Dy;
    bob_outx = final0.bob_outx;
    bob_outy = final0.bob_outy;
    done_bob = final0.done_bob;
    done_encrypt = final0.done_encrypt;
    done_decrypt = final0.done_decrypt;
end
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

//Testing
initial begin: TEST_VECTORS
//Initialize signals
// P = 1461501637330902918203684832716283019651637554291
// Gx = 338530205676502674729549372677647997389429898939
// Gy = 842365456698940303598009444920994870805149798382
// N = 2082454586705741226620595
Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
alice = 256'd115792089237316195423570985008687907852837564279074904382605163141518161494324;
bob = 256'd11223344556677889911223344556677889911223344;
message = 256'hece385ece385ece385ece385ece385ece385ece385ece385ece385ece385ece3;
Reset = 1'b1;
#2 Reset = 1'b0;
end

endmodule
