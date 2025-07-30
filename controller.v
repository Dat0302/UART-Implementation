module controller (
    input  wire        clk_baud,        // Baud rate clock from Baud Rate Generator
    input  wire        reset,           // Reset (active high)
    input  wire        mode,            // Mode select (1: error correction, 0: normal)
    input  wire [1:0]  DWL,             // Data word length select
    input  wire        WR_bar,          // Write signal (active low)
    input  wire        RD_bar,          // Read signal (active low)
    input  wire        RXD,             // Serial input data (for start bit detection)
    output reg         enable_transmit, // Enable Transmitter Block
    output reg         enable_receive,  // Enable Receiver Block
    output reg         load_data,       // Load data to Transmitter Block
    output reg         read_data        // Read data from Receiver Block
);

// Transmitter states
localparam TX_IDLE            = 4'd0,
           TX_ERROR_CORRECTION = 4'd1,
           TX_NORMAL          = 4'd2,
           TX_START           = 4'd3,
           TX_B0              = 4'd4,
           TX_B1              = 4'd5,
           TX_B2              = 4'd6,
           TX_B3              = 4'd7,
           TX_B4              = 4'd8,
           TX_B5              = 4'd9,
           TX_B6              = 4'd10,
           TX_B7              = 4'd11,
           TX_PARITY          = 4'd12,
           TX_STOP            = 4'd13;

// Receiver states
localparam RX_IDLE            = 4'd0,
           RX_B0              = 4'd1,
           RX_B1              = 4'd2,
           RX_B2              = 4'd3,
           RX_B3              = 4'd4,
           RX_B4              = 4'd5,
           RX_B5              = 4'd6,
           RX_B6              = 4'd7,
           RX_B7              = 4'd8,
           RX_PARITY          = 4'd9,
           RX_STOP            = 4'd10,
           RX_INTERMEDIATE    = 4'd11;

// Internal signals
reg [3:0] tx_state, tx_next_state;
reg [3:0] rx_state, rx_next_state;
reg [2:0] data_length; // Data word length (5-8 bits)

