module DF_SYNC 
(
input  wire sync_Clk,sync_Rstn,
input  wire [3:0] un_sync_in,
output reg  [3:0] sync_out
);

reg  [1:0] sync_flipflop [3:0] ;

integer i;
integer j;

always@(posedge sync_Clk or negedge sync_Rstn)
 begin
	if(!sync_Rstn)
	 begin
		for( i = 0 ; i < 4 ; i = i+1 )
		 for( j = 0 ; j < 2 ; j = j+1 )
			sync_flipflop[i][j] <= 1'b0;
	 end
	else
	 begin
		for (i=0; i< 4; i=i+1)
		 sync_flipflop[i] <= {sync_flipflop[i][0],un_sync_in[i]};   
	 end  
 end


always @(*)
 begin
  for (i=0; i<4; i=i+1)
    sync_out[i] = sync_flipflop[i][1] ; 
 end  
		
		
		
 
 
 endmodule
 
 
 


 
