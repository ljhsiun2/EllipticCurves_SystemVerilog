module elg_encrypt
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset,
	input logic [255:0]  Gx, Gy, Qx, Qy, priv, message,
	output logic Done,
	output logic [255:0] Cx, Cy, Dx, Dy);

	// Px, Py is bob_point/other person's point i.e. public key.
	// Qx, Qx is shared secret point.
	logic[255:0] messagey;
	/* insert message stuff here; possibly do in C? */
	// C1 = r*G; C2 = r*pub_bob + message_encoded
	logic Done_C, Done_D, Done_tempD, done_mult0, done_mult1, done_mult2, done_sqrt;
	logic[255:0] tempDx, tempDy, r, temp_message, message_cube;
	logic [255:0] y_sqrd, y_sqrd_sqrd; // In square root, you need x1 = a, and x2 = a^2
	assign r = priv; // should just be priv

	/* This logic is for calculating f(m), i.e. calculating y in y^2 = x^3 + 7 mod p */
	multiplier #(P) mult0(.Clk, .Reset, .a(message), .b(message), .Done(done_mult0), .product(temp_message));
	multiplier #(P) mult1(.Clk, .Reset(Reset | ~done_mult0), .a(message), .b(temp_message), .Done(done_mult1), .product(message_cube));
	add #(P) add0(.a(message_cube), .b({252'b0, 4'b0111}), .op(1'b0), .sum(y_sqrd));
	multiplier #(P) mult2(.Clk, .Reset(Reset | ~done_mult1), .a(y_sqrd), .b(y_sqrd), .Done(done_mult2), .product(y_sqrd_sqrd));
	square_root #(P) sqrt(.Clk, .Reset(Reset | ~done_mult2), .a(y_sqrd), .a_squared(y_sqrd_sqrd), .out(messagey), .Done(done_sqrt));

	/* Generates C1 = r*G */
	gen_point #(P) gen_C(.Clk, .Reset, .privKey(r), .Gx, .Gy, .Done(Done_C), .outX(Cx), .outY(Cy));

	/* Generates Secret Point */
	gen_point #(P) gen_tempD(.Clk, .Reset(Reset | ~Done_C), .Gx(Qx), .Gy(Qy), .privKey(r), .Done(Done_tempD), .outX(tempDx), .outY(tempDy));

	/* Geneartes C2 = Secret + Pm */
	point_add #(P) gen_D(.Clk, .Reset(Reset | ~(Done_tempD && done_sqrt)), .Px(tempDx), .Py(tempDy), .Qx(message), .Qy(messagey), .Done(Done_D),
					.Rx(Dx), .Ry(Dy));

	assign Done = Done_D;

endmodule
