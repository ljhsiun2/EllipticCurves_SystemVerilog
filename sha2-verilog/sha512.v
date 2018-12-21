// block processor
// NB: master *must* continue to assert H_in until we have signaled output_valid
module sha512_block (
    input clk, rst,
    input [511:0] H_in,
    input [1023:0] M_in,
    input input_valid,
    output [511:0] H_out,
    output output_valid
    );

reg [6:0] round;
wire [63:0] a_in = H_in[511:448], b_in = H_in[447:384], c_in = H_in[383:320], d_in = H_in[319:256];
wire [63:0] e_in = H_in[255:192], f_in = H_in[191:128], g_in = H_in[127:64], h_in = H_in[63:0];
reg [63:0] a_q, b_q, c_q, d_q, e_q, f_q, g_q, h_q;
wire [63:0] a_d, b_d, c_d, d_d, e_d, f_d, g_d, h_d;
wire [63:0] W_tm2, W_tm15, s1_Wtm2, s0_Wtm15, Wj, Kj;
assign H_out = {
    a_in + a_q, b_in + b_q, c_in + c_q, d_in + d_q, e_in + e_q, f_in + f_q, g_in + g_q, h_in + h_q
};
assign output_valid = round == 80;

always @(posedge clk)
begin
    if (input_valid) begin
        a_q <= a_in; b_q <= b_in; c_q <= c_in; d_q <= d_in;
        e_q <= e_in; f_q <= f_in; g_q <= g_in; h_q <= h_in;
        round <= 0;
    end else begin
        a_q <= a_d; b_q <= b_d; c_q <= c_d; d_q <= d_d;
        e_q <= e_d; f_q <= f_d; g_q <= g_d; h_q <= h_d;
        round <= round + 1;
    end
end

sha512_round sha512_round (
    .Kj(Kj), .Wj(Wj),
    .a_in(a_q), .b_in(b_q), .c_in(c_q), .d_in(d_q),
    .e_in(e_q), .f_in(f_q), .g_in(g_q), .h_in(h_q),
    .a_out(a_d), .b_out(b_d), .c_out(c_d), .d_out(d_d),
    .e_out(e_d), .f_out(f_d), .g_out(g_d), .h_out(h_d)
);

sha512_s0 sha512_s0 (.x(W_tm15), .s0(s0_Wtm15));
sha512_s1 sha512_s1 (.x(W_tm2), .s1(s1_Wtm2));

W_machine #(.WORDSIZE(64)) W_machine (
    .clk(clk),
    .M(M_in), .M_valid(input_valid),
    .W_tm2(W_tm2), .W_tm15(W_tm15),
    .s1_Wtm2(s1_Wtm2), .s0_Wtm15(s0_Wtm15),
    .W(Wj)
);

sha512_K_machine sha512_K_machine (
    .clk(clk), .rst(input_valid), .K(Kj)
);

endmodule


// round compression function
module sha512_round (
    input [63:0] Kj, Wj,
    input [63:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output [63:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
    );

wire [63:0] Ch_e_f_g, Maj_a_b_c, S0_a, S1_e;

Ch #(.WORDSIZE(64)) Ch (
    .x(e_in), .y(f_in), .z(g_in), .Ch(Ch_e_f_g)
);

Maj #(.WORDSIZE(64)) Maj (
    .x(a_in), .y(b_in), .z(c_in), .Maj(Maj_a_b_c)
);

sha512_S0 S0 (
    .x(a_in), .S0(S0_a)
);

sha512_S1 S1 (
    .x(e_in), .S1(S1_e)
);

sha2_round #(.WORDSIZE(64)) sha256_round_inner (
    .Kj(Kj), .Wj(Wj),
    .a_in(a_in), .b_in(b_in), .c_in(c_in), .d_in(d_in),
    .e_in(e_in), .f_in(f_in), .g_in(g_in), .h_in(h_in),
    .Ch_e_f_g(Ch_e_f_g), .Maj_a_b_c(Maj_a_b_c), .S0_a(S0_a), .S1_e(S1_e),
    .a_out(a_out), .b_out(b_out), .c_out(c_out), .d_out(d_out),
    .e_out(e_out), .f_out(f_out), .g_out(g_out), .h_out(h_out)
);

endmodule


// Σ₀(x)
module sha512_S0 (
    input wire [63:0] x,
    output wire [63:0] S0
    );

assign S0 = ({x[27:0], x[63:28]} ^ {x[33:0], x[63:34]} ^ {x[38:0], x[63:39]});

endmodule


// Σ₁(x)
module sha512_S1 (
    input wire [63:0] x,
    output wire [63:0] S1
    );

