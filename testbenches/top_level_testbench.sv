module top_level_testbench;

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic clk, Done;
logic [255:0] message;
logic [255:0] decrypted_x, decrypted_y;
logic [255:0] chacha_key;
logic [127:0] chacha_nonce;

//final_top #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) final0(.*);
final_top final0 (
	.*
);
// Toggle the clock
// #1 means wait for a delay of 1 timeunit

always begin : CLOCK_GENERATION
#1 clk = ~clk;
end

initial begin: CLOCK_INITIALIZATION
    clk = 0;
end

//Testing
initial begin: TEST_VECTORS
//Initialize signals
// Gx = 338530205676502674729549372677647997389429898939
// Gy = 842365456698940303598009444920994870805149798382
// N = 2082454586705741226620595
priv_key = $random();
message = 96'hece498ece498ece498ece498;
chacha_key = $random();
chacha_nonce = $random();
end

endmodule : top_level_testbench
