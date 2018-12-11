module point_add
	(input logic clk, Reset,
	input logic [255:0]  Py, Qy, Px, Qx,
	output logic Done,
	output logic [255:0] Rx, Ry);

	logic mult0_done, inv_done, mult1_done, mult2_done;
	logic[255:0] sum0, sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8, s;
	logic[255:0] inv1;
	logic[255:0] prod1, prod2, prod3;
	logic reset0, reset1, reset2, inv_reset;

	logic[2:0] counter;

	//s = (Py + Qy) / (Px + Qx)
	//Rx = s*s + s + Px + Qx
	//Ry = s(Px + Rx) + Rx + Py

	// s = (Py - Qy) / (Px - Qx)
	// Rx = s*s - Px - Qx
	// Ry = s(Px - Rx) - Py

	always_ff @ (posedge clk)
	begin
		if(Reset) begin
			counter <= 0;
			reset2 <= 1'b0;
		end
		else
		begin
			if(mult1_done)
				counter <= counter + 1'b1;
			if(counter > 5)
				reset2 <= 1'b1;
		end
	end

	add add0(.a(Py), .b(Qy), .op(1'b1), .sum(sum0));	// Py - Qy
	add add1(.a(Px), .b(Qx), .op(1'b1), .sum(sum1));	// Px - Qx
	modular_inverse inv0(.clk, .Reset, .in({256'b0, sum1}), .out(inv1), .Done(inv_done)); //1/Px-Qx
	multiplier mult0(.clk, .Reset(~inv_done | Reset), .a(sum0), .b(inv1), .Done(mult0_done), .product(s)); //slope

	multiplier mult1(.clk, .Reset(~mult0_done | Reset), .a(s), .b(s), .Done(mult1_done), .product(prod2)); // s^2
	add add2(.a(Px), .b(Qx), .op(1'b0), .sum(sum3));	// Px + Qx
	add add3(.a(prod2), .b(sum3), .op(1'b1), .sum(sum4)); // s^2 - (Px + Qx)
	add add4(.a(Px), .b(sum4), .op(1'b1), .sum(sum5));	// Px - Rx
	add add5(.a(prod3), .b(Py), .op(1'b1), .sum(sum6)); // s(Px-Rx) - Py
	multiplier mult2(.clk, .Reset(~reset2 | Reset), .a(s), .b(sum5), .Done(mult2_done), .product(prod3)); //s(Px - Rx)
	/* to use a nonzero a, uncomment below line and replace all "sum4" with "sum8" */
	//add #(17) add7(.a(sum4), .b({254'b0, 2'b10}), .op(1'b0), .sum(sum8)); // Rx + a (for x^3 + 2x + 2, a is 2)


	assign Rx = sum4;
	assign Ry = sum6;
	assign Done = mult0_done & inv_done & mult1_done & mult2_done;

endmodule
