module uart_test(
		input CLOCK_50,
		input [0:0] KEY,
		input UART_RXD,
		output UART_TXD
);
 
		system1 u0(
			.clk_clk (CLOCK_50),
			.reset_reset_n (KEY[0]),
			.uart_custom_0_conduit_end_txd (UART_TXD),
			.uart_custom_0_conduit_end_rxd (UART_RXD)
			);
endmodule