module FIFO_MEM_CNTRL #(parameter FIFO_width = 16 , parameter FIFO_depth = 8 , parameter Pointer_Size = 4 ) 
(
input wire  [ FIFO_width-1   :0 ] w_data,
input wire  [ Pointer_Size-2 :0 ] w_addr,
input wire  [ Pointer_Size-2 :0 ] r_addr,
input wire  w_inc,
input wire  w_full,
input wire  wclk,
input wire  wrst_n,
output wire  [ FIFO_width-1 :0 ] r_data
);
reg [FIFO_width-1 :0 ] FIFO_MEM [FIFO_depth-1:0];
integer i ;
integer j ;
always@(posedge wclk or negedge wrst_n)
 begin
	if(!wrst_n)
		begin
		 for( i = 0 ; i < (FIFO_depth) ; i = i+1 )
		  for( j = 0 ; j < (FIFO_width) ; j = j+1 )
				FIFO_MEM[i][j] <= 1'b0;
		end
	else
		begin
			if(w_inc && !w_full)
				begin
					FIFO_MEM[w_addr] <= w_data;
				end
		end
 end
 
 assign r_data = FIFO_MEM[r_addr];
 
 endmodule
