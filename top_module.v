module top_module (
    input  wire        clk_in,
    input  wire        reset,
    input  wire        wr_bar,
    input  wire        rd_bar,
    input  wire [7:0]  data_in,
    input  wire        rxd,
    input  wire        mode,
    input  wire [1:0]  dwl,
    input  wire [2:0]  baud_sel,
    input  wire        baud_enable,

    output wire        txd,
    output wire [7:0]  d_out,
    output wire        oe,
    output wire        rxrdy,
    output wire        txrdy,
    output wire        pe,
    output wire        fe,
    output wire        ne,
    output wire        sec,
    output wire        ded
);

    wire clk_baud;
    wire [10:0] tx_shift_debug;

    baud_rate_generator baud_gen (
        .clk_in(clk_in),
        .reset(reset),
        .sel(baud_sel),
        .baud_enable(baud_enable),
        .clk_baud(clk_baud)
    );

    uart_tx tx_unit (
        .clk_baud(clk_baud),
        .reset(reset),
        .wr_bar(wr_bar),
        .mode(mode),
        .DWL(dwl),
        .data_in(data_in),
        .txd(txd),
        .txrdy(txrdy),
        .shift_reg_out(tx_shift_debug) 
    );

    uart_rx rx_unit (
        .clk_baud(clk_baud),
        .rxd(rxd),
        .Mode(mode),
        .DWL(dwl),
        .Rd_bar(rd_bar),
        .Reset(reset),
        .D_OUT(d_out),
        .OE(oe),
        .RXRDY(rxrdy),
        .PE(pe),
        .FE(fe),
        .NE(ne),
        .SEC(sec),
        .DED(ded)
    );

endmodule
