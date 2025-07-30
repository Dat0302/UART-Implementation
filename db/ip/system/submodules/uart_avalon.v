module uart_avalon (
    // Avalon MM Interface
    input  wire        clk,           // Clock
    input  wire        reset,         // Reset
    input  wire [3:0]  address,       // Address bus (4-bit)
    input wire   chip_select,
    input  wire [31:0] writedata,     // Data to write (32-bit)
    output wire [31:0] readdata,      // Data to read (32-bit)
    
    // UART physical interface
    input  wire        rxd,           // Received serial data
    output wire        txd            // Transmitted serial data
);

    // Internal registers and wires
    reg [7:0]  data_in_reg;     // TX data register
    reg [1:0]  dwl_reg = 2'b11; // Data word length (default 8-bit)
    reg [2:0]  baud_sel_reg;    // Baud rate selection
    reg        mode_reg;        // Mode (0=normal, 1=Hamming)
    reg        baud_enable_reg; // Baud rate enable
    
    wire [7:0] d_out_wire;      // RX data output
    wire       oe_wire;         // Output enable
    wire       rxrdy_wire;      // Receiver ready
    wire       txrdy_wire;      // Transmitter ready
    wire       pe_wire;        // Parity error
    wire       fe_wire;        // Frame error
    wire       ne_wire;        // No error (hamming)
    wire       sec_wire;       // Single error corrected
    wire       ded_wire;       // Double error detected

    // Status register
    wire [31:0] status_reg = {
        24'b0,          // Reserved
        ded_wire,       // Double error detected
        sec_wire,       // Single error corrected
        ne_wire,        // No error
        fe_wire,        // Frame error
        pe_wire,        // Parity error
        txrdy_wire,     // Transmitter ready
        rxrdy_wire      // Receiver ready
    };

    // Control register
    wire [31:0] control_reg = {
        24'b0,          // Reserved
        baud_enable_reg, // Baud enable
        baud_sel_reg,   // Baud rate selection [2:0]
        1'b0,           // Reserved
        mode_reg,       // Mode select
        dwl_reg        // Data word length [1:0]
    };

    // Instantiate UART core
    top_module uart_core (
        .clk_in(clk),
        .reset(reset),
        .wr_bar(chip_select),      
        .rd_bar(~chip_select),      
        .data_in(data_in_reg),
        .rxd(rxd),
        .mode(mode_reg),
        .dwl(dwl_reg),
        .baud_sel(baud_sel_reg),
        .baud_enable(baud_enable_reg),
        .txd(txd),
        .d_out(d_out_wire),
        .oe(oe_wire),
        .rxrdy(rxrdy_wire),
        .txrdy(txrdy_wire),
        .pe(pe_wire),
        .fe(fe_wire),
        .ne(ne_wire),
        .sec(sec_wire),
        .ded(ded_wire)
    );

    // Avalon read interface
    assign readdata = (address == 4'h0) ? {24'b0, d_out_wire} :
                     (address == 4'h1) ? status_reg :
                     (address == 4'h2) ? control_reg : 32'b0;

    // Avalon write interface
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_in_reg <= 8'b0;
            dwl_reg <= 2'b11;       // Default 8-bit
            baud_sel_reg <= 3'b0;
            mode_reg <= 1'b0;
            baud_enable_reg <= 1'b0;
        end
        else if (write) begin
            case (address)
                4'h0: data_in_reg <= writedata[7:0];  // Write TX data
                4'h2: begin                          // Write control
                    baud_enable_reg <= writedata[7];
                    baud_sel_reg <= writedata[6:4];
                    mode_reg <= writedata[2];
                    dwl_reg <= writedata[1:0];
                end
            endcase
        end
    end

endmodule