module uart_rx (
    input wire clk_baud,
    input wire rxd,
    input wire Mode,
    input wire [1:0] DWL,
    input wire Rd_bar,
    input wire Reset,
    output reg [7:0] D_OUT,
    output wire OE,
    output reg RXRDY,
    output wire PE,
    output wire FE,
    output wire NE,
    output wire SEC,
    output wire DED
);

    reg [10:0] shift_reg;
    reg [3:0] bit_count;
    reg receiving;
    reg [7:0] data_buffer;
    reg buffer_full;
    reg frame_error;
    reg pe_valid;

    wire parity_bit;
    wire [7:0] hamming_input;
    wire [3:0] corrected_data;
    assign hamming_input = shift_reg[8:1];

    assign parity_bit = ^data_buffer;
    assign PE = (pe_valid && Mode == 0) ? (parity_bit != shift_reg[9]) : 1'bz;

    hamming_decoder h_dec (
        .reset(Reset),
        .received_data(hamming_input),
        .corrected_data(corrected_data),
        .NE(NE),
        .SEC(SEC),
        .DED(DED)
    );

    assign FE = frame_error;
    assign OE = ~Rd_bar & buffer_full;

    always @(posedge clk_baud or posedge Reset) begin
        if (Reset) begin
            shift_reg <= 11'bz;
            bit_count <= 0;
            receiving <= 0;
            RXRDY <= 0;
            data_buffer <= 0;
            buffer_full <= 0;
            frame_error <= 1'bz;
            pe_valid <= 0;
            D_OUT <= 8'b0;
        end
        else begin
            if (!receiving && rxd == 1'b0) begin
                receiving <= 1;
                bit_count <= 0;
                RXRDY <= 0;
                frame_error <= 1'bz;
            end
            else if (receiving) begin
                if (bit_count < 10) begin
                    shift_reg <= {rxd, shift_reg[10:1]};
                    bit_count <= bit_count + 1;
                end else begin
                    receiving <= 0;
                    bit_count <= bit_count + 1;
                end

                if (bit_count == 9) begin
                    pe_valid <= 1;
                end
                if (bit_count == 10) begin
                    receiving <= 0;
                    buffer_full <= 1;
                    RXRDY <= 1;
                    frame_error <= (shift_reg[10] != 1'b1);
                    if (Mode == 0) begin
                        case (DWL)
                            2'b00: data_buffer <= {3'b0, shift_reg[8:4]};
                            2'b01: data_buffer <= {2'b0, shift_reg[8:3]};
                            2'b10: data_buffer <= {1'b0, shift_reg[8:2]};
                            2'b11: data_buffer <= shift_reg[8:1];
                        endcase
                    end
                    else begin
                        data_buffer <= {4'b0, corrected_data};
                    end
                end
            end

            if (!Rd_bar && RXRDY) begin
                D_OUT <= data_buffer;
                buffer_full <= 0;
                RXRDY <= 0;
            end
        end
    end
endmodule
