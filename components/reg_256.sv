module reg_256 #(parameter size = 256)
				(input  logic Clk, Reset, Load,
              input  logic [size-1:0]  Data,
              output logic [size-1:0]  Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset)
			  Out <= 0;
		 else if (Load)
			  Out <= Data;
		else
			  Out <= Out;
	end

endmodule
