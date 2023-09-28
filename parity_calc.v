module parity_calc 
(
input wire [7:0] P_DATA,
input wire PAR_TYP,
input wire Data_Valid,
input wire busy,
input wire CLK,RST,

output reg par_bit 
);

wire temp;

reg  [7:0]   data_tmp ;


always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    data_tmp <= 'b0 ;
   end
  else if(Data_Valid && !busy)
   begin
    data_tmp <= P_DATA ;
   end 
 end
 
always@(posedge CLK or negedge RST)
 begin
	if (!RST)
		par_bit <= 1'b0;
	else if (Data_Valid)
		begin
			if (PAR_TYP)
				begin
					if(temp)
						par_bit <= 1'b0;
					else
						par_bit <= 1'b1;
				end
			else
				begin
					if(temp)
						par_bit <= 1'b1;
					else
						par_bit <= 1'b0;
				end
					
		end	
 end
		
assign temp = ^data_tmp;
endmodule
