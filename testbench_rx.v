`timescale 1ns/1ps

module testbench_rx;

    reg clk_baud;
    reg rxd;
    reg Mode;
    reg [1:0] DWL;
    reg Rd_bar;
    reg Reset;
    wire [7:0] D_OUT;
    wire OE, RXRDY, PE, FE, NE, SEC, DED, PB;

    uart_rx uut (
        .clk_baud(clk_baud),
        .rxd(rxd),
        .Mode(Mode),
        .DWL(DWL),
        .Rd_bar(Rd_bar),
        .Reset(Reset),
        .D_OUT(D_OUT),
        .OE(OE),
        .RXRDY(RXRDY),
        .PE(PE),
        .FE(FE),
        .NE(NE),
        .SEC(SEC),
        .DED(DED)
    );

    // Tạo xung clk_baud ~57600 bps (≈17.36µs per bit)
    initial begin
        clk_baud = 0;
        forever #8680 clk_baud = ~clk_baud;  // T = 17.36us, f = 57600Hz
    end

    // Hamming(7,4) encoding for 4'b1101 = 8'b11101011
    // Frame = {Stop=1, Parity=1, Hamming=11101011, Start=0}
    reg [10:0] hamming_frame = 11'b1_1_11101011_0;
    integer i;

    initial begin

        // Initial state
        rxd = 1;
        Mode = 1;       // Hamming mode
        DWL = 2'b00;    // Don't care in Hamming
        Rd_bar = 1;
        Reset = 1;

        #1000 Reset = 0;
        #20000;

        // Send Hamming frame bit-by-bit, LSB first (start bit first)
        for (i = 0; i < 11; i = i + 1) begin
            rxd = hamming_frame[i];
            #17360;  // Wait one baud period (17.36 us)
        end

        // Set rxd back to idle
        rxd = 1;
        #50000;

        // Read if ready
        if (RXRDY) begin
            Rd_bar = 0;
            #17360;
            Rd_bar = 1;
        end

        #30000;
        $finish;
    end

endmodule
