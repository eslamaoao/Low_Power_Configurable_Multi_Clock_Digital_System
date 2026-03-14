module FIFO_WR #(parameter Pointer_Size = 4 ) 
(
input wire winc,
input wire wclk,
input wire wrst_n,

input  wire [Pointer_Size-1:0] sync_r2w_ptr,

output reg  [Pointer_Size-1:0] gray_w2r_ptr,
output wire [Pointer_Size-2:0] waddr,
output wire wfull

);

reg [Pointer_Size-1:0] wptr ;
always@(posedge wclk or negedge wrst_n)
 begin
	if(!wrst_n)
	 begin
		wptr <= 'b0;
	 end
	else if (!wfull && winc)
	 begin
		wptr <= wptr + 1 ;
	 end
 end
 
 
assign waddr = wptr [Pointer_Size-2:0] ;
 
 
 always@(posedge wclk or negedge wrst_n)
 begin
	if(!wrst_n)
	 begin
		gray_w2r_ptr <= 'b0;
	 end
	else 
	 begin
		case (wptr)
		4'b0000 : gray_w2r_ptr <= 4'b0000;
		4'b0001 : gray_w2r_ptr <= 4'b0001;
		4'b0010 : gray_w2r_ptr <= 4'b0011;
		4'b0011 : gray_w2r_ptr <= 4'b0010;
		4'b0100 : gray_w2r_ptr <= 4'b0110;
		4'b0101 : gray_w2r_ptr <= 4'b0111;
		4'b0110 : gray_w2r_ptr <= 4'b0101;
		4'b0111 : gray_w2r_ptr <= 4'b0100;
		4'b1000 : gray_w2r_ptr <= 4'b1100;
		4'b1001 : gray_w2r_ptr <= 4'b1101;
		4'b1010 : gray_w2r_ptr <= 4'b1111;
		4'b1011 : gray_w2r_ptr <= 4'b1110;
		4'b1100 : gray_w2r_ptr <= 4'b1010;
		4'b1101 : gray_w2r_ptr <= 4'b1011;
		4'b1110 : gray_w2r_ptr <= 4'b1001;
		4'b1111 : gray_w2r_ptr <= 4'b1000;
		endcase
	 end
 end
 
 
 
assign wfull = ( (gray_w2r_ptr[3] != sync_r2w_ptr[3]) && (gray_w2r_ptr[2] != sync_r2w_ptr[2]) && (gray_w2r_ptr[1:0] == sync_r2w_ptr[1:0])) ;

endmodule 