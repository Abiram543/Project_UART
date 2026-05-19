`default_nettype none

module uart_rec #(
parameter WORD_LEN = 8
)(
	input wire uart_clk,
	input wire sys_rst_l,
	input wire uart_REC_dataH, // Asynchronous serial input
	output reg [WORD_LEN-1:0] rec_dataH,
	output reg rec_busy,
	output reg rec_readyH
);

// state parameterization
localparam START = 2'b00,
		   DATA = 2'b01,
		   STOP = 2'b10;

// reg declaration
reg [1:0] state;
reg [3:0] count_rec;
reg temp = 0;	// temprory register for START state
reg [WORD_LEN-1:0]rec_dataH_temp = 0;	// temprory register for output parallel data.
reg [$clog2(WORD_LEN)-1:0] index;	// Index number for each input data
reg reg1, reg2; // Dual rank synchronizer registers

//dual rank synchronizer
always@(posedge uart_clk or negedge sys_rst_l)
begin
	if(!sys_rst_l)begin
		reg1 <= 1;
		reg2 <= 1;
	end
	else begin
		reg1 <= uart_REC_dataH;
		reg2 <= reg1;
	end
end
	
// Receiver logic
always@(posedge uart_clk or negedge sys_rst_l)
begin
	if(!sys_rst_l)begin
		state <= START;
		count_rec <= 0;
		rec_readyH <= 1;
	    rec_busy <= 0;
		rec_dataH <= 0;
	end
	else begin
		case(state)
		START: begin
			index <= 0;
			if(reg2 == 0) begin
			     rec_readyH <= 0;
			     rec_busy <= 1;
			     if(count_rec == 4'd15) begin
			     	if(temp) begin
			     		state <= DATA;
			     		count_rec <= 0;
			     		temp <= 0;
			     	end
			     	else begin
			     		state <= START;
			     		count_rec <= 0;
			     	end
			     end
			     else begin
			          state <= START;
			     	count_rec <= count_rec + 1;
			     	if(count_rec == 4'd7)
			     		temp <= 1;
			     	else
			     		temp <= temp;
			     end
			end
			else begin
			     state <= START;
			     count_rec <= 0;
		    end
		end
		
		DATA: begin
			if(index >= WORD_LEN-1 && count_rec == 4'd15) begin
				state <= STOP;
				count_rec <= 0;
				index <= 0;
			end
			else begin
				state <= DATA;
				if(count_rec == 4'd15) begin
					count_rec <= 0;
					index <= index + 1;
				end
				else begin
					count_rec <= count_rec + 1;
					if(count_rec == 4'd7)
						rec_dataH_temp[index] <= reg2;
					else
						rec_dataH_temp[index] <= rec_dataH_temp[index];
				end
			end
		end
		
		STOP: begin
			if(count_rec == 4'd15) begin
				state <= START;
				if(temp) begin
					count_rec <= 0;
					temp <= 0;
				end
				else begin
					count_rec <= 0;
					rec_dataH_temp <= 0;
				end
			end
			else begin
				count_rec <= count_rec + 1;
				state <= STOP;
				if(count_rec == 4'd7 && reg2 == 1) begin
				    rec_dataH <= rec_dataH_temp;
					temp <= 1;
					rec_readyH <= 1;
			        rec_busy <= 0;
				end
				else
					temp <= temp;
			end
		end
		
		default: begin
			count_rec <= 0;
			state <= START;
			rec_dataH_temp <= 0;
			rec_dataH <= rec_dataH;
			index <= 0;
			temp <= 0;
		end
		endcase
	end
end


endmodule
					

