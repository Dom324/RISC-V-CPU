/*
Wrapper pro block ram pro ICE40 LP8K, viz. MemoryUsageGuideforiCE40Devices.pdf
1536 adres, kazda po 8 bitech. Positive edge read, Positive edge write
*/
module RAM1536x8(
  input RCLK, RE, WCLK, WE,
	input [10:0] RADDR, WADDR,
  input [7:0] WDATA,
	output reg [7:0] RDATA_OUT
);

  reg RE_bank0, RE_bank1, RE_bank2, WE_bank0, WE_bank1, WE_bank2;
  wire [7:0] RDATA_bank0, RDATA_bank1, RDATA_bank2;

always @ (posedge RCLK) begin

  RE_bank0 = 0;
  RE_bank1 = 0;
  RE_bank2 = 0;
  RDATA_OUT = 0;

  if(RE == 1) begin
    if(RADDR[10:9] == 2'b00) begin      //cte se z bank0
      RE_bank0 = 1;
      RDATA_OUT = RDATA_bank0;
    end
    if(RADDR[10:9] == 2'b01) begin      //cte se z bank1
      RE_bank1 = 1;
      RDATA_OUT = RDATA_bank1;
    end
    if(RADDR[10:9] == 2'b10) begin      //cte se z bank2
      RE_bank2 = 1;
      RDATA_OUT = RDATA_bank2;
    end
  end
end

always @ (posedge WCLK) begin

  WE_bank0 = 0;
  WE_bank1 = 0;
  WE_bank2 = 0;

  if(WE == 1) begin
    if(WADDR[10:9] == 2'b00) begin      //cte se z bank0
      WE_bank0 = 1;
    end
    if(WADDR[10:9] == 2'b01) begin      //cte se z bank1
      WE_bank1 = 1;
    end
    if(WADDR[10:9] == 2'b10) begin      //cte se z bank2
      WE_bank2 = 1;
    end
  end
end

SB_RAM512x8 ram512X8_inst1 (
.RDATA(RDATA_bank0[7:0]),
.RADDR(RADDR[8:0]),
.RCLK(RCLK),
.RCLKE(RE_bank0),
.RE(RE_bank0),
.WADDR(WADDR[8:0]),
.WCLK(WCLK),
.WCLKE(WE_bank0),
.WDATA(WDATA[7:0]),
.WE(WE_bank0)
);

SB_RAM512x8 ram512X8_inst2 (
.RDATA(RDATA_bank1[7:0]),
.RADDR(RADDR[8:0]),
.RCLK(RCLK),
.RCLKE(RE_bank1),
.RE(RE_bank1),
.WADDR(WADDR[8:0]),
.WCLK(WCLK),
.WCLKE(WE_bank1),
.WDATA(WDATA[7:0]),
.WE(WE_bank1)
);

SB_RAM512x8 ram512X8_inst3 (
.RDATA(RDATA_bank2[7:0]),
.RADDR(RADDR[8:0]),
.RCLK(RCLK),
.RCLKE(RE_bank2),
.RE(RE_bank2),
.WADDR(WADDR[8:0]),
.WCLK(WCLK),
.WCLKE(WE_bank2),
.WDATA(WDATA[7:0]),
.WE(WE_bank2)
);

endmodule
