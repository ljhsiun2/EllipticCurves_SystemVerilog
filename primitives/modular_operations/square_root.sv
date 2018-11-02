module square_root
    #(parameter P = 256'd115792089237316195423570985008687907853269984665640564039457584007908834671663)
    (input logic Clk, input logic Reset,
        input logic [255:0] a,
        input logic [255:0] a_squared,
        output logic [255:0] out,
        output logic Done);

// exponent = (p+1)/4. P mod 4 === 3 in order to use this shortcut.
// If this is the case, for r^2 = x mod P, r = r^((P+1)/4) mod P
// See Implementation of ElGamal Elliptic Curve Cryptography Over Prime Field Using C
logic [253:0] exponent;
logic [255:0] op0_in, op1_in, op0_out, op1_out, exponent_in, exponent_out, prod0, prod1, a0_in, a1_in, a0_out, a1_out;
logic mult_reset, mult0_done, mult1_done, exp_load, a_load, count_set, op_load;
logic [7:0] counter;

enum logic [3:0] {Start, Find_first_one, Check, Mult, Square, Shift, Finish, Op_mult, Op_square} State, Next_State;
// 28948022309329048855892746252171976963317496166410141009864396001977208667916
assign exponent = 254'd28948022309329048855892746252171976963317496166410141009864396001977208667916;
//assign exponent = 254'd66;

// Similar to gen_point, we use the double-add algorithm to find a^exponent
//reg_256 exponent_reg(.Clk, .Reset, .Load(exp_load), .Data(exponent_in), .Out(exponent_out));
reg_256 a0_reg(.Clk, .Reset, .Load(a_load), .Data(a0_in), .Out(a0_out));
reg_256 a1_reg(.Clk, .Reset, .Load(a_load), .Data(a1_in), .Out(a1_out));
reg_256 op0_reg(.Clk, .Reset, .Load(op_load), .Data(op0_in), .Out(op0_out));
reg_256 op1_reg(.Clk, .Reset, .Load(op_load), .Data(op1_in), .Out(op1_out));

// operand is a variable thing-- it is a if in the add state, and a_out in the double state.
// https://en.wikipedia.org/wiki/Exponentiation_by_squaring#Montgomery's_ladder_technique
multiplier #(P) mult0(.Clk, .Reset(Reset | ~mult_reset), .a(a0_out), .b(op0_in), .Done(mult0_done), .product(prod0));
multiplier #(P) mult1(.Clk, .Reset(Reset | ~mult_reset), .a(a1_out), .b(op1_in), .Done(mult1_done), .product(prod1));

always_ff @ (posedge Clk)
begin
    if(Reset) begin
        State <= Start;
        counter <= 254;
    end
    else
        State <= Next_State;
    if(count_set)
        counter <= counter - 1;
end

always_comb begin
    Next_State = State;
    unique case(State)
        Start: Next_State = Find_first_one;
        Find_first_one:
        begin
            if(exponent[counter])
                Next_State = Check;
            else
                Next_State = Find_first_one;
        end
        Check:
        begin
            if(exponent[counter])
                Next_State = Op_mult;
            else
                Next_State = Op_square;
        end
        Op_mult:
            Next_State = Mult;
        Mult:
        begin
            if(mult0_done && mult1_done)
                Next_State = Shift;
            else
                Next_State = Mult;
        end
        Op_square:
            Next_State = Square;
        Square:
        begin
            if((mult0_done && mult1_done) && counter == 0)
                Next_State = Finish;
            else if(mult0_done && mult1_done)
                Next_State = Shift;
            else
                Next_State = Square;
        end
        Shift:
        begin
            if(counter == 0)
                Next_State = Finish;
            else
                Next_State = Check;
        end
        Finish: ;
        default: ;
    endcase

    mult_reset = 1'b1;
    a_load = 1'b0;
    op_load = 1'b0;
    count_set = 1'b0;
    a0_in = a0_out;
    a1_in = a1_out;
    op0_in = op0_out;
    op1_in = op1_out;
    out = 256'b0;
    Done = 1'b0;

    case(State)
        Start:
        begin
            mult_reset = 1'b0;
            a_load = 1'b1;
            a1_in = a_squared;
            a0_in = a;
        end
        Find_first_one:
            count_set = 1'b1;
        Check:
            mult_reset = 1'b0;
        Op_mult:
        begin
            op_load = 1'b1;
            op0_in = a1_out;
            op1_in = a1_out;
        end
        Mult:
            mult_reset = 1'b1;
        Op_square:
        begin
            op_load = 1'b1;
            op0_in = a0_out;
            op1_in = a0_out;
        end
        Square:
            mult_reset = 1'b1;
        Shift:
        begin
            a_load = 1'b1;
            a0_in = prod0;
            a1_in = prod1;
            count_set = 1'b1;
        end
        Finish:
        begin
            out = prod0;
            Done = 1'b1;
        end
    endcase
end

endmodule
