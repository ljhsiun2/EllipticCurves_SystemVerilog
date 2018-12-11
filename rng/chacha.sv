module chacha
			(input logic clk, Reset,
			input logic [255:0] key,
			input logic [127:0] nonce,
			output logic [511:0] stream,
			output logic Done);

/*Each of the following is a 32 bit word
**
**constant constant constant constant
**key		key		key			key
**key		key		key			key
**input		input	input		input

**0			1			2			3
**4			5			6			7
**8			9			10			11
**12		13			14			15

**constant: "expand 32-byte k" in ASCII
**key: 256-bit private key that we will use -- can optionally seed
**input: 2 words are usually for a counter, and 2 for a nonce.  Since we don't need a counter,
** we'll use a 4 word nonce. This can be set using a PRNG in C or a TRNG in the form of a ring oscillator
*/

logic [511:0] state_in, state_out, original_state;
logic [3:0] count_in, count_out;
logic [31:0] a1, b1, c1, d1, w1, x1, y1, z1;
logic [31:0] a2, b2, c2, d2, w2, x2, y2, z2;
logic [31:0] a3, b3, c3, d3, w3, x3, y3, z3;
logic [31:0] a4, b4, c4, d4, w4, x4, y4, z4;

logic [32:0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16;
logic state_load, count_load;

assign original_state = {128'h617078653320646e79622d326b206574, key, nonce};



reg_256 #(512) stateReg(.clk, .Load(state_load), .Data(state_in), .Out(state_out));
reg_256 #(4) roundReg(.clk, .Load(count_load), .Data(count_in), .Out(count_out));

quarter_round qr1(.a(a1), .b(b1), .c(c1), .d(d1), .w(w1), .x(x1), .y(y1), .z(z1));
quarter_round qr2(.a(a2), .b(b2), .c(c2), .d(d2), .w(w2), .x(x2), .y(y2), .z(z2));
quarter_round qr3(.a(a3), .b(b3), .c(c3), .d(d3), .w(w3), .x(x3), .y(y3), .z(z3));
quarter_round qr4(.a(a4), .b(b4), .c(c4), .d(d4), .w(w4), .x(x4), .y(y4), .z(z4));

enum logic [2:0] {Init, Col, Diag, Add, Finish} State, Next_State;


    always_ff @ (posedge clk)
    begin
        if(Reset)
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
		Init: Next_State = Col;
		Col: Next_State = Diag;
		Diag:
		begin
			if(count_out == 5'b1010)
				Next_State = Add;
			else
				Next_State = Col;
		end
		Add: Next_State = Finish;
		Finish: Next_State = Finish;
		default: ;
	endcase

	//Default vals
	state_in = state_out;
	count_in = count_out;
	Done = 1'b0;
	stream = 512'b0;

	state_load = 1'b0;
	count_load = 1'b0;
	a1 = 32'b0;
	a2 = 32'b0;
	a3 = 32'b0;
	a4 = 32'b0;
	b1 = 32'b0;
	b2 = 32'b0;
	b3 = 32'b0;
	b4 = 32'b0;
	c1 = 32'b0;
	c2 = 32'b0;
	c3 = 32'b0;
	c4 = 32'b0;
	d1 = 32'b0;
	d2 = 32'b0;
	d3 = 32'b0;
	d4 = 32'b0;

	s1 = 33'b0;
	s2 = 33'b0;
	s3 = 33'b0;
	s4 = 33'b0;
	s5 = 33'b0;
	s6 = 33'b0;
	s7 = 33'b0;
	s8 = 33'b0;
	s9 = 33'b0;
	s10 = 33'b0;
	s11 = 33'b0;
	s12 = 33'b0;
	s13 = 33'b0;
	s14 = 33'b0;
	s15 = 33'b0;
	s16 = 33'b0;

	unique case(State)
		Init:
		begin
			state_load = 1'b1;
			count_load = 1'b1;

			count_in = 4'b0;

			state_in[511:384] = 128'h617078653320646e79622d326b206574;	//Constant
			state_in[383:128] = key;
			state_in[127:0] = nonce;

		end
		Col:
		begin
			count_load = 1'b1;
			count_in = count_out + 4'b01;

			state_load = 1'b1;

			a1 = state_out[511:480];	//0
			a2 = state_out[479:448];	//1
			a3 = state_out[447:416];	//2
			a4 = state_out[415:384];	//3

			b1 = state_out[383:352];	//4
			b2 = state_out[351:320];	//5
			b3 = state_out[319:288];	//6
			b4 = state_out[287:256];	//7

			c1 = state_out[255:224];	//8
			c2 = state_out[223:192];	//9
			c3 = state_out[191:160];	//10
			c4 = state_out[159:128];	//11

			d1 = state_out[127:96];		//12
			d2 = state_out[95:64];		//13
			d3 = state_out[63:32];		//14
			d4 = state_out[31:0];		//15

			state_in[511:480] = w1;
			state_in[479:448] = w2;
			state_in[447:416] = w3;
			state_in[415:384] = w4;

			state_in[383:352] = x1;
			state_in[351:320] = x2;
			state_in[319:288] = x3;
			state_in[287:256] = x4;

			state_in[255:224] = y1;
			state_in[223:192] = y2;
			state_in[191:160] = y3;
			state_in[159:128] = y4;

			state_in[127:96] = z1;
			state_in[95:64] = z2;
			state_in[63:32] = z3;
			state_in[31:0] = z4;
		end
		Diag:
		begin
			state_load = 1'b1;

			a1 = state_out[511:480];	//0
			a2 = state_out[479:448];	//1
			a3 = state_out[447:416];	//2
			a4 = state_out[415:384];	//3

			b1 = state_out[351:320];	//5
			b2 = state_out[319:288];	//6
			b3 = state_out[287:256];	//7
			b4 = state_out[383:352];	//4

			c1 = state_out[191:160];	//10
			c2 = state_out[159:128];	//11
			c3 = state_out[255:224];	//8
			c4 = state_out[223:192];	//9

			d1 = state_out[31:0];		//15
			d2 = state_out[127:96];		//12
			d3 = state_out[95:64];		//13
			d4 = state_out[63:32];		//14

			state_in[511:480] = w1;		//0
			state_in[479:448] = w2;		//1
			state_in[447:416] = w3;		//2
			state_in[415:384] = w4;		//3

			state_in[351:320] = x1;		//5
			state_in[319:288] = x2;		//6
			state_in[287:256] = x3;		//7
			state_in[383:352] = x4;		//4

			state_in[191:160] = y1;		//10
			state_in[159:128] = y2;
			state_in[255:224] = y3;
			state_in[223:192] = y4;

			state_in[31:0] = z1;
			state_in[127:96] = z2;
			state_in[95:64] = z3;
			state_in[63:32] = z4;
		end
		Add:
		begin
			state_load = 1'b1;

			s1 = state_out[511:480] + original_state[511:480];
			s2 = state_out[479:448] + original_state[479:448];
			s3 = state_out[447:416] + original_state[447:416];
			s4 = state_out[415:384] + original_state[415:384];

			s5 = state_out[383:352] + original_state[383:352];
			s6 = state_out[351:320] + original_state[351:320];
			s7 = state_out[319:288] + original_state[319:288];
			s8 = state_out[287:256] + original_state[287:256];

			s9 = state_out[255:224] + original_state[255:224];
			s10 = state_out[223:192] + original_state[223:192];
			s11 = state_out[191:160] + original_state[191:160];
			s12 = state_out[159:128] + original_state[159:128];

			s13 = state_out[127:96] + original_state[127:96];
			s14 = state_out[95:64] + original_state[95:64];
			s15 = state_out[63:32] + original_state[63:32];
			s16 = state_out[31:0] + original_state[31:0];	//Effectively adds the two

			state_in[511:480] = s1[31:0];
			state_in[479:448] = s2[31:0];
			state_in[447:416] = s3[31:0];
			state_in[415:384] = s4[31:0];

			state_in[383:352] = s5[31:0];
			state_in[351:320] = s6[31:0];
			state_in[319:288] = s7[31:0];
			state_in[287:256] = s8[31:0];

			state_in[255:224] = s9[31:0];
			state_in[223:192] = s10[31:0];
			state_in[191:160] = s11[31:0];
			state_in[159:128] = s12[31:0];

			state_in[127:96] = s13[31:0];
			state_in[95:64] = s14[31:0];
			state_in[63:32] = s15[31:0];
			state_in[31:0] = s16[31:0];
		end
		Finish:
		begin
			Done = 1'b1;
			//FUCK THIS SHIT
			stream = {state_out[487:480], state_out[495:488], state_out[503:496], state_out[511:504], state_out[455:448], state_out[463:456], state_out[471:464], state_out[479:472], state_out[423:416], state_out[431:424], state_out[439:432], state_out[447:440], state_out[391:384], state_out[399:392], state_out[407:400], state_out[415:408], state_out[359:352], state_out[367:360], state_out[375:368], state_out[383:376], state_out[327:320], state_out[335:328], state_out[343:336], state_out[351:344], state_out[295:288], state_out[303:296], state_out[311:304], state_out[319:312], state_out[263:256], state_out[271:264], state_out[279:272], state_out[287:280], state_out[231:224], state_out[239:232], state_out[247:240], state_out[255:248], state_out[199:192], state_out[207:200], state_out[215:208], state_out[223:216], state_out[167:160], state_out[175:168], state_out[183:176], state_out[191:184], state_out[135:128], state_out[143:136], state_out[151:144], state_out[159:152], state_out[103:96], state_out[111:104], state_out[119:112], state_out[127:120], state_out[71:64], state_out[79:72], state_out[87:80], state_out[95:88], state_out[39:32], state_out[47:40], state_out[55:48], state_out[63:56], state_out[7:0], state_out[15:8], state_out[23:16], state_out[31:24]} ;
		end
		default: ;
	endcase
end

endmodule
