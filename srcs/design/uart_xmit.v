`timescale 1ns / 1ps

`default_nettype none

module uart_xmit #(
parameter WORD_LEN = 8
)(
	input wire uart_clk,	// clock from baud generator
	input wire [WORD_LEN-1:0] xmit_dataH,	// parallel input data
	input wire xmitH,	// active high signal when it is high the tx will start
	input wire sys_rst_l,	// active low rst
	output reg uart_xmit_dataH,	// serial data out from the tx
	output reg xmit_active,	// active high when the tx is busy
	output reg xmit_doneH	//	logic high when the xmit completely sent the data
);

// state parameterization
localparam IDLE = 2'b00,
				START = 2'b01,
				DATA = 2'b10,
				STOP = 2'b11;

// reg declaration
reg [1:0] state;
reg [3:0] count_xmit; 		// internal counter for 16 cycle
reg [$clog2(WORD_LEN):0] index = 0;	// index of the data here WORD_LEN=8 bit data
 

always@(posedge uart_clk or negedge sys_rst_l)
begin
	if(!sys_rst_l) begin
		state <= IDLE;
		count_xmit <= 0;
	end
	else begin
		case(state)
		IDLE: begin
		    count_xmit <= 0;
			if(xmitH) begin
					state <= START;
				end
			else begin
				state <= IDLE;
			end
		end
		
		START: begin
			if(count_xmit == 4'd15) begin
				state <= DATA;
				count_xmit <= 0;
			end
			else begin
				state <= START;
				count_xmit <= count_xmit + 1;
			end
		end
		
		DATA: begin
			if(count_xmit == 4'd15	&& index == WORD_LEN-1) begin
				state <= STOP;
				count_xmit <= 0;
				index <= 0;
			end
			else begin
				state <= DATA;
				if(count_xmit == 4'd15) begin
					index <= index + 1;
					count_xmit <= 0;
				end
				else begin
					count_xmit <= count_xmit + 1;
				end
			end
		end
		
		STOP: begin
			if(count_xmit == 4'd15)begin
				state <= IDLE;
			end
			else begin
				state <= STOP;
				count_xmit <= count_xmit + 1;
			end
		end
		
		default: begin
			state <= IDLE;
		end
		endcase
	end
end

//Output logic
always@(*)begin
	xmit_active = (state != IDLE);
	xmit_doneH = (state == IDLE);
	case(state)
	   IDLE: uart_xmit_dataH = 1;
	   START: uart_xmit_dataH = 0;
	   DATA: uart_xmit_dataH = xmit_dataH[index];
	   STOP: uart_xmit_dataH = 1;
	   default: uart_xmit_dataH = 1;
	endcase
end


endmodule


