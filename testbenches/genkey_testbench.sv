//openssl ec -in ecprivkey.pem -pubout -out ecpubkey.pem

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic Clk, Reset;
logic [255:0] p, privKey, Gx, Gy, outx, outy;

assign Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
assign Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
assign p =  256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
assign privKey = 256'h4141414141414141414141414141414141414141414141414141414141414141;

point_gen point_gen0(.*);

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


end

endmodule
