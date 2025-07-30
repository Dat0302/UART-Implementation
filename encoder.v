module encoder (
    input  wire [3:0] data_in,     
    output wire [7:0] encoded_out  
);

    wire d0, d1, d2, d3;
    wire p0, p1, p2, p_all;

    assign d0 = data_in[0];
    assign d1 = data_in[1];
    assign d2 = data_in[2];
    assign d3 = data_in[3];


    assign h0 = d1 ^ d2 ^ d3;       
    assign h1 = d0 ^ d2 ^ d3;       
    assign h2 = d1 ^ d0 ^ d3;      
	 assign h3 = d0 ^ d1 ^ d2;


    assign encoded_out = {h3,h2,h1,h0,d3, d2, d1, d0};

endmodule	