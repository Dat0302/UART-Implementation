module hamming_decoder (
    input wire reset,
    input wire [7:0] received_data,
    output reg [3:0] corrected_data,
    output reg NE,
    output reg SEC,
    output reg DED
);

    reg [3:0] syndrome;
    reg [7:0] corrected_bits;

    always @(*) begin
        syndrome[0] = received_data[0] ^ received_data[2] ^ received_data[4] ^ received_data[6];
        syndrome[1] = received_data[1] ^ received_data[2] ^ received_data[5] ^ received_data[6];
        syndrome[2] = received_data[3] ^ received_data[4] ^ received_data[5] ^ received_data[6];
        syndrome[3] = received_data[7] ^ received_data[0] ^ received_data[1] ^ received_data[2] ^ received_data[3] ^ received_data[4] ^ received_data[5] ^ received_data[6];

        corrected_bits = received_data;

        if (reset) begin
            corrected_data = 4'b0000;
            NE = 0;
            SEC = 0;
            DED = 0;
        end else begin
            if (syndrome == 4'b0000) begin
                corrected_bits = received_data;
                NE = 1;
                SEC = 0;
                DED = 0;
            end else if (syndrome >= 1 && syndrome <= 8) begin
                corrected_bits[syndrome - 1] = ~received_data[syndrome - 1];
                NE = 0;
                SEC = 1;
                DED = 0;
            end else begin
                NE = 0;
                SEC = 0;
                DED = 1;
            end

            corrected_data = corrected_bits[6:3];
        end
    end
endmodule
