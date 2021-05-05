module TinyFPGA_BX (
// 16MHz clock
  input CLK_16mhz,

// Left side of board
  /*inout PIN_1,
  inout PIN_2,
  inout PIN_3,
  inout PIN_4,
  inout PIN_5,
  inout PIN_6,
  inout PIN_7,
  inout PIN_8,
  inout PIN_9,*/
  inout PIN_10,
  inout PIN_11,
  inout PIN_12,
  inout PIN_13,

// Right side of board
  inout PIN_14,
  inout PIN_15,
  /*inout PIN_16,
  inout PIN_17,
  inout PIN_18,
  inout PIN_19,
  inout PIN_20,
  inout PIN_21,
  inout PIN_22,
  inout PIN_23,
  inout PIN_24,*/

// SPI flash interface on bottom of board
  inout SPI_SS,
  inout SPI_SCK,
  inout SPI_IO0,
  inout SPI_IO1,
  inout SPI_IO2,
  inout SPI_IO3,

// General purpose pins on bottom of board
  /*inout PIN_25,
  inout PIN_26,
  inout PIN_27,
  inout PIN_28,
  inout PIN_29,
  inout PIN_30,
  inout PIN_31,*/

// LED
  inout LED,

// USB
  /*inout USBP,
  inout USBN,*/
  output USBPU
);

  logic keyboard_data, keyboard_clock, hsync, vsync, VGA_pixel, CLK_VGA, CLK_CPU;
  logic [26:0] clk_div;

  logic resetn, resetp, pll_locked;

  assign keyboard_data = PIN_12;
  assign keyboard_clock = PIN_13;
  assign PIN_10 = hsync;
  assign PIN_11 = vsync;
  assign PIN_14 = VGA_pixel;
  assign PIN_15 = CLK_VGA;

  /*logic flash_io0_oe, flash_io1_oe, flash_io2_oe, flash_io3_oe,
        flash_io0_do, flash_io1_do, flash_io2_do, flash_io3_do,
        flash_io0_di, flash_io1_di, flash_io2_di, flash_io3_di;*/

// deactivate USB
  assign USBPU = 1'b0;

  logic res0, res1, res2;
  assign resetn = !resetp;
  assign resetp = !(res0 & res1 & res2);

always_ff @ (posedge CLK_CPU, negedge pll_locked) begin

  if(!pll_locked) begin
    res0 <= 0;
    res1 <= 0;
    res2 <= 0;
  end
  else if(CLK_CPU) begin
    res0 <= pll_locked;
    res1 <= res0;
    res2 <= res1;
  end

end

always_ff @ (posedge CLK_16mhz) begin

  if(CLK_16mhz) clk_div <= clk_div + 1;

  if(clk_div[19]) CLK_CPU <= 1;
  else CLK_CPU <= 0;

end

  /*SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({SPI_IO0, SPI_IO1, SPI_IO2, SPI_IO3}),
		.OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
		.D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);*/

  //PLL obvod generujici CLK pro VGA obvod, 40MHz
pll CLK_VGA_PLL(
        .clock_in(CLK_16mhz),
        .clock_out(CLK_VGA),
        .locked(pll_locked)
        );
  //PLL obvod generujici CLK pro VGA obvod, 40MHz

AT25SF081 flash(SPI_SCK, SPI_SS, SPI_SI, SPI_IO3, SPI_IO2, SPI_SO);

  CPU RISC_V_CPU(
                .CLK_VGA(CLK_VGA),
                .CLK_CPU(CLK_CPU),
                .resetn(resetn),
                .resetp(resetp),

                .keyboard_data(keyboard_data),
                .keyboard_clock(keyboard_clock),

                .hsync(hsync),
                .vsync(vsync),
                .VGA_pixel(VGA_pixel),

                .SPI_CS(SPI_SS),      //SPI rozhrani
                .SPI_SCK(SPI_SCK),    //SPI rozhrani
                .SPI_SI(SPI_SI),
                .SPI_SO(SPI_SO),
                /*.flash_io0_oe(flash_io0_oe),
                .flash_io1_oe(flash_io1_oe),
                .flash_io2_oe(flash_io2_oe),
                .flash_io3_oe(flash_io3_oe),

                .flash_io0_do(flash_io0_do),
                .flash_io1_do(flash_io1_do),
                .flash_io2_do(flash_io2_do),
                .flash_io3_do(flash_io3_do),

                .flash_io0_di(flash_io0_di),
                .flash_io1_di(flash_io1_di),
                .flash_io2_di(flash_io2_di),
                .flash_io3_di(flash_io3_di)*/

                .stall_debug(1'b0),
                .DIP_switch(8'h00)
                );


//SOS blikani na signalizaci, ze se kod nahral spravne
  // keep track of time and location in blink_pattern

  // pattern that will be flashed over the LED over time
  wire [31:0] blink_pattern = 32'b101010001110111011100010101;

  // increment the blink_counter every clock

  // light up the LED according to the pattern
  //assign LED = blink_pattern[blink_counter[25:21]];
  assign LED = CLK_CPU;
//SOS blikani na signalizaci, ze se kod nahral spravne





// Left side of board
  assign PIN_1 = 1'bz;
  assign PIN_2 = 1'bz;
  assign PIN_3 = 1'bz;
  assign PIN_4 = 1'bz;
  //assign PIN_5 = 1'bz;
  assign PIN_6 = 1'bz;
  assign PIN_7 = 1'bz;
  assign PIN_8 = 1'bz;
  assign PIN_9 = 1'bz;
  assign PIN_10 = 1'bz;
  assign PIN_11 = 1'bz;
  assign PIN_12 = 1'bz;
  assign PIN_13 = 1'bz;

// Right side of board
  /*assign PIN_14 = 1'bz;
  assign PIN_15 = 1'bz;
  assign PIN_16 = 1'bz;
  assign PIN_17 = 1'bz;
  assign PIN_18 = 1'bz;
  assign PIN_19 = 1'bz;
  assign PIN_20 = 1'bz;
  assign PIN_21 = 1'bz;
  assign PIN_22 = 1'bz;
  assign PIN_23 = 1'bz;*/
  assign PIN_24 = 1'bz;

// SPI flash interface on bottom of board
  //assign SPI_SS = 1'bz;
  //assign SPI_SCK = 1'bz;
  assign SPI_IO0 = SPI_SI;
  assign SPI_SO = SPI_IO1;
  assign SPI_IO2 = 1'b1;
  assign SPI_IO3 = 1'b1;

// General purpose pins on bottom of board
  assign PIN_25 = 1'bz;
  assign PIN_26 = 1'bz;
  assign PIN_27 = 1'bz;
  assign PIN_28 = 1'bz;
  assign PIN_29 = 1'bz;
  assign PIN_30 = 1'bz;
  assign PIN_31 = 1'bz;



endmodule
