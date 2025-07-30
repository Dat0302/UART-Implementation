`timescale 1ns/1ps

module controller_tb;

    // Inputs
    reg clk_baud;
    reg reset;
    reg mode;
    reg [1:0] DWL;
    reg WR_bar;
    reg RD_bar;
    reg RXD;
    
    // Outputs
    wire enable_transmit;
    wire enable_receive;
    wire load_data;
    wire read_data;
    
    // Instantiate the Unit Under Test (UUT)
    controller uut (
        .clk_baud(clk_baud),
        .reset(reset),
        .mode(mode),
        .DWL(DWL),
        .WR_bar(WR_bar),
        .RD_bar(RD_bar),
        .RXD(RXD),
        .enable_transmit(enable_transmit),
        .enable_receive(enable_receive),
        .load_data(load_data),
        .read_data(read_data)
    );
    
    // Baud clock generation (115200 baud rate example)
    parameter BAUD_PERIOD = 8680; // 115200 baud = 8.68us per bit
    initial begin
        clk_baud = 0;
        forever #(BAUD_PERIOD/2) clk_baud = ~clk_baud;
    end
    
    // Test procedure
    initial begin
        // Initialize Inputs
        reset = 1;
        mode = 0;
        DWL = 2'b11; // 8-bit by default
        WR_bar = 1;
        RD_bar = 1;
        RXD = 1; // Idle state is high
        
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        
        // Test Case 1: Normal mode transmission (8-bit)
        $display("Test Case 1: Normal mode transmission (8-bit)");
        mode = 0;
        DWL = 2'b11; // 8-bit
        #BAUD_PERIOD;
        WR_bar = 0; // Initiate write
        #BAUD_PERIOD;
        WR_bar = 1;
        
        // Monitor transmitter states
        #(BAUD_PERIOD * 12); // Wait for full transmission (start + 8 bits + parity + stop)
        
        // Test Case 2: Error correction mode transmission (5-bit)
        $display("\nTest Case 2: Error correction mode transmission (5-bit)");
        mode = 1;
        DWL = 2'b00; // 5-bit
        #BAUD_PERIOD;
        WR_bar = 0; // Initiate write
        #BAUD_PERIOD;
        WR_bar = 1;
        
        // Monitor transmitter states
        #(BAUD_PERIOD * 8); // Wait for full transmission (start + 5 bits + parity + stop)
        
        // Test Case 3: Normal mode reception (7-bit)
        $display("\nTest Case 3: Normal mode reception (7-bit)");
        mode = 0;
        DWL = 2'b10; // 7-bit
        RXD = 1; // Idle
        #BAUD_PERIOD;
        
        // Simulate incoming data (start bit + 7 data bits + parity + stop)
        RXD = 0; // Start bit
        #BAUD_PERIOD;
        RXD = 1; // Bit 0
        #BAUD_PERIOD;
        RXD = 0; // Bit 1
        #BAUD_PERIOD;
        RXD = 1; // Bit 2
        #BAUD_PERIOD;
        RXD = 0; // Bit 3
        #BAUD_PERIOD;
        RXD = 1; // Bit 4
        #BAUD_PERIOD;
        RXD = 0; // Bit 5
        #BAUD_PERIOD;
        RXD = 1; // Bit 6
        #BAUD_PERIOD;
        RXD = 0; // Parity
        #BAUD_PERIOD;
        RXD = 1; // Stop bit
        #BAUD_PERIOD;
        
        // Read the received data
        RD_bar = 0;
        #BAUD_PERIOD;
        RD_bar = 1;
        
        // Test Case 4: Error correction mode reception (6-bit)
        $display("\nTest Case 4: Error correction mode reception (6-bit)");
        mode = 1;
        DWL = 2'b01; // 6-bit
        RXD = 1; // Idle
        #BAUD_PERIOD;
        
        // Simulate incoming data (start bit + 6 data bits + parity + stop)
        RXD = 0; // Start bit
        #BAUD_PERIOD;
        RXD = 1; // Bit 0
        #BAUD_PERIOD;
        RXD = 0; // Bit 1
        #BAUD_PERIOD;
        RXD = 1; // Bit 2
        #BAUD_PERIOD;
        RXD = 0; // Bit 3
        #BAUD_PERIOD;
        RXD = 1; // Bit 4
        #BAUD_PERIOD;
        RXD = 0; // Bit 5
        #BAUD_PERIOD;
        RXD = 1; // Parity
        #BAUD_PERIOD;
        RXD = 1; // Stop bit
        #BAUD_PERIOD;
        
        // Read the received data
        RD_bar = 0;
        #BAUD_PERIOD;
        RD_bar = 1;
        
        // End simulation
        #100;
        $display("\nAll test cases completed");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time = %t: State = TX:%0d RX:%0d | WR_bar=%b RD_bar=%b | En_TX=%b En_RX=%b | Load=%b Read=%b | RXD=%b",
            $time, uut.tx_state, uut.rx_state, WR_bar, RD_bar, 
            enable_transmit, enable_receive, load_data, read_data, RXD);
    end
    
endmodule