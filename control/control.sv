module control
		(input logic Clk, reset,
		input logic[3:0] Start,
		input logic[255:0] in,
		output logic[255:0] export_key,
		output logic Done);


logic [255:0] alice_outx, alice_outy, bob_outx, bob_outy, msg_in, msg_out;
logic [255:0] P, n, Gx, Gy, alice_out, bob_out, decrypted_x, decrypted_y;

logic [255:0] seed_in, seed_out;

logic Reset, reset_load, reset_in;

logic [255:0] Cx, Cy, Dx, Dy;

logic done_bob, done_encrypt, done_decrypt, done_chacha;

logic [511:0] stream_out;

logic load_done, done_in;

//logic alice_x_load, alice_y_load, alice_priv_load, bob_x_load, bob_y_load, bob_priv_load, secret_x_load, secret_y_load, msg_load;
logic msg_load, seed_load;
assign P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
assign n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
assign Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
assign Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;


reg_256 message(.Clk, .Reset, .Load(msg_load), .Data(msg_in), .Out(msg_out));
reg_256 seed(.Clk, .Reset, .Load(seed_load), .Data(seed_in), .Out(seed_out));

reg_256 #(1) doneReg(.Clk, .Reset, .Load(load_done), .Data(done_in), .Out(Done));
reg_256 #(1) resetReg(.Clk, .Reset, .Load(reset_load), .Data(reset_in), .Out(Reset));

/*reg_256 Alice_priv(.Clk, .Reset, .Load(alice_priv_load), .Data(alice_in), .Out(alice_out));
reg_256 Bob_priv(.Clk, .Reset, .Load(bob_priv_load), .Data(bob_in), .Out(bob_out));

reg_256 Alice_x(.Clk, .Reset, .Load(alice_x_load), .Data(Cx), .Out(alice_outx));
reg_256 Alice_y(.Clk, .Reset, .Load(alice_y_load), .Data(Cy), Out(alice_outy));
reg_256 Bob_x(.Clk, .Reset, .Load(bob_x_load), .Data(bob_inx), .Out(bob_outx));
reg_256 Bob_y(.Clk, .Reset, .Load(bob_y_load), .Data(bob_iny), .Out(bob_outy));*/

enum logic [3:0] {Init, Get_Msg, Get_Seed, Out_PrivA, Out_PrivB, Out_PubAX, Out_PubAY, Out_PubBX, Out_PubBY, Out_Msg_Enc_X, Out_Msg_Enc_Y, Out_Msg_Dec_X, Out_Msg_Dec_Y, Finish} State, Next_State;

//Generate user's public key
gen_point #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) bob_point(.Clk, .Reset(Reset | ~done_chacha), .privKey(bob_out), .Gx, .Gy,
					.outX(bob_outx), .outY(bob_outy), .Done(done_bob));

//Encrypt the message using the generated public key and an additional public key internal to elg_encrypt
elg_encrypt #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) encrypt_message(.Clk, .Reset(Reset | ~done_bob), .priv(alice_out), .Gx, .Gy, .Qx(bob_outx), .Qy(bob_outy),
			.message(msg_out), .Done(done_encrypt), .Cx, .Cy, .Dx, .Dy);

//Decrypt the message
elg_decrypt #(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F) decrypt_message(.Clk, .Reset(Reset | ~done_encrypt), .Cx, .Cy, .Dx, .Dy,
			.priv(bob_out), .Done(done_decrypt), .outx(decrypted_x), .outy(decrypted_y));

//Generate two 256 bit private keys from a 512 bit random number stream
chacha chacha20(.Clk, .Reset, .key(256'b0), .nonce(128'b0), .stream(stream_out), .Done(done_chacha));

always_ff @ (posedge Clk)
begin
    if(reset)
	begin
        State <= Init;
	end
    else
        State <= Next_State;
end

//Next state logic

