library verilog;
use verilog.vl_types.all;
entity uart_rx is
    port(
        clk_baud        : in     vl_logic;
        rxd             : in     vl_logic;
        Mode            : in     vl_logic;
        DWL             : in     vl_logic_vector(1 downto 0);
        Rd_bar          : in     vl_logic;
        Reset           : in     vl_logic;
        D_OUT           : out    vl_logic_vector(7 downto 0);
        OE              : out    vl_logic;
        RXRDY           : out    vl_logic;
        PE              : out    vl_logic;
        FE              : out    vl_logic;
        NE              : out    vl_logic;
        SEC             : out    vl_logic;
        DED             : out    vl_logic
    );
end uart_rx;
