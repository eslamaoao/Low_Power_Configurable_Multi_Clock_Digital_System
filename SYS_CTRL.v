module SYS_CTRL 
(

input wire [15:0] ALU_OUT,
input wire OUT_Valid,

input wire CLK,RST,

input wire [7:0] RdData ,
input wire RdData_Valid,
input wire [7:0] RX_P_DATA,
input wire RX_D_VLD,

input wire FIFO_FULL,

output reg [3:0] ALU_FUN ,
output reg EN ,
output reg CLK_EN,
output reg [3:0]Address,
output reg WrEn,
output reg RdEn,
output reg [7:0]WrData,

output reg [7:0] TX_P_DATA,
output reg TX_D_VLD
);



localparam [5:0]      	IDLE         	 	= 4'b0000,

						Wr_W8_FOR_addr   	= 4'b0001,
						Wr_W8_FOR_data	 	= 4'b0011,
						
						
						Rd_W8_FOR_addr   	= 4'b0010,
						Rd_Do_OPER		 	= 4'b0110,
						
						ALU_OP_W8_FOR_OP1   = 4'b0111, // op stand for operand
						ALU_OP_W8_FOR_OP2   = 4'b0101,
						ALU_OP_W8_FOR_FN    = 4'b0100,
						ALU_OP_DO_OPER		= 4'b1100,

						
						ALU_W8_FOR_FN   	= 4'b1101,
						
						FIFO_write_msb	   	= 4'b1111,
						finiss = 4'b1110;
					    
		   
reg    [3:0] current_state , next_state ;
		





	
always@(posedge CLK or negedge RST)
 begin
	if(!RST)
		begin
			current_state <= IDLE ;
		end
	else
		begin
			current_state <= next_state ;
		end
 end
 
 
 
