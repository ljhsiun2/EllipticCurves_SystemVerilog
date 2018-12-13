import elliptic_curve_structs::*;

module multiplier (
	input 	logic 				clk, Reset,
	input 	logic [255:0] 		a, b,
	output 	logic 				Done,
	output 	logic [255:0] 		product
);

/* multiplication using bit shifting and adding */

logic [255:0] a_in, a_out, count_in, count_out;
logic [257:0] b_in, b_out,c_in, c_out;
logic a_load, b_load, c_load, count_load;

reg_256 a_reg(.clk, .Load(a_load), .Data(a_in), .Out(a_out));
reg_256 #(258) b_reg(.clk, .Load(b_load), .Data(b_in), .Out(b_out));
reg_256 #(258) c_reg(.clk, .Load(c_load), .Data(c_in), .Out(c_out));
reg_256 #(256) count(.clk, .Load(count_load), .Data(count_in), .Out(count_out));

enum logic [2:0] {
	Init, Start,
	setB, redB, setC,
	Finish
}	State, Next_State;

always_ff @ (posedge clk)
begin
    if(Reset)
	begin
        State <= Init;
	end
    else
        State <= Next_State;
end


always_comb begin
    Next_State = State;
    unique case(State)
		Init: Next_State = Start;
		Start: Next_State = setB;
		setB:
		begin
			if((b_out << 1) >= {2'b00,params.p})
				Next_State = redB;
			else
				Next_State = setC;
		end
		redB:
		begin
			if(b_out >= {2'b00,params.p})
				Next_State = redB;
			else
				Next_State = setC;
		end
		setC:
		begin
			if(count_out == 8'd254)
				Next_State = Finish;
			else
				Next_State = setB;
		end
		Finish:
			Next_State = Finish;
		default: ;
	endcase

	count_in = count_out;
	b_in = b_out;
	c_in = c_out;
	a_in = a_out;

	count_load = 1'b0;
	a_load = 1'b0;
	b_load = 1'b0;
	c_load = 1'b0;
	product = 256'b0;
	Done = 1'b0;

	unique case(State)
		Init:
		begin
			Done = 1'b0;
			count_in = 8'b0;
			a_in = a;
			b_in = {2'b0, b};
			c_in = 258'b0;

			count_load = 1'b1;
			a_load = 1'b1;
			b_load = 1'b1;
			c_load = 1'b1;
		end
		Start:
		begin
			if(a[0] == 1)
				c_in = b_out;
			else
				c_in = 258'b0;
			c_load = 1'b1;
		end
		setB:
		begin
			a_in = a_out >> 1;
			a_load = 1'b1;
			b_load = 1'b1;
			b_in = b_out << 1;
		end
		redB:
		begin
			b_load = 1'b1;
			if(b_out >= {2'b00, params.p})
				b_in = b_out - {2'b00,params.p};
			else
				b_in = b_out;
		end
		setC:
		begin
			c_load = 1'b1;
			if(a_out[0] == 1'b1)
			begin
				if((c_out + b_out) >= {2'b00, params.p})
					c_in = (c_out + b_out) - {2'b00, params.p};
				else
					c_in = c_out + b_out;
			end
			else
			begin
				if(c_out >= {2'b00, params.p})
					c_in = c_out - params.p;
				else
					c_in = c_out;
			end
			//increment counter
			count_in = count_out + 8'b01;
			count_load = 1'b1;
		end
		Finish:
		begin
			if(c_out < params.p)
			begin
				Done = 1'b1;
				product = c_out[255:0];
			end
			else
			begin
				c_in = c_out - {2'b00,params.p};
				c_load = 1'b1;
				Done = 1'b0;
			end
		end
		default: ;
	endcase
end

endmodule
