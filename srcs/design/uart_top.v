`default_nettype none

module uart_top #(
parameter WORD_LEN = 8
)(
    input wire sys_clk, 	// System clock (parameterizable)
    input wire sys_rst_l, 	// Asynchronous active low reset
    input wire [WORD_LEN-1:0] xmit_dataH, // Transmitter input (parallel)
    input wire xmitH, // (Tx control input)
    input wire uart_REC_dataH, // Receiver input (serial input)
    output wire uart_xmit_dataH,	// Tx output
    output wire xmit_active,		// Tx output
    output wire xmit_doneH,		// Tx output
    output wire rec_readyH,		// Rx output 
    output wire rec_busy,		// Rx output
    output wire [WORD_LEN-1:0] rec_dataH	// Rx output (Parallel)
    );
    
    wire uart_clk;	// UART Clock from the baud_gen output
    
    // baud gen instantiation
    baud_gen  inst1 (.sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .uart_clk (uart_clk));
    
    // transmitter instantiation
    uart_xmit inst2(
	.uart_clk(uart_clk),	
	.xmit_dataH(xmit_dataH),	// user input	
	.xmitH(xmitH),	
	.sys_rst_l(sys_rst_l),	
	.uart_xmit_dataH(uart_xmit_dataH),
	.xmit_active(xmit_active),	
	.xmit_doneH(xmit_doneH)	
);

    // Receiver instantiation
    uart_rec  inst3(
	.uart_clk(uart_clk),
	.sys_rst_l(sys_rst_l),
	.uart_REC_dataH(uart_REC_dataH), // Asynchronous serial user input
	.rec_dataH(rec_dataH),
	.rec_busy(rec_busy),
	.rec_readyH(rec_readyH)
);

endmodule

