module modular_inverse
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset,
	input logic [511:0] in,
	output logic [255:0] out,
	output logic Done);

	/*Since Z = 2 for the case of binary polynomials, all divisions can be preformed via a right shift, and all
	**divisibility checks can be preformed by checking the least signifigant bit.
	**Since the only elliptic curve operations we have to worry about are point doubling and point adding, we're
	**not concerned with numbers greater than 2P, which will be limited to 257 bits
	**
	**UPDATE 11/22: Ditched that assumption, now allows inputs up to 512 bits instead of 257
	*/

	//Control Signals
	logic u_load, v_load, g1_load, g2_load, status;
	logic [511:0] u_in, u_out, g1_in, g1_out, g2_in, g2_out;
	logic [511:0] v_in, v_out;

	//State machine states
	enum logic [2:0] {Init, Start, Check_u, Check_v, Check_deg, Finish} State, Next_State;


	//Register Instatntations
	reg_256 #(512) u(.Clk, .Reset, .Load(u_load), .Data(u_in), .Out(u_out));
	reg_256 #(512) v(.Clk, .Reset, .Load(v_load), .Data(v_in), .Out(v_out));
	reg_256 #(512) g1(.Clk, .Reset, .Load(g1_load), .Data(g1_in), .Out(g1_out));
	reg_256 #(512) g2(.Clk, .Reset, .Load(g2_load), .Data(g2_in), .Out(g2_out));

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
				if(u_out == 512'b01 || v_out == 512'b01)
					Next_State = Finish;
				else if(u_out[0] == 0)
					Next_State = Check_u;
				else if(v_out[0] == 0)
					Next_State = Check_v;
				else
					Next_State = Check_deg;
			end
			Check_u:
			begin
				 if(u_out[0] == 0)
					Next_State = Check_u;
				else if(v_out[0] == 0)
					Next_State = Check_v;
				else
					Next_State = Check_deg;
			end
			Check_v:
			begin
				 if(v_out[0] == 0)
					Next_State = Check_v;
				else
					Next_State = Check_deg;
			end
			Check_deg:
			begin
				Next_State = Start;
			end
			Finish:
			begin
				Next_State = Finish;
			end
			default: Next_State = Init;
		endcase

		//Default values
		u_in = u_out;
		v_in = v_out;
		g1_in = g1_out;
		g2_in = g2_out;
		u_load = 1'b0;
		v_load = 1'b0;
		g1_load = 1'b0;
		g2_load = 1'b0;
		out = 256'b0;
		Done = 1'b0;

	//Preform algorithm steps
		unique case(State)
			Init:
			begin
				u_in = in;
				v_in = P;
				Done = 1'b0;
				g1_in = 512'b01;
				g2_in = 512'b0;
				u_load = 1'b1;
				v_load = 1'b1;
				g1_load = 1'b1;
				g2_load = 1'b1;
			end
			Start:
			begin
			end
			Check_u:
			begin
				u_in = u_out >> 1;	//Divide by z (z=2)
				if(g1_out[0] == 0)
					g1_in = g1_out >> 1;
				else
					g1_in = (g1_out + P) >> 1;
				if(u_out != 512'b01 && u_out[0] == 0)
				begin
					u_load = 1'b1;
					g1_load = 1'b1;
				end
			end
			Check_v:
			begin
				v_in = v_out >> 1;
				if(g2_out[0] == 0)
					g2_in = g2_out >> 1;
				else
					g2_in = (g2_out + P) >> 1;
				if(v_out != 512'b01 && v_out[0] == 0)
				begin
					v_load = 1'b1;
					g2_load = 1'b1;
				end
			end
			Check_deg:
			begin
				//Checks if deg(u) > deg(v)
				if(u_out > v_out && u_out >= ((v_out << 1) - v_out))
				begin
					u_in = u_out + v_out;
					g1_in = g1_out + g2_out;
					u_load = 1'b1;
					g1_load = 1'b1;
				end
				else
				begin
					v_in = v_out + u_out;
					g2_in = g2_out + g1_out;
					v_load = 1'b1;
					g2_load = 1'b1;
				end
			end
			Finish:
			begin
				Done = 1'b1;
				if(u_out == 512'b01)
					out = g1_out[255:0];
				else
					out = g2_out[255:0];
			end
			default: ;
		endcase
	end


endmodule