always @(*)
 begin
	case(current_state)
	
	IDLE 				:	begin
								if(RX_D_VLD)
								 begin
									if(RX_P_DATA == 8'hAA)
										next_state = Wr_W8_FOR_addr;
									else if (RX_P_DATA == 8'hBB)
										next_state = Rd_W8_FOR_addr;
									else if (RX_P_DATA == 8'hCC)
										next_state = ALU_OP_W8_FOR_OP1;
									else if (RX_P_DATA == 8'hDD)
										next_state = ALU_W8_FOR_FN ;
									else 
										next_state= IDLE;
								 end
								else
									next_state = IDLE ;
							end
				
	Wr_W8_FOR_addr 		:   begin
								if(RX_D_VLD)
									next_state = Wr_W8_FOR_data;
								else
									next_state = Wr_W8_FOR_addr ;
							end
			
	Wr_W8_FOR_data		:   begin
								if(RX_D_VLD)
									next_state = IDLE;
								else
									next_state = Wr_W8_FOR_data ;
							end

	Rd_W8_FOR_addr 		:   begin
								if(RX_D_VLD)
									next_state =  Rd_Do_OPER ;    
								else
									next_state = Rd_W8_FOR_addr ;
							end 

	Rd_Do_OPER	 		:   begin
								//if(RdData_Valid)
									next_state = finiss ;
								//else
									//next_state = Rd_Do_OPER ;
							end 
							
	finiss	 			:   begin
								//if(RdData_Valid)
									next_state = IDLE ;
								//else
									//next_state = Rd_Do_OPER ;
							end 
							
	ALU_OP_W8_FOR_OP1 	:   begin
								if(RX_D_VLD)
									next_state = ALU_OP_W8_FOR_OP2;
								else
									next_state = ALU_OP_W8_FOR_OP1 ;
							end 
						
	ALU_OP_W8_FOR_OP2 	:   begin
								if(RX_D_VLD)
									next_state = ALU_OP_W8_FOR_FN;
								else
									next_state = ALU_OP_W8_FOR_OP2 ;
							end 
							
	ALU_OP_W8_FOR_FN 	:   begin
								if(RX_D_VLD)
									next_state = ALU_OP_DO_OPER;
								else
									next_state = ALU_OP_W8_FOR_FN ;
							end
							
	ALU_OP_DO_OPER 		:   begin
								next_state = FIFO_write_msb;
							end

							
	ALU_W8_FOR_FN		:	begin
								if(RX_D_VLD)
									next_state = ALU_OP_DO_OPER;
								else
									next_state = ALU_W8_FOR_FN ;
							end
							
	FIFO_write_msb		:	begin
								if(FIFO_FULL)
									next_state = FIFO_write_msb;
								else
									next_state = IDLE ;
							end
	
							
	default 			:   next_state = IDLE ;	
	endcase
 end


reg [3:0]tmp_addr ;
 
//////////////////////////////

always@(*)
 begin
TX_P_DATA		= 8'b0    ;
TX_D_VLD		= 1'b0	  ;		
ALU_FUN 		= 4'b0	  ; 
EN 				= 1'b0	  ;
CLK_EN  		= 1'b0	  ;
//Address 		= 4'b0	  ;
WrEn 			= 1'b0	  ;
RdEn			= 1'b0 	  ;
WrData  		= 8'b0	  ;
tmp_addr = 4'b0;




	

	case(current_state)
	
	IDLE 				:	begin
								ALU_FUN 	= 4'b0	  ; 
								EN 			= 1'b0	  ;
								CLK_EN  	= 1'b0	  ;
								tmp_addr 	= 4'b0 	  ;
								WrEn 		= 1'b0	  ;
								RdEn		= 1'b0 	  ;
								WrData  	= 8'b0	  ;
								TX_P_DATA 	= 8'b0	  ;
							end
			
    Wr_W8_FOR_addr 		:   begin
								// waiting for the adderesss :)))))
							end
		
	Wr_W8_FOR_data		:   begin
							tmp_addr = RX_P_DATA[3:0];	
								if(RX_D_VLD)
									begin
										WrData  = RX_P_DATA;
										WrEn    = 1'b1;
									end
								else
									begin
										WrEn    = 1'b0;
									end
							end

	Rd_W8_FOR_addr 		:   begin
								tmp_addr = RX_P_DATA[3:0];
							
							end 

	Rd_Do_OPER 			:   begin
								RdEn        = 1'b1;
								
								/*if(RdData_Valid)
									begin
										TX_D_VLD	= 1'b1	  ;
										TX_P_DATA = RdData  ;
									end
								else
									begin
										TX_D_VLD	= 1'b0	  ;
									end
								
								
									*/
								end 
	finiss	 			:   begin
								if(RdData_Valid)
									begin
										TX_D_VLD	= 1'b1	  ;
										TX_P_DATA = RdData  ;
									end
								else
									begin
										TX_D_VLD	= 1'b0	  ;
									end
							end 
							
	ALU_OP_W8_FOR_OP1 	:   begin
								tmp_addr = 4'b0000		;
								WrData  = RX_P_DATA	;
								WrEn    = 1'b1	;	
							end 
						
	ALU_OP_W8_FOR_OP2 	:   begin
								tmp_addr = 4'b0001		;
								WrData  = RX_P_DATA	;
								WrEn    = 1'b1	;
							end 
							
	ALU_OP_W8_FOR_FN 	:   begin
								if(RX_D_VLD)
									CLK_EN  	= 1'b1	  ;
								else
									CLK_EN  	= 1'b0	  ;
								EN 			= 1'b1	  ;
								ALU_FUN		= RX_P_DATA[3:0];
								
							end 
							
	ALU_OP_DO_OPER  	:   begin										
								ALU_FUN		= RX_P_DATA[3:0];
								EN 			= 1'b1	  ;
								CLK_EN  	= 1'b1	  ;
								TX_P_DATA	= ALU_OUT[7:0] ;
								TX_D_VLD	= 1'b1	  ;	
							end	
							
	ALU_W8_FOR_FN		:	begin
								if(RX_D_VLD)
									CLK_EN  	= 1'b1	  ;
								else
									CLK_EN  	= 1'b0	  ;
								
								EN 			= 1'b1	  ;
								ALU_FUN		= RX_P_DATA[3:0];
							end	

	FIFO_write_msb		:	begin
								TX_P_DATA	= ALU_OUT[15:8];
								TX_D_VLD	= 1'b1	  ;	
							end
								
							
	default 			:   begin
								TX_P_DATA		= 8'b0    ;
								TX_D_VLD		= 1'b0	  ;		
								ALU_FUN 		= 4'b0	  ; 
								EN 				= 1'b0	  ;
								CLK_EN  		= 1'b0	  ;
								WrEn 			= 1'b0	  ;
								RdEn			= 1'b0 	  ;
								WrData  		= 8'b0	  ;
								tmp_addr 		= 4'b0	  ;
								
								
							end 
	endcase
 end

always@(posedge CLK or negedge RST )
 begin
	if(!RST)
	 begin
		Address <= 4'b0;
	 end
	else
	 begin
		Address <= tmp_addr;
	 end
 end

endmodule
