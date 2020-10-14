/*
Wrapper pro block ram pro ICE40 LP8K, viz. MemoryUsageGuideforiCE40Devices.pdf
256 adres, kazda po 16 bitech. Positive edge read, Positive edge write
*/
module RAM256x16(
  input RCLK_c, RCLKE_c, RE_c, WCLK_c, WCLKE_c, WE_c,
	input [7:0] RADDR_c, WADDR_c,
  input [15:0] MASK_IN, WDATA_IN,
	output [15:0] RDATA_OUT
);


SB_RAM256x16 RAM(
.RDATA(RDATA_OUT[15:0]),
.RADDR(RADDR_c[7:0]),
.RCLK(RCLK_c),
.RCLKE(RCLKE_c),
.RE(RE_c),
.WADDR(WADDR_c[7:0]),
.WCLK(WCLK_c),
.WCLKE(WCLKE_c),
.WDATA(WDATA_IN[15:0]),
.WE(WE_c),
.MASK(MASK_IN[15:0])
);


endmodule