//Start = 1'b1 always indicates that the software is done saving whatever is in the output register and the state machine can move on
always_comb begin
    Next_State = State;
    unique case(State)
	Init:
	begin
		if(Start == 4'b0001)
			Next_State = Get_Msg;
		else
			Next_State = Init;
	end
	Get_Msg:
	begin
		if(Start == 4'b0010)
			Next_State = Get_Seed;
		else
			Next_State = Get_Msg;
	end
	Get_Seed:
	begin
		if(Start == 4'b0011)
			Next_State = Out_PrivA;
		else
			Next_State = Get_Seed;
	end
	Out_PrivA:
	begin
		if(done_chacha == 1'b1 && Start == 4'b0100)
			Next_State = Out_PrivB;
		else
			Next_State = Out_PrivA;
	end
	Out_PrivB:
	begin
		if(done_chacha == 1'b1 && Start == 4'b0101)
			Next_State = Out_PubBX;
		else
			Next_State = Out_PrivB;
	end
	Out_PubBX:
	begin
		if(done_bob == 1'b1 && Start == 4'b0110)
			Next_State = Out_PubBY;
		else
			Next_State = Out_PubBX;
	end
	Out_PubBY:
	begin
		if(done_bob == 1'b1 && Start == 4'b0111)
			Next_State = Out_PubAX;
		else
			Next_State = Out_PubBY;
	end
	Out_PubAX:
	begin
		if(done_encrypt == 1'b1 && Start == 4'b1000)
			Next_State = Out_PubAY;
		else
			Next_State = Out_PubAX;
	end
	Out_PubAY:
	begin
		if(done_encrypt == 1'b1 && Start == 4'b1001)
			Next_State = Out_Msg_Enc_X;
		else
			Next_State = Out_PubAY;
	end
	Out_Msg_Enc_X:
	begin
		if(done_encrypt == 1'b1 && Start == 4'b1010)
			Next_State = Out_Msg_Enc_Y;
		else
			Next_State = Out_Msg_Enc_X;
	end
	Out_Msg_Enc_Y:
	begin
		if(done_encrypt == 1'b1 && Start == 4'b1011)
			Next_State = Out_Msg_Dec_X;
		else
			Next_State = Out_Msg_Enc_Y;
	end
	Out_Msg_Dec_X:
	begin
		if(done_decrypt == 1'b1 && Start == 4'b1100)
			Next_State = Out_Msg_Dec_Y;
		else
			Next_State = Out_Msg_Dec_X;
	end
	Out_Msg_Dec_Y:
	begin
		if(done_decrypt == 1'b1 && Start == 4'b1101)
			Next_State = Finish;
		else
			Next_State = Out_Msg_Dec_Y;
	end
	Finish:
	begin
		if(Start == 4'b1111)		//Give option to reset and run again without recompiling
			Next_State = Init;
		else
			Next_State = Finish;
	end
	default: ;
	endcase

	load_done = 1'b0;
	done_in = Done;
	export_key = 256'b0;
	msg_load = 1'b0;
	msg_in = msg_out;
	alice_out = {1'b0, stream_out[511:257]};
	bob_out = {1'b0, stream_out[255:1]};
	seed_load = 1'b0;
	seed_in = seed_out;
	reset_in = Reset || reset;
	reset_load = 1'b0;

    unique case(State)
	Init:
	begin
		reset_in = 1'b1;
		reset_load = 1'b1;
		load_done = 1'b1;
		done_in = 1'b0;
	end
	Get_Msg:
	begin
		reset_in = 1'b0;
		reset_load = 1'b1;
		msg_load = 1'b1;
		msg_in = in;
	end
	Get_Seed:
	begin
		seed_load = 1'b1;
		seed_in = in;
	end
	Out_PrivA:
	begin
		export_key = alice_out;
		done_in = done_chacha;
		load_done = 1'b1;
	end
	Out_PrivB:
	begin
		export_key = bob_out;
		done_in = done_chacha;
		load_done = 1'b1;
	end
	Out_PubBX:
	begin
		export_key = bob_outx;
		done_in = done_bob;
		load_done = 1'b1;
	end
	Out_PubBY:
	begin
		export_key = bob_outy;
		done_in = done_bob;
		load_done = 1'b1;
	end
	Out_PubAX:
	begin
		export_key = Cx;
		done_in = done_encrypt;
		load_done = 1'b1;
	end
	Out_PubAY:
	begin
		export_key = Cy;
		done_in = done_encrypt;
		load_done = 1'b1;
	end
	Out_Msg_Enc_X:
	begin
		export_key = Dx;
		done_in = done_encrypt;
		load_done = 1'b1;
	end
	Out_Msg_Enc_Y:
	begin
		export_key = Dy;
		done_in = done_encrypt;
		load_done = 1'b1;
	end
	Out_Msg_Dec_X:
	begin
		export_key = decrypted_x;
		done_in = done_decrypt;
		load_done = 1'b1;
	end
	Out_Msg_Dec_Y:
	begin
		export_key = decrypted_y;
		done_in = done_decrypt;
		load_done = 1'b1;
	end
	Finish:
	begin
		done_in = 1'b1;
		load_done = 1'b1;
	end
	default: ;
	endcase
end

endmodule
