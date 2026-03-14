module ASYNIC_FIFO #(parameter FIFO_width = 16 ,parameter FIFO_depth = 8 ,parameter Pointer_Size = 4) 
(
input wire W_CLK,
input wire W_RST,
input wire W_INC,
input wire R_CLK,
input wire R_RST,
input wire R_INC,
input wire [FIFO_width-1:0 ] WR_DATA,

output wire FULL,
output wire [FIFO_width-1:0] RD_DATA,
output wire EMPTY

);


wire [2:0] w_addr_wire;
wire [2:0] r_addr_wire;



wire [3:0]sync_r2w_ptr_wire;
wire [3:0]gray_w2r_ptr_wire;



wire [3:0] sync_w2r_ptr_wire;
wire [3:0] gray_r2w_ptr_wire;



FIFO_MEM_CNTRL #(.FIFO_width(FIFO_width), .FIFO_depth(FIFO_depth), .Pointer_Size(Pointer_Size) ) U0
(
.w_data (WR_DATA),
.w_addr (w_addr_wire),
.r_addr (r_addr_wire),
.w_inc  (W_INC),
.w_full (FULL),
.wclk   (W_CLK),
.wrst_n (W_RST),
.r_data (RD_DATA)
);


FIFO_WR #(.Pointer_Size(Pointer_Size))  U1
(
.winc (W_INC),
.wclk (W_CLK),
.wrst_n (W_RST),
.sync_r2w_ptr (sync_r2w_ptr_wire),
.gray_w2r_ptr (gray_w2r_ptr_wire),
.waddr (w_addr_wire),
.wfull (FULL)
);


FIFO_RD #(.Pointer_Size(Pointer_Size)) U2
(
.rinc 			(R_INC),
.rclk 			(R_CLK),
.rrst_n 		(R_RST),
.sync_w2r_ptr 	(sync_w2r_ptr_wire),
.gray_r2w_ptr 	(gray_r2w_ptr_wire),
.raddr       	(r_addr_wire),
.rempty     	(EMPTY)
);


DF_SYNC Sync_r2w
(
.sync_Clk (W_CLK),
.sync_Rstn (W_RST),
.un_sync_in (gray_r2w_ptr_wire),
.sync_out (sync_r2w_ptr_wire)
);

DF_SYNC Sync_w2r
(
.sync_Clk (R_CLK),
.sync_Rstn (R_RST),
.un_sync_in (gray_w2r_ptr_wire),
.sync_out (sync_w2r_ptr_wire)
);



endmodule
