module ClkDiv #(parameter ratio_width = 8 )
(
input wire i_ref_clk,
input wire i_rst_n,
input wire i_clk_en,
input wire [ratio_width-1 :0 ]i_div_ratio,
output reg o_div_clk
);
 
wire ClK_DIV_EN;
wire [ratio_width-2:0] half ;
wire [ratio_width-2:0] half_plus_one;
wire odd;
reg [ratio_width-2:0] count;
reg tmp_div_clk;
reg flag = 1'b0;

always@(posedge i_ref_clk or negedge i_rst_n)
 begin
	if(!i_rst_n)
		begin
			tmp_div_clk	 <= 1'b0;
			count   	 <=  'b0;
			flag         <= 1'b0;
		end
	else if (ClK_DIV_EN )
		begin
			if ((count == half) && (!odd))
				begin
					tmp_div_clk <= ! tmp_div_clk;
					count <= 'b0 ;
				end
			else if	(((!flag && (count == half)) || (flag && (count == half_plus_one))) && odd)
				begin
					tmp_div_clk <= ~ tmp_div_clk;
					count <= 'b0;
					flag <= !flag;
				end
			else
				count <= count + 1'b1 ;
		end
 end
 
//assign 	o_div_clk = tmp_div_clk;
	
always@ (*)
 begin
	if ( ClK_DIV_EN )
		o_div_clk = tmp_div_clk;
	else
		o_div_clk = i_ref_clk;
 end 
	

	
assign half = ((i_div_ratio >> 1) -1 );
assign half_plus_one = half+1 ;
assign odd = i_div_ratio[0];
assign ClK_DIV_EN = (i_clk_en && ( i_div_ratio != 'b0) && ( i_div_ratio != 'b1));
endmodule
