module avalon_console_interface
	(input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [4:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [255:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [255:0] AVL_READDATA,	// Avalon-MM Read Data

	output logic [31:0] EXPORT_DATA	
);

//FOR PASSING KEYS:
//REGISTERS 0-7: MSG_IN
//REGISTERS 8-15: KEY_OUT
//REGISTER 30: START
//REGISTER 31: DONE

logic [31:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D30, D31, Data_Out;

//Instantiate regfile to transfer data to and from software
regfile reg0(.Clk(CLK), .Reset(RESET), .Load(AVL_WRITE), .ADDR(AVL_ADDR), .write_data(AVL_WRITEDATA), .AVL_BYTE_EN, .D0, .D1, .D2, .D3, .D4, .D5, .D6, .D7, .D8, .D9, .D10, .D11, .D12, .D13, .D14, .D15, .D30, .D31, .Data_Out(AVL_READDATA));

//Control logic
control c0(.Clk(CLK), .reset(RESET), .Start(D30[3:0]), .in({D0, D1, D2, D3, D4, D5, D6, D7}), .export_key({D8, D9, D10, D11, D12, D13, D14, D15}), .Done(D31[0]));

assign EXPORT_DATA = D30;

endmodule
