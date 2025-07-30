module uart_tx (
    input  wire        clk_baud,
    input  wire        reset,
    input  wire        wr_bar,
    input  wire        mode,
    input  wire [1:0]  DWL,
    input  wire [7:0]  data_in,
    output wire        txd,
    output reg         txrdy,
    output wire [10:0] shift_reg_out
);

    reg  [10:0] shift_reg;
    reg  [3:0]  bit_cnt;
    reg         sending;

    wire [7:0]  hamming_encoded;
    wire        parity_bit;

    encoder h_enc (
        .data_in(data_in[3:0]),
        .encoded_out(hamming_encoded)
    );

    assign parity_bit = ^data_in[7:0];
    assign txd = shift_reg[0];
    assign shift_reg_out = shift_reg;

    always @(posedge clk_baud or posedge reset) begin
        if (reset) begin
            shift_reg <= 11'b11111111111;
            bit_cnt   <= 4'd0;
            sending   <= 1'b0;
            txrdy     <= 1'b1;
        end else begin
            if (!wr_bar && !sending) begin
                if (mode == 1'b1) begin
                    shift_reg <= {2'b11, hamming_encoded, 1'b0};
                end else begin
                    case (DWL)
                        2'b00: shift_reg <= {1'b1, parity_bit, 3'b000, data_in[4:0], 1'b0};
                        2'b01: shift_reg <= {1'b1, parity_bit, 2'b00, data_in[5:0], 1'b0};
                        2'b10: shift_reg <= {1'b1, parity_bit, 1'b0, data_in[6:0], 1'b0};
                        2'b11: shift_reg <= {1'b1, parity_bit, data_in[7:0], 1'b0};
                    endcase
                end
                sending  <= 1'b1;
                bit_cnt  <= 4'd0;
                txrdy    <= 1'b0;
            end else if (sending && clk_baud) begin
                shift_reg <= {1'b1, shift_reg[10:1]};
                bit_cnt   <= bit_cnt + 1;
                if (bit_cnt == 4'd10) begin
                    sending <= 1'b0;
                    txrdy   <= 1'b1;
                end
            end
        end
    end

endmodule
