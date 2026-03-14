module RX_ClkDiv_MUX
(
input wire  [5:0]MUX_IN,
output reg  [7:0]MUX_OUT
);

always@(*)
 begin
	case (MUX_IN)
	6'd32: MUX_OUT = 8'd1;
	6'd16: MUX_OUT = 8'd2;
	6'd8 : MUX_OUT = 8'd4;
	default: MUX_OUT = 8'd2;
	endcase
 end
 
 endmodule
