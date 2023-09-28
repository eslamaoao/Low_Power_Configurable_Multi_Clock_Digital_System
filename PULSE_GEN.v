module PULSE_GEN 
(
input wire RST,
input wire CLK,
input wire LVL_SIG,
output wire PULSE_SIG
);

reg Pulse_Gen, FF;

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    Pulse_Gen <= 1'b0 ;	
	FF <= 1'b0 ;	
   end
  else
   begin
    Pulse_Gen <= LVL_SIG   ;
	FF 		  <= Pulse_Gen ;
   end  
 end

 
assign PULSE_SIG = Pulse_Gen && !FF ;

endmodule