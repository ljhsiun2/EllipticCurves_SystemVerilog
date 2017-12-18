module point_gen
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset,
	input logic [7:0] p, priv_key, // it should be mod p, not mod n my notes are wrong
	input logic [7:0] Gx, Gy,
	output logic [7:0] outx, outy);

logic [7:0] out_tempx, out_tempy, point_out_x_add, point_out_y_add, point_out_x_doub, point_out_y_doub, k, mod_out, k_temp;
logic [7:0] k_out, inv_mod_add_regVal, inv_mod_doub_regVal;
logic [7:0] inv_mod_add_valOut, inv_mod_doub_valOut;
logic [8:0] inv_mod_add_val, inv_mod_doub_val;
logic [15:0] s, s_out;
logic done_add, done_doub, done_mod;
logic k_load, mod_load, s_load, outx_load, outy_load;

enum logic [4:0] {Start, While_start, If_Check,
                  calc_s_doub, calc_s_add, inv_mod_add, inv_mod_doub, slope_mod,
                  calc_point, change_k, Finish, inv_add_load, inv_doub_load} State, Next_State;

reg_256 k_reg(.Clk, .Reset, .Load(k_load), .Data(k), .Out(k_out));
reg_256 inv_mod_add_reg(.Clk, .Reset, .Load(mod_load), .Data(inv_mod_add_val), .Out(inv_mod_add_regVal));
reg_256 inv_mod_doub_reg(.Clk, .Reset, .Load(mod_load), .Data(inv_mod_doub_val), .Out(inv_mod_doub_regVal));
reg_256 s_reg(.Clk, .Reset, .Load(s_load), .Data(s), .Out(s_out));
reg_256 outx_reg(.Clk, .Reset, .Load(outx_load), .Data(out_tempx), .Out(outx));
reg_256 outy_reg(.Clk, .Reset, .Load(outy_load), .Data(out_tempy), .Out(outy));

modular_inverse #(P) add_point(.Clk, .Reset, .in(inv_mod_add_regVal), .out(inv_mod_add_valOut), .Done(done_add));
modular_inverse #(P) doub_point(.Clk, .Reset, .in(inv_mod_doub_regVal), .out(inv_mod_doub_valOut), .Done(done_doub));
modulus #(P) mod(.Clk, .Reset, .k(s_out), .mod(p), .out(mod_out), .Done(done_mod));
point_op #(P) do_math_nerds_doub(.Clk, .Reset, .Ax(out_tempx), .Ay(out_tempy),
                       .Bx(out_tempx), .By(out_tempy), .s(mod_out),
                       .outx(point_out_x_doub), .outy(point_out_y_doub));
point_op #(P) do_math_nerds_add(.Clk, .Reset, .Ax(Gx), .Ay(Gy),
					   .Bx(out_tempx), .By(out_tempy), .s(mod_out),
					   .outx(point_out_x_add), .outy(point_out_y_add));
// k, inv_mod_add_val, inv_mod_doub_val, s
always_ff @ (posedge Clk)
begin
    if(Reset)
        State <= Start;
    else
        State <= Next_State;
end

always_comb begin
    Next_State = State;
    unique case(State)
        Start:
            Next_State = While_start;
        While_start:
        begin
            if(k>0)
                Next_State = If_Check;
            else
                Next_State = Finish;
        end
        If_Check:
        begin
            if(k[0])
                Next_State = inv_add_load;
            else
                Next_State = inv_doub_load;
        end
		inv_add_load:
			Next_State = inv_mod_add;
		inv_doub_load:
			Next_State = inv_mod_doub;
        inv_mod_add:
        begin
            if(done_add)
                Next_State = calc_s_add;
            else
                Next_State = inv_mod_add;
        end
        calc_s_add:
        begin
            Next_State = slope_mod;
        end
        inv_mod_doub:
        begin
            if(done_doub)
                Next_State = calc_s_doub;
            else
                Next_State = inv_mod_doub;
        end
        calc_s_doub:
            Next_State = slope_mod;
        slope_mod:
        begin
            if(done_mod)
                Next_State = calc_point;
            else
                Next_State = slope_mod;
        end
        calc_point:
            Next_State = change_k;
        change_k:
            Next_State = If_Check;
        Finish: ;
        default: ;
    endcase

    mod_load = 1'b0;
    k_load = 1'b0;
    outx_load = 1'b0;
    outy_load = 1'b0;
	s_load = 1'b0;

	out_tempx = outx;
	out_tempy = outy;
    k = k_out;
	inv_mod_add_val = inv_mod_add_regVal;
	inv_mod_doub_val = inv_mod_doub_regVal;
	s = s_out;

	case(State)
        Start:
        begin
            out_tempx = Gx;
            out_tempy = Gy;
            k = priv_key;
			k_load = 1'b1;
			outx_load = 1'b1;
			outy_load = 1'b1;
        end
        While_start: ;
        If_Check: ;
		inv_add_load:
		begin
			mod_load = 1'b1;
			inv_mod_add_val = Gx - out_tempx;
		end
		inv_doub_load:
		begin
			mod_load = 1'b1;
			inv_mod_doub_val = 2*out_tempy; // need to worry about neg? usually stuff first
		end
        inv_mod_add:
        begin
            if(done_mod)
                mod_load = 1'b1;
			else
				mod_load = 1'b0;
        end
        inv_mod_doub:
        begin
            if(done_mod)
                mod_load = 1'b1;
			else
				mod_load = 1'b0;
        end
        calc_s_add:
		begin
			s_load = 1'b1;
			s = (Gy-out_tempy)*inv_mod_add_valOut;
		end
        calc_s_doub:
		begin
			s_load = 1'b1;
            s = 3*(out_tempx*out_tempx)*inv_mod_doub_valOut;
		end
        slope_mod: ;
        calc_point: ;
        change_k:
        begin
            k_load = 1'b1;
            if(k_out[0])
			begin
				out_tempx = point_out_x_add;
				out_tempy = point_out_y_add;
                k = k_out - 1;
				outx_load = 1'b1;
				outy_load = 1'b1;
			end
            else
			begin
				out_tempx = point_out_x_doub;
				out_tempy = point_out_y_doub;
                k = k_out >> 1;
				outx_load = 1'b1;
				outy_load = 1'b1;
			end
        end
        Finish:
        begin
            outx_load = 1'b1;
            outy_load = 1'b1;
        end
        default: ;
    endcase
end

endmodule
