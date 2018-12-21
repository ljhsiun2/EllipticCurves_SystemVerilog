import elliptic_curve_structs::*;

module gen_point (
	input 	logic 			clk, Reset,
	input 	logic [255:0] 	privKey,
	input 	curve_point_t 	in_point,
	output 	curve_point_t 	out_point,
	output 	logic 			Done
);

enum logic [2:0] {Init, init_load,
	// find_start,
	Inc, Double, Add, dummy_op,
	Finish} State, Next_State;


	logic [255:0] priv_in, priv_out, x_in, x_out, y_in, y_out;
	logic [255:0] add_x_out, add_y_out, mult_x_out, mult_y_out, mult_x_in, mult_y_in, point_doub_x, point_doub_y;
	logic [7:0] count_in, count_out;
	logic priv_load, x_load, y_load, add_done, mult_done, count_load, add_reset, mult_reset, mult_x_load, mult_y_load;

	logic [255:0] gx, gy;
	assign gx = in_point.x;
	assign gy = in_point.y;

	//Private key register - will be shifted each round to check LSB
	reg_256 priv(.clk, .Load(priv_load), .Data(priv_in), .Out(priv_out));

	//Registers responsible for point doubling: 1G -> 2G -> 4G -> ...
	reg_256 mult_x(.clk, .Load(mult_x_load), .Data(mult_x_in), .Out(mult_x_out));
	reg_256 mult_y(.clk, .Load(mult_y_load), .Data(mult_y_in), .Out(mult_y_out));

	//Registers keeping track of public key calculation
	reg_256 x(.clk, .Load(x_load), .Data(x_in), .Out(x_out));
	reg_256 y(.clk, .Load(y_load), .Data(y_in), .Out(y_out));

	//Counter
	logic start_bit_load;
	logic [7:0] start_bit_in, start_bit_out;
	reg_256 #(8) count_reg(.clk, .Load(count_load), .Data(count_in), .Out(count_out));
	reg_256 #(8) start_bit_reg(.clk, .Load(start_bit_load), .Data(start_bit_in), .Out(start_bit_out));


	//Point addition and point doubling module instantiations
// TODO make less messy
curve_point_t add_R, add_P, add_Q;
assign add_P.x = mult_x_out;
assign add_Q.x = x_out;
assign add_P.y = mult_y_out;
assign add_Q.y = y_out;
point_add add0(.clk, .Reset(add_reset),
	.P(add_P), .Q(add_Q),
	.R(add_R),
	.Done(add_done)
);
assign add_x_out = add_R.x;
assign add_y_out = add_R.y;



curve_point_t doub_R, doub_P;
assign doub_P.x = mult_x_out;
assign doub_P.y = mult_y_out;
point_double doub0(.clk, .Reset(mult_reset),
	.P(doub_P),
	.R(doub_R),
	.Done(mult_done)
);
assign point_doub_x = doub_R.x;
assign point_doub_y = doub_R.y;

logic flag;
assign flag = priv_out[0];

    always_ff @ (posedge clk)
    begin
        if(Reset)
		begin
            State <= Init;
		end
        else begin
            State <= Next_State;
		end
    end

//Next state logic
always_comb begin
    Next_State = State;
    unique case(State)
		Init: Next_State = init_load;
		// find_start : begin
		// 	if(privKey[start_bit_out-1] == 1'b1)
		// 		Next_State = Add;
		// 	else Next_State = find_start;
		// end
		init_load : Next_State = Add;
		Inc: Next_State = Add;	//Skips doubling for the first round since the multiplication register are init to Gx, Gy
		Double:
		begin
			if(mult_done == 1'b1)	//Stays in this state until point double does its thing
				Next_State = Inc;
			else
				Next_State = Double;
		end
		dummy_op : if(add_done == 1'b1) Next_State = Double;
		Add:
		begin
			if(x_out == 0 && y_out == 0 && priv_out[0] == 1'b1)
				Next_State = Double;
			else if(add_done == 1'b0 && priv_out[0] == 1'b1)	//Stays here until point add finishes up
				Next_State = Add;
			else if(count_out == 8'd255)
			begin
				if(add_done == 1'b1)
					Next_State = Finish;
				else
					Next_State = Add;
			end
			else if(priv_out[0] == 1'b0)
				Next_State = dummy_op;
			else Next_State = Double;
		end
		Finish: Next_State = Finish;
		default: ;
	endcase

	//Default vals
	priv_in = privKey;
	x_in = x_out;
	y_in = y_out;
	count_in = count_out;
	mult_x_in = mult_x_out;
	mult_y_in = mult_y_out;

	priv_load = 1'b0;
	x_load = 1'b0;
	y_load = 1'b0;
	count_load = 1'b0;
	mult_x_load = 1'b0;
	mult_y_load = 1'b0;

	add_reset = 1'b0;
	mult_reset = 1'b0;
	Done = 1'b0;

	out_point.x = 256'd0;
	out_point.y = 256'd0;

	start_bit_load = 0;
	start_bit_in = 8'd256;

	unique case(State)
		Init:
		begin
			add_reset = 1'b1;
			mult_reset = 1'b1;

			//Initialize public key registers with (0,0), a point not on the curve
			//add_point will not work properly with this point, so this provides a check
			x_load = 1'b1;
			y_load = 1'b1;
			x_in = 0;
			y_in = 0;

			//Init counter to 0
			count_in = 8'b0;
			count_load = 1'b1;
			start_bit_load = 1'b1;
			start_bit_in = 8'd256;

			//multiplier registers hold value of generator to start
			mult_x_in = gx;
			mult_y_in = gy;
			mult_x_load = 1'b1;
			mult_y_load = 1'b1;

			//Load private key reg


		end

		init_load : begin
			priv_load = 1'b1;
			priv_in = privKey;
		end
		//
		// find_start : begin
		// 	priv_in = privKey;
		// 	priv_load = 1'b1;
		// 	start_bit_load = 1'b1;
		// 	start_bit_in = start_bit_out - 1;
		// end

		Inc:
		begin
			//increment counter
			count_load = 1'b1;
			count_in = count_out + 8'b01;
			add_reset = 1'b1;

			//Shift private key register right
			priv_in = priv_out >> 1;
			priv_load = 1'b1;
		end
		Double:
		begin
			//Update multiplication registers
			mult_x_load = 1'b1;
			mult_y_load = 1'b1;
			if(mult_done == 1'b1)
			begin
				mult_x_in = point_doub_x;
				mult_y_in = point_doub_y;
			end
			else
			begin
				mult_x_in = mult_x_out;
				mult_y_in = mult_y_out;
			end
		end

		dummy_op:
		begin
			if(add_done == 1'b1)
				mult_reset = 1'b1;
		end

		Add:
		begin
			mult_reset = 1'b1;
			if(priv_out[0] == 1'b1)
			begin
				x_load = 1'b1;
				y_load = 1'b1;
				if(x_out == 0 && y_out == 0)//Since (0,0) does not lie on the curve, we use it to indicate no adds have been completed yet
				begin
					x_in = mult_x_out;
					y_in = mult_y_out;
				end
				else	//Normal point addition
				begin
					if(add_done == 1'b1)
					begin
						x_in = add_x_out;
						y_in = add_y_out;
					end
				end
			end
			else if(priv_out[0] == 1'b0)
				add_reset = 1'b1;
			else	//Do nothing
			begin
				x_in = x_out;
				y_in = y_out;
			end
		end
		Finish:
		begin
			out_point.x = x_out;
			out_point.y = y_out;
			Done = 1'b1;
		end
		default:;
	endcase

end

endmodule
