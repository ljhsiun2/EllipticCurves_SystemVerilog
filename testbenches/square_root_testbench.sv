module square_root_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic Clk, Reset;
logic [255:0] a, a_squared, out;
logic Done;

logic [255:0] op0_in, op1_in, a0_in, a1_in, prod0, prod1;
logic [7:0] counter;

square_root uncreative_name(.*);
// Toggle the clock


always_ff @ (posedge Clk) begin
	op0_in <= uncreative_name.op0_in;
	op1_in <= uncreative_name.op1_in;
	a0_in <= uncreative_name.a0_in;
	a1_in <= uncreative_name.a1_in;
	prod0 <= uncreative_name.prod0;
	prod1 <= uncreative_name.prod1;
	counter <= uncreative_name.counter;
end
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end
//out == 448FBB09CFD25729AB89200A3A3E12F5A8BA89C50C19C68DB9FCE9B2E9C48057
//Testing
initial begin: TEST_VECTORS
//Initialize signals
Reset = 1'b1;
#2 Reset = 1'b0;
a = 10;
a_squared = 100;
end
endmodule
