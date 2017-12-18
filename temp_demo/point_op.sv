module point_op
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset,
	input logic [7:0] Ax, Ay, Bx, By,
	input logic [7:0] s,
	output logic [15:0] outx, outy);

logic [15:0] tempx, tempy;
logic [15:0] temp2;

always_comb begin
	tempx = s*s - Ax - Bx;
	temp2 = Ax - tempx;
	tempy = s*temp2 - Ay;
end

assign outx = tempx;
assign outy = tempy;

endmodule
