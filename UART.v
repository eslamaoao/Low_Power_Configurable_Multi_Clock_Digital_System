module UART 
(
input wire UART_RX_IN,
input wire [7:0] UART_Config,

input wire RX_CLK,TX_CLK,
input wire SYNC_RST_2,


input wire F_EMPTY,
input wire [7:0] RD_DATA,

output wire [7:0] UART_P_DATA,
output wire 	  UART_VALID,

output wire 	  UART_BUSY,
output wire 	  UART_TX_OUT,


output wire PAR_ERR,
output wire STP_ERR

);

UART_RX U0
(
.RX_IN 			(UART_RX_IN),
.PAR_EN 		(UART_Config[0]),
.PAR_TYP		(UART_Config[1]),
.Prescale 		(UART_Config[7:2]),
.CLK 			(RX_CLK),
.RST 			(SYNC_RST_2),
.P_DATA 		(UART_P_DATA),
.data_valid 	(UART_VALID),
.PAR_ERR 		(PAR_ERR),
.STP_ERR  		(STP_ERR)
);





UART_TX U1
(
.CLK 			(TX_CLK),
.P_DATA 		(RD_DATA),
.DATA_VALID 	(F_EMPTY),
.PAR_EN			(UART_Config[0]),
.PAR_TYP		(UART_Config[1]),
.RST 			(SYNC_RST_2),
.TX_OUT 		(UART_TX_OUT),
.busy   		(UART_BUSY)

);

endmodule