import elliptic_curve_structs::*;

module reg_256 #(parameter size = 256)
(
	input  logic clk, Load,
  	input  logic [size-1:0]  Data,
  	output logic [size-1:0]  Out
);

always_ff @ (posedge clk)
begin
	if (Load)
		  Out <= Data;
	else
		  Out <= Out;
end

endmodule
