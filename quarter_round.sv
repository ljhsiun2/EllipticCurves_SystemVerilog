module quarter_round
		(input logic [31:0] a, b, c, d,
		output logic [31:0] w, x, y, z);

/**Each quarter round completes the following operations:
**a += b;  d ^= a;  d <<<= 16;
**c += d;  b ^= c;  b <<<= 12;
**a += b;  d ^= a;  d <<<=  8;
**c += d;  b ^= c;  b <<<=  7;
**
**Where <<< n is a left rotation by n
*/

logic [31:0] a2, a3;
logic [31:0] b2, b3, b4, b5;
logic [31:0] c2, c3;
logic [31:0] d2, d3, d4, d5;

always_comb
begin
	a2 = a + b;
	d2 = d ^ a2;
	d3 = {d2[15:0], d2[31:16]};
	
	c2 = c + d3;
	b2 = b ^ c2;
	b3 = {b2[19:0], b2[31:20]};

	a3 = a2 + b3;
	d4 = a3 ^ d3;
	d5 = {d4[23:0], d4[31:24]};

	c3 = c2 + d5;
	b4 = c3 ^ b3;
	b5 = {b4[24:0], b4[31:25]};

	w = a3;
	x = b5;
	y = c3;
	z = d5;
end

endmodule
	
