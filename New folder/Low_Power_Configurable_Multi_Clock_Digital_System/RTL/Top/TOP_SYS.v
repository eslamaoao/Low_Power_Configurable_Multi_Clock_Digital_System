module TOP_SYS #(
parameter ratio_width = 8,
parameter NUM_STAGES=2,
parameter BUS_WIDTH = 8,
parameter Reg_Width=8,
parameter Reg_Depth=8,
parameter Reg_ADDR=4,
parameter OPER_WIDTH=8,
parameter OUT_WIDTH = OPER_WIDTH*2,
parameter FIFO_width = 8,
parameter FIFO_depth = 8,
parameter Pointer_Size= 4 
)
(
input wire RX_IN,
input wire REF_CLK,
input wire RST,
input wire UART_CLK,
output wire TX_OUT

);

wire [7:0] UART_Config_wire;
wire [7:0] RD_DATA_wire;



wire [7:0] UART_P_DATA_wire;
wire [7:0] Sync_Data_Wire;
wire UART_VALID_wire;
wire enable_pulse_wire;



wire [7:0] prescale_Wire;

wire SYNC_RST_2_wire;
wire SYNC_RST_1_wire;

wire Rx_CLK_wire; 
wire Tx_CLK_wire; 

wire UART_BUSY_wire;
wire RD_INC_wire;



wire F_EMPTY_wire ;
wire Not_F_EMPTY_wire;

wire PAR_ERR_wire;
wire STP_ERR_wire;



// clock gating //
wire CLK_EN_Wire;


////////////////////////////////////
/////////// alu control wires //////

wire EN_Wire;

wire [3:0] ALU_FUN_Wire;
wire [7:0]REG0_wire;
wire [7:0]REG1_wire;
wire [7:0]REG2_wire;
wire [7:0]REG3_wire;

////////////////////
////////////////////



wire ALU_Clk;


///////////////////////////////////
/////////// sys_control_wires//////

wire WrEn_wire;
wire RdEn_wire;
wire RdData_VLD_wire;
wire W_INC_wire;
wire OUT_Valid_Wire;
wire FIFO_FULL_wire;
wire [3:0] Address_wire;
wire [7:0] WrData_wire;
wire [7:0] RdData_wire;
wire [7:0] WR_DATA_wire;

wire [15:0] ALU_OUT_Wire;

//////////////////////////
///////////////////////////


SYS_CTRL V4
(
.ALU_OUT (ALU_OUT_Wire),
.OUT_Valid (OUT_Valid_Wire),
.CLK	(REF_CLK),
.RST 	(SYNC_RST_1_wire),
.RdData (RdData_wire),
.RdData_Valid (RdData_VLD_wire),
.RX_P_DATA		(Sync_Data_Wire),
.ALU_FUN 	(ALU_FUN_Wire),
.EN  	(EN_Wire),
.CLK_EN (CLK_EN_Wire),
.Address (Address_wire),
.WrEn	(WrEn_wire),
.RdEn 	(RdEn_wire),
.WrData (WrData_wire),
.TX_P_DATA	(WR_DATA_wire),
.RX_D_VLD 	(enable_pulse_wire),
.TX_D_VLD	(W_INC_wire),
.FIFO_FULL  (FIFO_FULL_wire)
);

ALU #(.OPER_WIDTH(OPER_WIDTH),.OUT_WIDTH(OUT_WIDTH)) V6

(
.A (REG0_wire),
.B (REG1_wire),
.EN (EN_Wire),
.ALU_FUN (ALU_FUN_Wire),
.CLK (ALU_Clk),
.RST (SYNC_RST_1_wire),
.ALU_OUT (ALU_OUT_Wire),
.OUT_VALID  (OUT_Valid_Wire)
);

CLK_GATE v7
(
.CLK_EN (CLK_EN_Wire),
.CLK 	(REF_CLK),
.GATED_CLK (ALU_Clk)
);