assign S1 = ({x[13:0], x[63:14]} ^ {x[17:0], x[63:18]} ^ {x[40:0], x[63:41]});

endmodule


// σ₀(x)
module sha512_s0 (
    input wire [63:0] x,
    output wire [63:0] s0
    );

assign s0 = ({x[0:0], x[63:1]} ^ {x[7:0], x[63:8]} ^ (x >> 7));

endmodule


// σ₁(x)
module sha512_s1 (
    input wire [63:0] x,
    output wire [63:0] s1
    );

assign s1 = ({x[18:0], x[63:19]} ^ {x[60:0], x[63:61]} ^ (x >> 6));

endmodule


// a machine that delivers round constants
module sha512_K_machine (
    input clk,
    input rst,
    output [63:0] K
    );

reg [5119:0] rom_q;
wire [5119:0] rom_d = { rom_q[5055:0], rom_q[5119:5056] };
assign K = rom_q[5119:5056];

always @(posedge clk)
begin
    if (rst) begin
        rom_q <= {
            64'h428a2f98d728ae22, 64'h7137449123ef65cd, 64'hb5c0fbcfec4d3b2f, 64'he9b5dba58189dbbc,
            64'h3956c25bf348b538, 64'h59f111f1b605d019, 64'h923f82a4af194f9b, 64'hab1c5ed5da6d8118,
            64'hd807aa98a3030242, 64'h12835b0145706fbe, 64'h243185be4ee4b28c, 64'h550c7dc3d5ffb4e2,
            64'h72be5d74f27b896f, 64'h80deb1fe3b1696b1, 64'h9bdc06a725c71235, 64'hc19bf174cf692694,
            64'he49b69c19ef14ad2, 64'hefbe4786384f25e3, 64'h0fc19dc68b8cd5b5, 64'h240ca1cc77ac9c65,
            64'h2de92c6f592b0275, 64'h4a7484aa6ea6e483, 64'h5cb0a9dcbd41fbd4, 64'h76f988da831153b5,
            64'h983e5152ee66dfab, 64'ha831c66d2db43210, 64'hb00327c898fb213f, 64'hbf597fc7beef0ee4,
            64'hc6e00bf33da88fc2, 64'hd5a79147930aa725, 64'h06ca6351e003826f, 64'h142929670a0e6e70,
            64'h27b70a8546d22ffc, 64'h2e1b21385c26c926, 64'h4d2c6dfc5ac42aed, 64'h53380d139d95b3df,
            64'h650a73548baf63de, 64'h766a0abb3c77b2a8, 64'h81c2c92e47edaee6, 64'h92722c851482353b,
            64'ha2bfe8a14cf10364, 64'ha81a664bbc423001, 64'hc24b8b70d0f89791, 64'hc76c51a30654be30,
            64'hd192e819d6ef5218, 64'hd69906245565a910, 64'hf40e35855771202a, 64'h106aa07032bbd1b8,
            64'h19a4c116b8d2d0c8, 64'h1e376c085141ab53, 64'h2748774cdf8eeb99, 64'h34b0bcb5e19b48a8,
            64'h391c0cb3c5c95a63, 64'h4ed8aa4ae3418acb, 64'h5b9cca4f7763e373, 64'h682e6ff3d6b2b8a3,
            64'h748f82ee5defb2fc, 64'h78a5636f43172f60, 64'h84c87814a1f0ab72, 64'h8cc702081a6439ec,
            64'h90befffa23631e28, 64'ha4506cebde82bde9, 64'hbef9a3f7b2c67915, 64'hc67178f2e372532b,
            64'hca273eceea26619c, 64'hd186b8c721c0c207, 64'heada7dd6cde0eb1e, 64'hf57d4f7fee6ed178,
            64'h06f067aa72176fba, 64'h0a637dc5a2c898a6, 64'h113f9804bef90dae, 64'h1b710b35131c471b,
            64'h28db77f523047d84, 64'h32caab7b40c72493, 64'h3c9ebe0a15c9bebc, 64'h431d67c49c100d4c,
            64'h4cc5d4becb3e42b6, 64'h597f299cfc657e2a, 64'h5fcb6fab3ad6faec, 64'h6c44198c4a475817
        };
    end else begin
        rom_q <= rom_d;
    end
end

endmodule


// initial hash values
module sha512_H_0(
    output [511:0] H_0
    );

assign H_0 = {
    64'h6A09E667F3BCC908, 64'hBB67AE8584CAA73B, 64'h3C6EF372FE94F82B, 64'hA54FF53A5F1D36F1,
    64'h510E527FADE682D1, 64'h9B05688C2B3E6C1F, 64'h1F83D9ABFB41BD6B, 64'h5BE0CD19137E2179
};

endmodule
