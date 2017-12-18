module add_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic Clk, Reset;
logic [255:0] a, b, sum;
logic op;

add #(17) add0(.*);
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

//Testing
initial begin: TEST_VECTORS
//Initialize signals
Reset = 1'b1;
op = 1'b1;
a = 6;
b = -16;
#2 Reset = 1'b0;

//EXPECTED 76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669b2ee6586
end
endmodule