RegFile #(.WIDTH(Reg_Width),.DEPTH(Reg_Depth),.ADDR(Reg_ADDR)) V5
(
.CLK (REF_CLK),
.RST (SYNC_RST_1_wire),
.WrEn (WrEn_wire),
.RdEn (RdEn_wire),
.Address (Address_wire),
.WrData (WrData_wire),
.RdData (RdData_wire),
.RdData_VLD (RdData_VLD_wire),
.REG0  	(REG0_wire),
.REG1	(REG1_wire),
.REG2	(UART_Config_wire),
.REG3	(REG3_wire)
);


ASYNIC_FIFO #(.FIFO_width(FIFO_width),.FIFO_depth(FIFO_depth),.Pointer_Size (Pointer_Size) ) V8
(
.W_CLK (REF_CLK),
.W_RST (SYNC_RST_1_wire),
.W_INC (W_INC_wire),
.R_CLK (Tx_CLK_wire),
.R_RST (SYNC_RST_2_wire),
.R_INC (RD_INC_wire),
.WR_DATA(WR_DATA_wire),
.FULL (FIFO_FULL_wire),
.RD_DATA (RD_DATA_wire),
.EMPTY   (F_EMPTY_wire)
);

INV V9
( 
.IN (F_EMPTY_wire),
.OUT (Not_F_EMPTY_wire)
);

UART V0
(
.UART_RX_IN (RX_IN),
.UART_Config (UART_Config_wire),
.RX_CLK (Rx_CLK_wire),
.TX_CLK (Tx_CLK_wire),
.SYNC_RST_2 (SYNC_RST_2_wire),
.F_EMPTY (Not_F_EMPTY_wire),
.RD_DATA (RD_DATA_wire),
.UART_P_DATA ( UART_P_DATA_wire),
.UART_VALID  (UART_VALID_wire ),
.UART_BUSY   (UART_BUSY_wire),
.UART_TX_OUT (TX_OUT),
.PAR_ERR (PAR_ERR_wire),
.STP_ERR (STP_ERR_wire)
);

DATA_SYNC # (.NUM_STAGES(NUM_STAGES), .BUS_WIDTH(BUS_WIDTH)) V3
(
.CLK 				(REF_CLK),
.RST 				(SYNC_RST_1_wire),
.unsync_bus 		(UART_P_DATA_wire),
.bus_enable 		(UART_VALID_wire),
.sync_bus  			(Sync_Data_Wire),
.enable_pulse_d		(enable_pulse_wire)
);



ClkDiv #(.ratio_width(ratio_width)) DivClk_RX
(
.i_ref_clk (UART_CLK),
.i_rst_n (SYNC_RST_2_wire),
.i_clk_en (1'b1),
.i_div_ratio (prescale_Wire),
.o_div_clk (Rx_CLK_wire)
);

ClkDiv #(.ratio_width(ratio_width)) DivClk_TX
(
.i_ref_clk (UART_CLK),
.i_rst_n (SYNC_RST_2_wire),
.i_clk_en (1'b1),
.i_div_ratio (REG3_wire),
.o_div_clk (Tx_CLK_wire)
);


RX_ClkDiv_MUX V2
(
.MUX_IN  (UART_Config_wire[7:2]),
.MUX_OUT (prescale_Wire)
);



RST_SYNC #(.NUM_STAGES(NUM_STAGES)) RST_SYNC_2
(
.CLK (UART_CLK),
.RST (RST),
.SYNC_RST (SYNC_RST_2_wire)
);

RST_SYNC #(.NUM_STAGES(NUM_STAGES)) RST_SYNC_1
(
.CLK (REF_CLK),
.RST (RST),
.SYNC_RST (SYNC_RST_1_wire)
);


PULSE_GEN V1
(
.RST (SYNC_RST_2_wire),
.CLK (Tx_CLK_wire),
.LVL_SIG (UART_BUSY_wire),
.PULSE_SIG (RD_INC_wire)
);





endmodule
