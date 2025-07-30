library verilog;
use verilog.vl_types.all;
entity hamming_decoder is
    port(
        reset           : in     vl_logic;
        received_data   : in     vl_logic_vector(7 downto 0);
        corrected_data  : out    vl_logic_vector(3 downto 0);
        NE              : out    vl_logic;
        SEC             : out    vl_logic;
        DED             : out    vl_logic
    );
end hamming_decoder;