// Map DWL to data length (Table 1)
always @(*) begin
    if (DWL == 2'b00) data_length = 3'd5;
    else if (DWL == 2'b01) data_length = 3'd6;
    else if (DWL == 2'b10) data_length = 3'd7;
    else data_length = 3'd8;
end

// Transmitter Controller: State Register
always @(posedge clk_baud or posedge reset) begin
    if (reset) begin
        tx_state <= TX_IDLE;
    end else begin
        tx_state <= tx_next_state;
    end
end

// Transmitter Controller: Next State and Output Logic using if-else
always @(*) begin
    // Default values
    tx_next_state = tx_state;
    enable_transmit = 1'b0;
    load_data = 1'b0;

    if (tx_state == TX_IDLE) begin
        if (WR_bar == 1'b0) begin
            if (mode)
                tx_next_state = TX_ERROR_CORRECTION;
            else
                tx_next_state = TX_NORMAL;
        end
    end else if (tx_state == TX_ERROR_CORRECTION) begin
        load_data = 1'b1; // Signal Transmitter Block to load and encode data
        tx_next_state = TX_START;
    end else if (tx_state == TX_NORMAL) begin
        load_data = 1'b1; // Signal Transmitter Block to load and prepare data
        tx_next_state = TX_START;
    end else if (tx_state == TX_START) begin
        enable_transmit = 1'b1; // Start transmitting (start bit)
        tx_next_state = TX_B0;
    end else if (tx_state == TX_B0) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_B1;
    end else if (tx_state == TX_B1) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_B2;
    end else if (tx_state == TX_B2) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_B3;
    end else if (tx_state == TX_B3) begin
        enable_transmit = 1'b1;
        if (mode || (!mode && data_length == 5))
            tx_next_state = TX_PARITY; // Directly to PARITY if 5 bits
        else
            tx_next_state = TX_B4;
    end else if (tx_state == TX_B4) begin
        enable_transmit = 1'b1;
        if (mode || (!mode && data_length == 6))
            tx_next_state = TX_PARITY; // Directly to PARITY if 6 bits
        else
            tx_next_state = TX_B5;
    end else if (tx_state == TX_B5) begin
        enable_transmit = 1'b1;
        if (mode || (!mode && data_length == 7))
            tx_next_state = TX_PARITY; // Directly to PARITY if 7 bits
        else
            tx_next_state = TX_B6;
    end else if (tx_state == TX_B6) begin
        enable_transmit = 1'b1;
        if (mode || (!mode && data_length == 8))
            tx_next_state = TX_PARITY; // Directly to PARITY if 8 bits
        else
            tx_next_state = TX_B7;
    end else if (tx_state == TX_B7) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_PARITY;
    end else if (tx_state == TX_PARITY) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_STOP;
    end else if (tx_state == TX_STOP) begin
        enable_transmit = 1'b1;
        tx_next_state = TX_IDLE; // Directly transition to IDLE
    end else begin
        tx_next_state = TX_IDLE;
    end
end

// Receiver Controller: State Register
always @(posedge clk_baud or posedge reset) begin
    if (reset) begin
        rx_state <= RX_IDLE;
    end else begin
        rx_state <= rx_next_state;
    end
end

// Receiver Controller: Next State and Output Logic using if-else
always @(*) begin
    // Default values
    rx_next_state = rx_state;
    enable_receive = 1'b0;
    read_data = 1'b0;

    if (rx_state == RX_IDLE) begin
        if (RXD == 1'b0) begin // Start bit detected
            rx_next_state = RX_B0;
            enable_receive = 1'b1;
        end
    end else if (rx_state == RX_B0) begin
        enable_receive = 1'b1;
        rx_next_state = RX_B1;
    end else if (rx_state == RX_B1) begin
        enable_receive = 1'b1;
        rx_next_state = RX_B2;
    end else if (rx_state == RX_B2) begin
        enable_receive = 1'b1;
        rx_next_state = RX_B3;
    end else if (rx_state == RX_B3) begin
        enable_receive = 1'b1;
        if (mode || (!mode && data_length == 5))
            rx_next_state = RX_PARITY; // Directly to PARITY if 5 bits
        else
            rx_next_state = RX_B4;
    end else if (rx_state == RX_B4) begin
        enable_receive = 1'b1;
        if (mode || (!mode && data_length == 6))
            rx_next_state = RX_PARITY; // Directly to PARITY if 6 bits
        else
            rx_next_state = RX_B5;
    end else if (rx_state == RX_B5) begin
        enable_receive = 1'b1;
        if (mode || (!mode && data_length == 7))
            rx_next_state = RX_PARITY; // Directly to PARITY if 7 bits
        else
            rx_next_state = RX_B6;
    end else if (rx_state == RX_B6) begin
        enable_receive = 1'b1;
        if (mode || (!mode && data_length == 8))
            rx_next_state = RX_PARITY; // Directly to PARITY if 8 bits
        else
            rx_next_state = RX_B7;
    end else if (rx_state == RX_B7) begin
        enable_receive = 1'b1;
        rx_next_state = RX_PARITY;
    end else if (rx_state == RX_PARITY) begin
        enable_receive = 1'b1;
        rx_next_state = RX_STOP;
    end else if (rx_state == RX_STOP) begin
        enable_receive = 1'b1;
        rx_next_state = RX_INTERMEDIATE; // Directly transition to INTERMEDIATE
    end else if (rx_state == RX_INTERMEDIATE) begin
        read_data = 1'b1; // Signal Receiver Block to provide data and error signals
        if (RD_bar == 1'b0) begin
            rx_next_state = RX_IDLE;
        end else begin
            rx_next_state = RX_INTERMEDIATE; // Stay in INTERMEDIATE until RD_bar = 0
        end
    end else begin
        rx_next_state = RX_IDLE;
    end
end

endmodule