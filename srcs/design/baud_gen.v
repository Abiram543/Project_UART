`timescale 1ns / 1ps

`default_nettype none

module baud_gen #(
parameter BAUD = 2400,
parameter XTAL_CLK = 100_000_000,	// 100MHz
parameter WORD_LEN = 8
)(
input wire sys_clk,
input wire sys_rst_l, // active low reset signal
output reg uart_clk
);

localparam integer CV = XTAL_CLK/(16*2*BAUD);	// count value
localparam CW = $clog2(CV);	// counter width

//counter reg for generating baud clock
reg [CW-1:0] count;
	
always@(posedge sys_clk) begin
	if(!sys_rst_l) begin
		count <= 0;
		uart_clk <= 0;
	end
	else if(count == CV) begin
		uart_clk <= ~uart_clk;
		count <= 0;
	end
	else
		count <= count + 1;
end
endmodule

	

