module regfile (input logic Clk, Reset, Load,
				input logic [4:0] ADDR,	//Address of registers
				input logic [31:0] write_data,
				input  logic [4:0] AVL_BYTE_EN,	
				output logic [31:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16, D17,D18, D19, D20, D21, D22, D23, D30, D31, Data_Out);

	logic [31:0] newData, Data;

//REGISTERS 0-7: PRIVATE KEY
//REGISTERS 8-15: POINT X
//REGISTERS 16-23: POINT Y
//REGISTER 30: START
//REGISTER 31: DONE
	

//Determine which bytes to assign to registers
always_comb
begin
	case(AVL_BYTE_EN)
		4'b1111: Data = write_data;
		4'b1100: Data = {write_data[31:16], newData[15:0]};
		4'b0011: Data = {newData[31:16], write_data[15:0]};
		4'b0100: Data = {newData[31:24], write_data[23:16], newData[15:0]};
		4'b0010: Data = {newData[31:16], write_data[15:8], newData[7:0]};
		4'b0001: Data = {newData[31:8], write_data[7:0]};
		default: Data = newData;	//Keep everything the same
	endcase
end

	//Instantiate the 26 registers 0-23, 30, 31
	reg_256 #(32) reg0(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00000) & Load), .Data(Data), .Out(D0));
	reg_256 #(32) reg1(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00001) & Load), .Data(Data), .Out(D1));
	reg_256 #(32) reg2(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00010) & Load), .Data(Data), .Out(D2));
	reg_256 #(32) reg3(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00011) & Load), .Data(Data), .Out(D3));
	reg_256 #(32) reg4(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00100) & Load), .Data(Data), .Out(D4));
	reg_256 #(32) reg5(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00101) & Load), .Data(Data), .Out(D5));
	reg_256 #(32) reg6(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00110) & Load), .Data(Data), .Out(D6));
	reg_256 #(32) reg7(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b00111) & Load), .Data(Data), .Out(D7));
	reg_256 #(32) reg8(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01000) & Load), .Data(Data), .Out(D8));
	reg_256 #(32) reg9(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01001) & Load), .Data(Data), .Out(D9));
	reg_256 #(32) reg10(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01010) & Load), .Data(Data), .Out(D10));
	reg_256 #(32) reg11(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01011) & Load), .Data(Data), .Out(D11));
	reg_256 #(32) reg12(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01100) & Load), .Data(Data), .Out(D12));
	reg_256 #(32) reg13(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01101) & Load), .Data(Data), .Out(D13));
	reg_256 #(32) reg14(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01110) & Load), .Data(Data), .Out(D14));
	reg_256 #(32) reg15(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b01111) & Load), .Data(Data), .Out(D15));
	reg_256 #(32) reg16(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10000) & Load), .Data(Data), .Out(D16));
	reg_256 #(32) reg17(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10001) & Load), .Data(Data), .Out(D17));
	reg_256 #(32) reg18(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10010) & Load), .Data(Data), .Out(D18));
	reg_256 #(32) reg19(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10011) & Load), .Data(Data), .Out(D19));
	reg_256 #(32) reg20(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10100) & Load), .Data(Data), .Out(D20));
	reg_256 #(32) reg21(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10101) & Load), .Data(Data), .Out(D21));
	reg_256 #(32) reg22(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10110) & Load), .Data(Data), .Out(D22));
	reg_256 #(32) reg23(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b10111) & Load), .Data(Data), .Out(D23));
	reg_256 #(32) reg30(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b11110) & Load), .Data(Data), .Out(D30));
	reg_256 #(32) reg31(.Clk(Clk), .Reset(Reset), .Load((ADDR == 5'b11111) & Load), .Data(Data), .Out(D31));


//Read logic
	always_comb
	begin
			unique case(ADDR)
				5'b00000: Data_Out = D0;
				5'b00001: Data_Out = D1;
				5'b00010: Data_Out = D2;
				5'b00011: Data_Out = D3;
				5'b00100: Data_Out = D4;
				5'b00101: Data_Out = D5;
				5'b00110: Data_Out = D6;
				5'b00111: Data_Out = D7;
				5'b01000: Data_Out = D8;
				5'b01001: Data_Out = D9;
				5'b01010: Data_Out = D10;
				5'b01011: Data_Out = D11;
				5'b01100: Data_Out = D12;
				5'b01101: Data_Out = D13;
				5'b01110: Data_Out = D14;
				5'b01111: Data_Out = D15;
				5'b10000: Data_Out = D16;
				5'b10001: Data_Out = D17;
				5'b10010: Data_Out = D18;
				5'b10011: Data_Out = D19;
				5'b10100: Data_Out = D20;
				5'b10101: Data_Out = D21;
				5'b10110: Data_Out = D22;
				5'b10111: Data_Out = D23;
				5'b11110: Data_Out = D30;
				5'b11111: Data_Out = D31;
				default: Data_Out = 32'b0;
			endcase
	end
		

endmodule

	

	




