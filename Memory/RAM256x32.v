/*
Wrapper pro block ram pro ICE40 LP8K, viz. MemoryUsageGuideforiCE40Devices.pdf
256 adres, kazda po 32 bitech. Positive edge read, Positive edge write
FPGA rady ICE40 maji max 16 bitove bloky pameti, pro vytvoreni 32 bitoveho bloku jsou zapotrebi dva 16 bitove
*/
module RAM256x32(
  input RCLK_c, RCLKE_c, RE_c, WCLK_c, WCLKE_c, WE_c,
	input [7:0] RADDR_c, WADDR_c,
  input [31:0] MASK_IN, WDATA_IN,
	output [31:0] RDATA_OUT
);

  wire [15:0] MASK_low, MASK_high, WDATA_high, WDATA_low, RDATA_low, RDATA_high;

  assign RDATA_OUT [15:0] = RDATA_low;
  assign MASK_low = MASK_IN [15:0];
  assign WDATA_low = WDATA_IN [15:0];

  assign RDATA_OUT [31:16] = RDATA_high;
  assign MASK_high = MASK_IN [31:16];
  assign WDATA_high = WDATA_IN [31:16];


SB_RAM256x16 RAM_low(
.RDATA(RDATA_low[15:0]),
.RADDR(RADDR_c[7:0]),
.RCLK(RCLK_c),
.RCLKE(RCLKE_c),
.RE(RE_c),
.WADDR(WADDR_c[7:0]),
.WCLK(WCLK_c),
.WCLKE(WCLKE_c),
.WDATA(WDATA_low[15:0]),
.WE(WE_c),
.MASK(MASK_low[15:0])
);

SB_RAM256x16 RAM_high(
.RDATA(RDATA_high[15:0]),
.RADDR(RADDR_c[7:0]),
.RCLK(RCLK_c),
.RCLKE(RCLKE_c),
.RE(RE_c),
.WADDR(WADDR_c[7:0]),
.WCLK(WCLK_c),
.WCLKE(WCLKE_c),
.WDATA(WDATA_high[15:0]),
.WE(WE_c),
.MASK(MASK_high[15:0])
);

endmodule
