module uart (
    input  wire        Clk_in,
	 input wire [2:0]   sel;
    input  wire        reset,
	 input  wire [7:0]  data_in,
    input  wire        mode,
    input  wire [1:0]  DWL,
    input  wire        wr_bar,
    input  wire [1:0]  rd_bar,
	 output wire        txrdy,
    output wire        rxrdy,
	 output wire [7:0]  data_out,
    output wire        txd,
    output wire [7:0]  data_out,
    output wire [7:0]  received_encoded
);