//openssl ec -in ecprivkey.pem -pubout -out ecpubkey.pem
module point_mult_testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

logic Clk, Reset;
logic [255:0] Py, Qy, Px, Qx, Rx, Ry;
logic Done;

logic  mult0_done, inv_done, mult1_done, mult2_done, mult3_done;
logic[255:0] prod1, prod2, prod3, prod0;
logic[255:0] inv1;
logic[255:0] sum0, sum1, sum2, sum3, sum4, sum5;

point_double p(.*);

always_ff @ (posedge Clk)
begin
	mult0_done <= p.mult0_done;
	inv_done <= p.inv_done;
	mult1_done <= p.mult1_done;
	mult2_done <= p.mult2_done;
	mult3_done <= p.mult3_done;
	prod0 <= p.prod0;
	prod1 <= p.prod1;
	prod2 <= p.prod2;
	prod3 <= p.prod3;
	inv1 <= p.inv1;
	sum0 <= p.sum0;
	sum1 <= p.sum1;
	sum2 <= p.sum2;
	sum3 <= p.sum3;
	sum4 <= p.sum4;
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
Px = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
Qx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
Py = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
Qy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
end

endmodule
