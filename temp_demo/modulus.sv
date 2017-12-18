module modulus
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F,
	  parameter size = 12'h100)
	(input logic Clk, Reset,
	input logic [15:0] k,
    input logic [7:0] mod,
	output logic [7:0] out,
	output logic Done);
// Note: this is pretty inefficient
    enum logic [2:0] {Start, If_Check, While_neg, While_pos, Finish} State, Next_State;

    always_ff @ (posedge Clk)
    begin
        if(Reset)
            State <= Start;
        else
            State <= Next_State;
    end

logic [15:0] out_temp, lol;
logic MSB_k, Load;
assign MSB_k = k[15]; // TODO: Either 1) Have numbers be a fixed legnth 2) Parameterize it
//assign out_temp = k;

	reg_256 #(16) X(.Clk, .Reset, .Load(Load), .Data(lol), .Out(out_temp));


    always_comb begin
        Next_State = State;
        unique case(State)
            Start:
                Next_State = Start;
            If_Check:
            begin
                if(MSB_k)
                    Next_State = While_neg;
                else
                    Next_State = While_pos;
            end
            While_neg:
            begin
                if(out_temp < 0)
                    Next_State = While_neg;
                else
                    Next_State = Finish;
            end
            While_pos:
            begin
                if(out_temp > mod)
                    Next_State = While_pos;
                else
                    Next_State = Finish;
            end
            Finish: ;
            default: ;
        endcase

        lol = out_temp;
		Load = 1'b0;
		out = out_temp[7:0];
		Done = 1'b0;

        case(State)
            Start:
			begin
				Load = 1'b1;
				lol = k;
				Done = 1'b0;
			end
            If_Check: ;
            While_neg:
			begin
                lol = out_temp + mod;
				Load = 1'b1;
			end
            While_pos:
			begin
				Load = 1'b1;
                lol = out_temp - mod;
			end
            Finish:
			begin
				Done = 1'b1;
				out = out_temp[7:0];
			end
			default: ;
        endcase
    end

endmodule
