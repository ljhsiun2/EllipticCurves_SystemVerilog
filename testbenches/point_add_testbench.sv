//openssl ec -in ecprivkey.pem -pubout -out ecpubkey.pem
module point_add_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic Clk, Reset;
logic [255:0] Py, Qy, Px, Qx, Rx, Ry;
logic Done;

point_add uncreative_name(.*);
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
Px = 4'd7;
Py = 4'd11;
Qx = 4'd13;
Qy = 4'd10;
end

endmodule
