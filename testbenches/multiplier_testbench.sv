module multiplier_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic Clk, Reset, Done;
logic [255:0] a, b, product;
logic [256:0] b_out;
logic [7:0] count_out;
logic [255:0] a_out, c_out;

multiplier #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) mult0(.*);

always_ff @(posedge Clk)
begin
	count_out = mult0.count_out;
	a_out = mult0.a_out;
	b_out = mult0.b_out;
	c_out = mult0.c_out;
end
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
#2 Reset = 1'b0;
a = 256'h26e4d30eccc3215dd8f3157d27e23acbdcfe68000000000000000;
b = 256'h184F03E93FF9F4DAA797ED6E38ED64BF6A1F010000000000000000;
//EXPECTED: 0x1200
//#200000 Reset = 1'b1;
//#2 Reset = 1'b0;
//a = 256'h09;
//b = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFE2F;
end

endmodule
