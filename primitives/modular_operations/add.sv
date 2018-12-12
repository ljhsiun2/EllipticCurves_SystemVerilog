import elliptic_curve_structs::*;

module add
	(input logic [255:0] a, b,
	 input logic op,
	output logic [255:0] sum);

logic [256:0] temp1, temp2;
	// op = 1, a-b mod p
	// op = 0, a+b mod p

always_comb
begin
	if(op) begin
			temp1 = a-b;
			temp2 = (a-b) + params.n;
			if(temp1[256])
				sum = temp2[255:0];
			else
				sum = temp1[255:0];
	end
	else begin
		temp1 = a + b;
		temp2 = (a + b) - params.n;
		if(temp1 >= params.n)
			sum = temp2[255:0];
		else
			sum = temp1[255:0];
	end
end
endmodule
