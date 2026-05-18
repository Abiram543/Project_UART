`default_nettype none

module uart_top #(
parameter WORD_LEN = 8
)(
    input wire sys_clk, sys_rst_l,
    input wire [WORD_LEN-1:0] xmit_dataH,
    input wire xmitH,
    output wire uart_xmit_dataH,
    output wire xmit_active,
    output wire xmit_doneH,
    output wire rec_readyH,
    output wire rec_busy,
    output wire [WORD_LEN-1:0] rec_dataH
    );
    
    wire uart_clk;
    
    // baud gen instantiation
    baud_gen  inst1 (.sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .uart_clk (uart_clk));
    
    // transmitter instantiation
    uart_xmit inst2(
	.uart_clk(uart_clk),	
	.xmit_dataH(xmit_dataH),	
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
	.uart_REC_dataH(uart_xmit_dataH), // Asynchronous serial input from the TX output
	.rec_dataH(rec_dataH),
	.rec_busy(rec_busy),
	.rec_readyH(rec_readyH)
);


endmodule

