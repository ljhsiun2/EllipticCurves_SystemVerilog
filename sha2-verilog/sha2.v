// generalised round compression function
module sha2_round #(
    parameter WORDSIZE=0
) (
    input [WORDSIZE-1:0] Kj, Wj,
    input [WORDSIZE-1:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    input [WORDSIZE-1:0] Ch_e_f_g, Maj_a_b_c, S0_a, S1_e,
    output [WORDSIZE-1:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
    );

wire [WORDSIZE-1:0] T1 = h_in + S1_e + Ch_e_f_g + Kj + Wj;
wire [WORDSIZE-1:0] T2 = S0_a + Maj_a_b_c;

assign a_out = T1 + T2;
assign b_out = a_in;
assign c_out = b_in;
assign d_out = c_in;
assign e_out = d_in + T1;
assign f_out = e_in;
assign g_out = f_in;
assign h_out = g_in;

endmodule


// Ch(x,y,z)
module Ch #(parameter WORDSIZE=0) (
    input wire [WORDSIZE-1:0] x, y, z,
    output wire [WORDSIZE-1:0] Ch
    );

assign Ch = ((x & y) ^ (~x & z));

endmodule


// Maj(x,y,z)
module Maj #(parameter WORDSIZE=0) (
    input wire [WORDSIZE-1:0] x, y, z,
    output wire [WORDSIZE-1:0] Maj
    );

assign Maj = (x & y) ^ (x & z) ^ (y & z);

endmodule


// the message schedule: a machine that generates Wt values
module W_machine #(parameter WORDSIZE=1) (
    input clk,
    input [WORDSIZE*16-1:0] M,
    input M_valid,
    output [WORDSIZE-1:0] W_tm2, W_tm15,
    input [WORDSIZE-1:0] s1_Wtm2, s0_Wtm15,
    output [WORDSIZE-1:0] W
);
reg [WORDSIZE*16-1:0] W_stack_q;

// W(t-n) values, from the perspective of Wt_next
assign W_tm2 = W_stack_q[WORDSIZE*2-1:WORDSIZE*1];
assign W_tm15 = W_stack_q[WORDSIZE*15-1:WORDSIZE*14];
wire [WORDSIZE-1:0] W_tm7 = W_stack_q[WORDSIZE*7-1:WORDSIZE*6];
wire [WORDSIZE-1:0] W_tm16 = W_stack_q[WORDSIZE*16-1:WORDSIZE*15];
// Wt_next is the next Wt to be pushed to the queue, will be consumed in 16 rounds
wire [WORDSIZE-1:0] Wt_next = s1_Wtm2 + W_tm7 + s0_Wtm15 + W_tm16;

wire [WORDSIZE*16-1:0] W_stack_d = {W_stack_q[WORDSIZE*15-1:0], Wt_next};
assign W = W_stack_q[WORDSIZE*16-1:WORDSIZE*15];

always @(posedge clk)
begin
    if (M_valid) begin
        W_stack_q <= M;
    end else begin
        W_stack_q <= W_stack_d;
    end
end

endmodule
