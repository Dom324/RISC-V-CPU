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
  inout PIN_15,
  inout PIN_16,
  inout PIN_17,
  inout PIN_18,
  inout PIN_19,
  inout PIN_20,
  inout PIN_21,
  inout PIN_22,
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
  inout USBP,
  inout USBN,
  output USBPU
);

// deactivate USB
assign USBPU = 1'b0;

  wire keyboard_data, keyboard_clock, hsync, vsync, VGA_pixel, CLK_VGA;
  logic reset, power_up;

  assign reset = PIN_5;
  assign keyboard_data = PIN_12;
  assign keyboard_clock = PIN_13;
  assign PIN_10 = hsync;
  assign PIN_11 = vsync;
  assign PIN_14 = VGA_pixel;
  assign PIN_15 = CLK_VGA;

  logic locked, CLK_CPU;
  logic [12:0] CLK_DIV2;


  /*assign PIN_16 = nextPC[7];
  assign PIN_17 = nextPC[6];
  assign PIN_18 = nextPC[5];
  assign PIN_19 = nextPC[4];
  assign PIN_20 = nextPC[3];
  assign PIN_21 = nextPC[2];
  assign PIN_22 = nextPC[1];
  assign PIN_23 = nextPC[0];*/

  always_ff @ (posedge CLK_16mhz) begin
    CLK_DIV2++;
  end
  assign CLK_CPU = CLK_DIV2[12];

  //PLL obvod generujici CLK pro VGA obvod, 40MHz
  /*pll CLK_VGA_PLL(
                  .REFERENCECLK(CLK_16mhz),
                  .PLLOUTCORE(),
                  .PLLOUTGLOBAL(CLK_VGA),
                  .RESET(0)
                  );*/

pll2 CLK_VGA_PLL(
        .clock_in(CLK_16mhz),
        .clock_out(CLK_VGA),
        .locked(locked)
        );
  //PLL obvod generujici CLK pro VGA obvod, 40MHz


  CPU RISC_V_CPU(
                .keyboard_data(keyboard_data),
                .keyboard_clock(keyboard_clock),
                .CLK_VGA(CLK_VGA),
                .CLK_CPU(CLK_CPU),
                .hsync(hsync),
                .vsync(vsync),
                .VGA_pixel(VGA_pixel),
                .reset(reset)
                );



//SOS blikani na signalizaci, ze se kod nahral spravne
  // keep track of time and location in blink_pattern
  reg [25:0] blink_counter;

  // pattern that will be flashed over the LED over time
  wire [31:0] blink_pattern = 32'b101010001110111011100010101;

  // increment the blink_counter every clock
  always @(posedge CLK_CPU) begin
      blink_counter <= blink_counter + 1;
  end
  // light up the LED according to the pattern
  assign LED = blink_pattern[blink_counter[25:21]];
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
  assign SPI_SS = 1'bz;
  assign SPI_SCK = 1'bz;
  assign SPI_IO0 = 1'bz;
  assign SPI_IO1 = 1'bz;
  assign SPI_IO2 = 1'bz;
  assign SPI_IO3 = 1'bz;

// General purpose pins on bottom of board
  assign PIN_25 = 1'bz;
  assign PIN_26 = 1'bz;
  assign PIN_27 = 1'bz;
  assign PIN_28 = 1'bz;
  assign PIN_29 = 1'bz;
  assign PIN_30 = 1'bz;
  assign PIN_31 = 1'bz;



endmodule
