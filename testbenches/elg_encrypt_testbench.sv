module elg_encrypt_testbench();

timeunit 10ns;

timeprecision 1ns;

logic Clk, Reset;
logic [255:0] Gx, Gy, Qx, Qy, message, Cx, Cy, Dx, Dy, priv;
logic Done;
// p mod 4 = 3 has to be true
elg_encrypt elg(.*);

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

initial begin: TEST_VECTORS

Reset = 1'b1;
priv = 5;
#2 Reset = 1'b0;
Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
// Assume bob's priv key is 3; so Q = 3*G;
// Let's also say alice's priv = 5,
Qx = 256'hF9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9;
Qy = 256'h388F7B0F632DE8140FE337E62A37F3566500A99934C2231B6CB9FD7584B8E672;
message = 256'd68;
end
endmodule
