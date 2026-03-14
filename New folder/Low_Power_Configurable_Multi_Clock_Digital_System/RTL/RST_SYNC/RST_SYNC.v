module RST_SYNC #(parameter NUM_STAGES=2)
(
input wire CLK,RST,
output reg SYNC_RST
);



reg [NUM_STAGES-1:0] Multi_FlipFlop;

integer i ;

//assign SYNC_RST = Multi_FlipFlop[NUM_STAGES-1];
always@(posedge CLK or negedge RST)
 begin
	if(!RST)
	 begin
		Multi_FlipFlop <= 'b0;
	 end
	else
	 begin
		Multi_FlipFlop[0] <= 1'b1;
		for(i=0; i< (NUM_STAGES-1); i = i+1)
			Multi_FlipFlop[i+1] <= Multi_FlipFlop [i] ;
		
		SYNC_RST <= Multi_FlipFlop[NUM_STAGES-1];
	 end
 end
 
endmodule