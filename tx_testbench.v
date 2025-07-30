`timescale 1ns/1ps

module tx_testbench;

    reg clk_baud;
    reg reset;
    reg wr_bar;
    reg mode;
    reg [1:0] DWL;
    reg [7:0] data_in;

    wire txd;
    wire txrdy;
    wire [10:0] shift_reg_out;

    uart_tx uut (
        .clk_baud(clk_baud),
        .reset(reset),
        .wr_bar(wr_bar),
        .mode(mode),
        .DWL(DWL),
        .data_in(data_in),
        .txd(txd),
        .txrdy(txrdy),
        .shift_reg_out(shift_reg_out)
    );

    // Baud clock = 57600 bps -> T ~ 17361 ns
    initial begin
        clk_baud = 0;
        forever #8680 clk_baud = ~clk_baud;  // 50% duty cycle
    end

    // Stimulus
    initial begin


        // Initial values
        reset = 1;
        wr_bar = 1;
        mode = 1;               // Hamming mode
        DWL = 2'b00;            // Don't care in Hamming mode
        data_in = 8'b00001101;  // Lower 4 bits = 1101

        // Reset pulse
        #100 reset = 0;
        #200;

        // Trigger one transmission
        wr_bar = 0;
        #17370;  // One clk_baud cycle
        wr_bar = 1;

        // Wait for transmission (11 bits * 17361 ns ≈ 191us)
        wait (txrdy == 1);
        #20000;

        $finish;
    end

endmodule
