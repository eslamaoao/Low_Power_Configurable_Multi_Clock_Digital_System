module FIFO_RD #(parameter Pointer_Size = 4 ) 
(
input wire rinc,
input wire rclk,
input wire rrst_n,

input  wire [Pointer_Size-1:0] sync_w2r_ptr,

output reg  [Pointer_Size-1:0] gray_r2w_ptr,
output wire [Pointer_Size-2:0] raddr,
output wire rempty

);


reg [Pointer_Size-1:0] rptr ;
always@(posedge rclk or negedge rrst_n)
 begin
	if(!rrst_n)
	 begin
		rptr <= 'b0;
	 end
	else if (!rempty && rinc)
	 begin
		rptr <= rptr + 1 ;
	 end
 end
 
 
assign raddr = rptr [Pointer_Size-2:0] ;
 
 
 always@(posedge rclk or negedge rrst_n)
 begin
	if(!rrst_n)
	 begin
		gray_r2w_ptr <= 'b0;
	 end
	else 
	 begin
		case (rptr)
		4'b0000 : gray_r2w_ptr <= 4'b0000;
		4'b0001 : gray_r2w_ptr <= 4'b0001;
		4'b0010 : gray_r2w_ptr <= 4'b0011;
		4'b0011 : gray_r2w_ptr <= 4'b0010;
		4'b0100 : gray_r2w_ptr <= 4'b0110;
		4'b0101 : gray_r2w_ptr <= 4'b0111;
		4'b0110 : gray_r2w_ptr <= 4'b0101;
		4'b0111 : gray_r2w_ptr <= 4'b0100;
		4'b1000 : gray_r2w_ptr <= 4'b1100;
		4'b1001 : gray_r2w_ptr <= 4'b1101;
		4'b1010 : gray_r2w_ptr <= 4'b1111;
		4'b1011 : gray_r2w_ptr <= 4'b1110;
		4'b1100 : gray_r2w_ptr <= 4'b1010;
		4'b1101 : gray_r2w_ptr <= 4'b1011;
		4'b1110 : gray_r2w_ptr <= 4'b1001;
		4'b1111 : gray_r2w_ptr <= 4'b1000;
		endcase
	 end
 end
 
 
 
assign rempty = (sync_w2r_ptr  ==  gray_r2w_ptr ) ;

endmodule 