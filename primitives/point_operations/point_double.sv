module point_double
	#(parameter P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
	(input logic Clk, Reset,
	input logic [255:0]  Px, Py,
	output logic Done,
	output logic [255:0] Rx, Ry);

	logic mult0_done, mult1_done, inv_done, mult2_done, mult3_done;
	logic[255:0] sum0, sum1, sum2, sum3, sum4, sum5;
	logic[255:0] inv1;
	logic[255:0] prod0, prod1, prod2, prod3;
	logic mult0_reset;
	logic [4:0] counter;

	logic [255:0] temp_prod0;

	//s = Px + (Py / Px)
	//Rx = s*s + s
	//Ry = Px^2 + (s + 1)Rx

	// s = (3*Px*Px)+a / (2*Py)
	// Rx = s^2 - 2*Px
	// Ry = s*(Px - Rx) - Py

	always_ff @ (posedge Clk)
	begin
		if(Reset) begin
			mult0_reset <= 1'b0;
			counter <= 0;
		end
		else begin
			if(counter > 3)
				mult0_reset <= 1'b1;
			counter <= counter + 5'b01;
		end
	end

	/* Registers for tracking if parameters change (e.g. multiplier) */

	/* Calculate s. prod0*inv1 (prod0 = 3*Px*Px, inv1 is inv_mod of 2*Py)
		Note: We need to reset mutiplier and mod_inverse whenever parameters change.
		Mod inverse is not being reset because sum2 is loaded instantly, so it's ok */
	add #(P) add0(.a(Px), .b(Px), .op(1'b0), .sum(sum0)); // sum0 = 2*Px
	add #(P) add1(.a(Px), .b(sum0), .op(1'b0), .sum(sum1)); // sum1 = 3*Px
	add #(P) add2(.a(Py), .b(Py), .op(1'b0), .sum(sum2)); // sum2 = 2*Py
	multiplier #(P) mult0(.Clk, .Reset(Reset | ~mult0_reset), .a(Px), .b(sum1), .Done(mult0_done), .product(prod0)); // prod0 = Px*sum1
	modular_inverse #(P) inv0(.Clk, .Reset, .in({256'b0, sum2}), .out(inv1), .Done(inv_done));	// 1/2*Py
	multiplier #(P) mult1(.Clk, .Reset(Reset | ~(inv_done && mult0_done)), .a(prod0), .b(inv1), .Done(mult1_done), .product(prod1)); // s

	/* To test for a != 0, put in line */
	//	add  add6(.a({254'b0, 2'b10}), .b(prod0), .op(1'b0), .sum(temp_prod0));
	/* and use "temp_prod0" for "prod0"	in mult1.a()*/

	/* Calculate Rx. s*s - 2*Px (prod1*prod1 - sum0) */
	multiplier #(P) mult2(.Clk, .Reset(Reset | ~mult1_done), .a(prod1), .b(prod1), .Done(mult2_done), .product(prod2)); // s*s
	add #(P) add3(.a(prod2), .b(sum0), .op(1'b1), .sum(sum3)); // Rx = s*s - 2*Px

	/* Calculate Ry. s*(Px - Rx) - Py */
	add #(P) add4(.a(Px), .b(sum3), .op(1'b1), .sum(sum4)); // sum4 = Px - Rx. modp of course!
	multiplier #(P) mult3(.Clk, .Reset(Reset | ~mult2_done), .a(prod1), .b(sum4), .Done(mult3_done), .product(prod3)); // s*(Px - Rx)
	add #(P) add5(.a(prod3), .b(Py), .op(1'b1), .sum(sum5)); // sum5 = Ry = s*(Px-Rx) - Py

	assign Rx = sum3;
	assign Ry = sum5;
	assign Done = mult0_done & mult1_done & inv_done & mult2_done & mult3_done;	//Make sure everything finishes

endmodule
