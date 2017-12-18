module elg_decrypt_testbench();

timeunit 10ns;

timeprecision 1ns;

logic Clk, Reset;
logic [255:0] Cx, Cy, Dx, Dy, priv, outx, outy;
logic Done;
// p mod 4 = 3 has to be true
elg_decrypt elg(.*);

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

initial begin: TEST_VECTORS

Reset = 1'b1;
priv = 3;
#2 Reset = 1'b0;
Cx = 256'h2F8BDE4D1A07209355B4A7250A5C5128E88B84BDDC619AB7CBA8D569B240EFE4;
Cy = 256'hD8AC222636E5E3D6D4DBA9DDA6C9C426F788271BAB0D6840DCA87D3AA6AC62D6;
// Assume bob's priv key is 3; so Q = 3*G;
// Let's also say alice's priv = 5,
Dx = 256'hb747db0388e605b641f13f5134372af542c943240cb484d5bc99296667ebdbec;
Dy = 256'hb832febaa2c01682a576deb2de4125c15efd2b9d1ae67e744fb3dbf979c849c4;
end
endmodule
