module modular_inverse_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic Clk, Reset;
logic [256:0] in;
logic [255:0] out;

//modular_inverse #(17) modular_inverse_test(.Clk, .Reset, .in, .out);
modular_inverse #(1147) modular_inverse_test(.Clk, .Reset, .in, .out);

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

in = 256'd05;
Reset = 1'b0;
#200 in = 256'd03;
#2 Reset = 1'b1;
#2 Reset = 1'b0;
#200 in = 256'd02;
#2 Reset = 1'b1;
#2 Reset = 1'b0;
#60 in = 256'd016;
#2 Reset = 1'b1;
#2 Reset = 1'b0;

end

endmodule


