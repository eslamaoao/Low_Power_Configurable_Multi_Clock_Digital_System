
module DATA_SYNC # ( 
     parameter NUM_STAGES = 2 ,
	 parameter BUS_WIDTH = 8 
)(
input    wire                      CLK,
input    wire                      RST,
input    wire     [BUS_WIDTH-1:0]  unsync_bus,
input    wire                      bus_enable,
output   reg      [BUS_WIDTH-1:0]  sync_bus,
output   reg                       enable_pulse_d
);



//internal connections
reg   [NUM_STAGES-1:0]    sync_reg;
reg                       enable_flop ;
					 
wire                      enable_pulse ;

wire  [BUS_WIDTH-1:0]     sync_bus_c ;
					 
//----------------- Multi flop synchronizer --------------

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    sync_reg <= 'b0 ;
   end
  else
   begin
    sync_reg <= {sync_reg[NUM_STAGES-2:0],bus_enable};
   end  
 end
 

//----------------- pulse generator --------------------

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    enable_flop <= 1'b0 ;	
   end
  else
   begin
    enable_flop <= sync_reg[NUM_STAGES-1] ;
   end  
 end

 
assign enable_pulse = sync_reg[NUM_STAGES-1] && !enable_flop ;


//----------------- multiplexing --------------------

assign sync_bus_c =  enable_pulse ? unsync_bus : sync_bus ;  


//----------- destination domain flop ---------------

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    sync_bus <= 'b0 ;	
   end
  else
   begin
    sync_bus <= sync_bus_c ;
   end  
 end
 
//--------------- delay generated pulse ------------

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    enable_pulse_d <= 1'b0 ;	
   end
  else
   begin
    enable_pulse_d <= enable_pulse ;
   end  
 end
 

endmodule
/*module DATA_SYNC #(parameter BUS_WIDTH,NUM_STAGES)
	(
		input wire [BUS_WIDTH-1:0] unsync_bus,
		input wire bus_enable,


		input wire CLK,RST,

		output reg enable_pulse,
		output reg [BUS_WIDTH-1:0] sync_bus
	);
	
	
		
	wire Pulse_Gen;
	reg [NUM_STAGES-1:0] Multi_FlipFlop;
	reg flip;
	assign Pulse_Gen = ((~flip) & Multi_FlipFlop[NUM_STAGES-1]) ;
	integer i ;
	always@(posedge CLK or negedge RST)
	 begin
		if(!RST)
		 begin
			Multi_FlipFlop <= 'b0;
		 end
		else
		 begin
			Multi_FlipFlop[0] <= bus_enable;
			for(i = 0 ; i < (NUM_STAGES-1); i=i+1)
				Multi_FlipFlop[i+1] <= Multi_FlipFlop[i];
				
			flip <= Multi_FlipFlop[NUM_STAGES-1];
			enable_pulse <= ((~flip) & Multi_FlipFlop[NUM_STAGES-1] );
		 end
	 
		
	 end
	
	
	always@(posedge CLK or negedge RST)
	 begin
		if(!RST)
		 begin
			sync_bus <= 'b0;
		 end
		else
 		 begin
			if (Pulse_Gen)
			 begin
				sync_bus <= unsync_bus;
			 end
			else
			 begin
				sync_bus <= sync_bus ;
			 end
		 end
	 
		
	 end

endmodule
*/