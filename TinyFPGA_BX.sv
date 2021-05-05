module TinyFPGA_BX (
// 16MHz clock
  input CLK_16mhz,

// Left side of board
  inout PIN_1,
  inout PIN_2,
  inout PIN_3,
  inout PIN_4,
  inout PIN_5,
  inout PIN_6,
  inout PIN_7,
  inout PIN_8,
  inout PIN_9,
  inout PIN_10,
  inout PIN_11,
  inout PIN_12,
  inout PIN_13,

// Right side of board
  inout PIN_14,
  inout PIN_15,     //DIP1
  inout PIN_16,     //DIP2
  inout PIN_17,     //DIP3
  inout PIN_18,     //DIP4
  inout PIN_19,     //DIP5
  inout PIN_20,     //DIP6
  inout PIN_21,     //DIP7
  inout PIN_22,     //DIP8
  inout PIN_23,
  inout PIN_24,

// SPI flash interface on bottom of board
  inout SPI_SS,
  inout SPI_SCK,
  inout SPI_IO0,
  inout SPI_IO1,
  inout SPI_IO2,
  inout SPI_IO3,

// General purpose pins on bottom of board
  inout PIN_25,
  inout PIN_26,
  inout PIN_27,
  inout PIN_28,
  inout PIN_29,
  inout PIN_30,
  inout PIN_31,

// LED
  inout LED,

// USB
  /*inout USBP,
  inout USBN,*/
  output USBPU
);

  logic keyboard_data, keyboard_clock, hsync, vsync, VGA_pixel, CLK_VGA, CLK_CPU;
  logic SPI_CS, SPI_CLK, SPI_SO, SPI_SI;

  logic resetn, resetp, pll_locked, PIN_12_buff, PIN_13_buff;

  assign PIN_10 = hsync;
  assign PIN_11 = vsync;
  assign PIN_14 = VGA_pixel;
  assign PIN_8 = CLK_VGA;

  //assign keyboard_data = PIN_13;
  //assign keyboard_clock = PIN_12;

always_ff @ (posedge CLK_CPU) begin
  //klavesnice skrz dva flip flopy
  {keyboard_data, PIN_13_buff} <= {PIN_13_buff, PIN_13};

end

always_ff @ (posedge CLK_CPU) begin
  //klavesnice skrz dva flip flopy
  {keyboard_clock, PIN_12_buff} <= {PIN_12_buff, PIN_12};

