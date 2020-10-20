// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor

    input PIN_5, PIN_12, PIN_13,                //reset, keyboard data, keyboard clock
    output PIN_10, PIN_11, PIN_14, PIN_15,      //hsync, vsync, VGA pixel data, VGA clock

    USBN, USBP,
    SPI_SS, SPI_SCK, SPI_IO0, SPI_IO1, SPI_IO2, SPI_IO3,

    //nepouzite piny
    PIN_1, PIN_2, PIN_3, PIN_4, PIN_6, PIN_7, PIN_8, PIN_9,
    PIN_16, PIN_17, PIN_18, PIN_19, PIN_20, PIN_21, PIN_22, PIN_23,
    PIN_24, PIN_25, PIN_26, PIN_27, PIN_28, PIN_29, PIN_30, PIN_31
    //nepouzite piny
);

    // drive USB pull-up resistor to '0' to disable USB
      assign USBPU = 0;

    wire reset, keyboard_data, keyboard_clock, hsync, vsync, VGA_pixel, CLK_VGA;

    reset = PIN_5;
    keyboard_data = PIN_12;
    keyboard_clock = PIN_13,
    assign PIN_10 = hsync;
    assign PIN_11 = vsync;
    assign PIN_14 = VGA_pixel;
    assign PIN_15 = CLK_VGA;

    pll CLK_VGA_PLL(CLK, , clk_VGA, );				//PLL obvod generujici CLK pro VGA obvod, 40MHz





  //SOS blikani na signalizaci, ze se kod nahral spravne
    // keep track of time and location in blink_pattern
    reg [25:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b101010001110111011100010101;

    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end
    // light up the LED according to the pattern
    assign LED = blink_pattern[blink_counter[25:21]];
  //SOS blikani na signalizaci, ze se kod nahral spravne


    assign USBP = 1'bz;
    assign USBN = 1'bz;

    assign SPI_SS = 1'bz;
    assign SPI_SCK = 1'bz;
    assign SPI_IO0 = 1'bz;
    assign SPI_IO1 = 1'bz;
    assign SPI_IO2 = 1'bz;
    assign SPI_IO3 = 1'bz;

    assign PIN_1 = 1'bz;
    assign PIN_2 = 1'bz;
    assign PIN_3 = 1'bz;
    assign PIN_4 = 1'bz;
    assign PIN_6 = 1'bz;
    assign PIN_7 = 1'bz;
    assign PIN_8 = 1'bz;
    assign PIN_9 = 1'bz;
    assign PIN_16 = 1'bz;
    assign PIN_17 = 1'bz;
    assign PIN_18 = 1'bz;
    assign PIN_19 = 1'bz;
    assign PIN_20 = 1'bz;
    assign PIN_21 = 1'bz;
    assign PIN_22 = 1'bz;
    assign PIN_23 = 1'bz;
    assign PIN_24 = 1'bz;
    assign PIN_25 = 1'bz;
    assign PIN_26 = 1'bz;
    assign PIN_27 = 1'bz;
    assign PIN_28 = 1'bz;
    assign PIN_29 = 1'bz;
    assign PIN_30 = 1'bz;
    assign PIN_31 = 1'bz;
endmodule
