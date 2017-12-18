module reduction
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset, 
	input logic [512:0] a
	output logic[255:0] a_mod_p);

	//Internal logic signals for register loading
	logic X_load, b_load, count_load;
	logic [512:0] X_in, X_out;
	logic [512:0] b_in, b_out;
	logic [7:0] count_in, count_out;

	//X, b, and counting registers
	reg256 #(512) X(.Clk, .Reset, .Load(X_load), .Data(X_in), .Out(X_out));
	reg256 #(512) b(.Clk, .Reset, .Load(b_load), .Data(b_in), .Out(b_out));
	reg256 #(8) count(.Clk, .Reset, .Load(count_load), .Data(count_in), .Out(count_out));

	//States
	enum logic [2:0] {Init, Start, Align, Compare, Shift, Finish} State, Next_State;

	//State machine behavior
	always_ff @ (posedge Clk)
	begin
		if(Reset)
		    State <= Init;
		else
		    State <= Next_State;
	end

	
	//Next State Logic
	always_comb
	begin
		Next_State = State;
		unique case(State)
			Init:
			begin
				Next_State = Start;
			end
			Start:
			begin
				if(a < P)
					Next_State = Finish;
				else
					Next_State = Align;
			end
			Align:
			begin
				if(X_out[511] == b_out[511])
					Next_State = Compare;
				else
					Next_State = Align;
			end
			Compare:
			begin
				Next_State = Shift;
			end
			Shift:
				if(count_out = 8'd255)
					Next_State = Finish;
				else
					Next_State = Compare;
			Finish:
			default: Next_State = Init;
		endcase

	X_in = X_out;
	b_in = b_out;
	count_in = count_out;
	X_load = 1'b0;
	b_load = 1'b0;
	count_load = 1'b0;
	a_mod_p = X_out;
	
	//Preform algorithm steps
		unique case(State)
			Init:
			begin
				X_in = a;
				b_in = P;
				count_in = 1'b0;
				count_load = 1'b1;
				X_load = 1'b1;
				b_load = 1'b1;
			end	
			Start:
			begin
				if(a < P && a[255] == 1)
					X_in = a ^ {256'b0, P};
				else if(a < P)
					X_in = a;
				else
				begin
					X_in = a;	//Need to do alignment
					b_in = P << 256;
				X_load = 1'b1;
				b_load = 1'b1;
			end
			Align:
			begin
				
			end
			Compare:
			begin
			end
			Shift:
			begin
			end
			Finish:
			begin
			end
			default: ;
		endcase
	end

endmodule

