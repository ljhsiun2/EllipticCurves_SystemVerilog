module gen_point_control (
    input logic clk,
    input logic reset,

);


always_ff @ (posedge clk)
begin
    if(reset)
	begin
        State <= Init;
	end
    else
        State <= Next_State;
end

//Next state logic
always_comb begin
    Next_State = State;
    unique case(State)
		Init: Next_State = Add;
		Inc: Next_State = Add;	//Skips doubling for the first round since the multiplication register are init to Gx, Gy
		Double:
		begin
			if(mult_done == 1'b1)	//Stays in this state until point double does its thing
				Next_State = Inc;
			else
				Next_State = Double;
		end
		Add:
		begin
			if(x_out == 0 && y_out == 0 && priv_out[0] == 1'b1)
				Next_State = Double;
			else if(add_done == 1'b0 && priv_out[0] == 1'b1)	//Stays here until point add finishes up
				Next_State = Add;
			else if(count_out == 255)
			begin
				if(add_done == 1'b1)
					Next_State = Finish;
				else
					Next_State = Add;
			end
			else
				Next_State = Double;
		end
		Finish: Next_State = Finish;
		default: ;
	endcase

	//Default vals
	priv_in = priv_out;
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

	outX = 256'b0;
	outY = 256'b0;

	unique case(State)
		Init:
		begin
			add_reset = 1'b1;
			mult_reset = 1'b1;

			//Initialize public key registers with (0,0), a point not on the curve
			//add_point will not work properly with this point, so this provides a check
			x_load = 1'b1;
			y_load = 1'b1;
			x_in = 256'b0;
			y_in = 256'b0;

			//Init counter to 0
			count_in = 8'b0;
			count_load = 1'b1;

			//multiplier registers hold value of generator to start
			mult_x_in = gx;
			mult_y_in = gy;
			mult_x_load = 1'b1;
			mult_y_load = 1'b1;

			//Load private key reg
			priv_load = 1'b1;
			priv_in = privKey;

		end
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
			else	//Do nothing
			begin
				x_in = x_out;
				y_in = y_out;
			end
		end
		Finish:
		begin
			outX = x_out;
			outY = y_out;
			Done = 1'b1;
		end
		default:;
	endcase

end