end


  logic [7:0] DIP_switch;

  SB_IO #(
    .PIN_TYPE(6'b 0000_01),
    .PULLUP(1'b 1)
  ) DIP_input [7:0](
    .PACKAGE_PIN({PIN_15, PIN_16, PIN_17, PIN_18, PIN_19, PIN_20, PIN_21, PIN_22}),
    .D_IN_0(DIP_switch)
  );

  SB_IO #(
    .PIN_TYPE(6'b 0000_01),
    .PULLUP(1'b 1)
  ) button_input (
    .PACKAGE_PIN(PIN_24),
    .D_IN_0(debug_button)
  );

  /*logic flash_io0_oe, flash_io1_oe, flash_io2_oe, flash_io3_oe,
        flash_io0_do, flash_io1_do, flash_io2_do, flash_io3_do,
        flash_io0_di, flash_io1_di, flash_io2_di, flash_io3_di;*/

// deactivate USB
  assign USBPU = 1'b0;

  logic res0, res1, res2;
  assign resetn = !resetp;
  assign resetp = !(res0 & res1 & res2);

  logic sync_pipe1, sync_pipe2;
  logic r_debug_button_state, r_DIP1_state;
  logic r_last, r_debug_button_event;
  logic o_debounced_debug_button, o_debounced_DIP1;
  logic debug_button;


/*always_ff @ (posedge clk_div[6]) begin
	{ r_debug_button_state, sync_pipe1 }
		<= { sync_pipe1, debug_button };         //tlacitko skrz dva flip flopy
end


always_ff @ (posedge clk_div[6]) begin
	{ r_DIP1_state, sync_pipe2 }
		<= { sync_pipe2, DIP_switch[7] };         //DIP1 skrz dva flip flopy
end

  logic [7:0] timer;
  logic debug_button_prev;

always_ff @ (posedge clk_div[6]) begin
  debug_button_prev <= r_debug_button_state;

	if(!resetn) timer <= 8'h02;
  else begin
    if(r_debug_button_state != debug_button_prev) timer <= 8'hff;
    else timer <= timer - 1'b1;
  end
end

always_ff @ (posedge clk_div[6]) begin
	if (timer == 0) begin
		o_debounced_debug_button <= r_debug_button_state;
    o_debounced_DIP1 <= r_DIP1_state;
  end
end

always_ff @ (posedge clk_div[6]) begin
	r_last <= o_debounced_debug_button;
	r_debug_button_event <= (!o_debounced_debug_button)&&(r_last);
end

  logic stall_debug;

always_comb begin

  stall_debug = 0;

end

always_ff @ (posedge clk_div[6], negedge pll_locked) begin

  if(!pll_locked) begin
    res0 <= 0;
    res1 <= 0;
    res2 <= 0;
  end
  else if(clk_div[6]) begin
    res0 <= pll_locked;
    res1 <= res0;
    res2 <= res1;
  end

end

always_ff @ (posedge CLK_16mhz) begin

  if(CLK_16mhz) clk_div <= clk_div + 1;

  if(!resetn) begin

    if(clk_div[6]) CLK_CPU <= 1;
    else CLK_CPU <= 0;

  end
  else begin

    CLK_CPU <= r_debug_button_event;

  end




end*/


always_ff @ (posedge CLK_CPU) begin
	{ r_debug_button_state, sync_pipe1 }
		<= { sync_pipe1, debug_button };         //tlacitko skrz dva flip flopy
end


always_ff @ (posedge CLK_CPU) begin
	{ r_DIP1_state, sync_pipe2 }
		<= { sync_pipe2, DIP_switch[7] };         //DIP1 skrz dva flip flopy
end

  logic [13:0] timer;
  logic debug_button_prev;

always_ff @ (posedge CLK_CPU) begin
  debug_button_prev <= r_debug_button_state;

	if(!resetn) timer <= 14'h0002;
  else begin
    if(r_debug_button_state != debug_button_prev) timer <= 14'h3fff;
    else timer <= timer - 1'b1;
  end
end

always_ff @ (posedge CLK_CPU) begin
	if (timer == 0) begin
		o_debounced_debug_button <= r_debug_button_state;
    o_debounced_DIP1 <= r_DIP1_state;
  end
end

always_ff @ (posedge CLK_CPU) begin
	r_last <= o_debounced_debug_button;
	r_debug_button_event <= (!o_debounced_debug_button)&&(r_last);
end

  logic stall_debug;

always_comb begin

  if(o_debounced_DIP1) begin

      /*if(clk_div == 10'h3ff) stall_debug = 0;
      else stall_debug = 1;*/
      stall_debug = 0;

  end
  else stall_debug = !r_debug_button_event;

end

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

  logic [9:0] clk_div;

always_ff @ (posedge CLK_16mhz) begin

  if(CLK_16mhz) clk_div <= clk_div + 1;

  //if(clk_div[6]) CLK_CPU <= 1;
  //else CLK_CPU <= 0;

end

  assign CLK_CPU = CLK_16mhz;


  //PLL obvod generujici CLK pro VGA obvod, 40MHz
pll CLK_VGA_PLL(
        .clock_in(CLK_16mhz),
        .clock_out(CLK_VGA),
        .locked(pll_locked)
        );
  //PLL obvod generujici CLK pro VGA obvod, 40MHz

//AT25SF081 flash(SPI_SCK, SPI_SS, SPI_SI, SPI_IO3, SPI_IO2, SPI_SO);

  CPU RISC_V_CPU(
                .CLK_VGA(CLK_VGA),
                .CLK_CPU(CLK_CPU),
                .resetn(resetn),
                .resetp(resetp),
                .stall_debug(stall_debug),

                .keyboard_data(keyboard_data),
                .keyboard_clock(keyboard_clock),

                .hsync(hsync),
                .vsync(vsync),
                .VGA_pixel(VGA_pixel),

                .DIP_switch(DIP_switch),

                .SPI_CS(SPI_CS),      //SPI rozhrani
                .SPI_SCK(SPI_CLK),    //SPI rozhrani
                .SPI_SI(SPI_SI),
                .SPI_SO(SPI_SO)
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
  assign SPI_SS = SPI_CS;
  assign SPI_SCK = SPI_CLK;
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
