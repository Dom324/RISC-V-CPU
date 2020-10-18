// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    output USBPU,  // USB pull-up resistor
    output LED,
    input CLK, PIN_5, PIN_13, PIN_12,
    output PIN_6, PIN_10, PIN_11, PIN_14, PIN_15, PIN_7, PIN_24, PIN_23, PIN_22, PIN_21, PIN_20, PIN_19, PIN_18, PIN_17
);

localparam shift_left = 32;			//shift_left

wire clk_VGA, reset, hsync, vsync, pixel_out, end_of_line, end_of_frame, keyboard_clk, keyboard_data;
wire [15:0] pixel_data;
wire [9:0] vertical;
wire [10:0] horizontal;
reg [7:0] asci, scan_code_buffer;
wire is_valid;
wire [7:0] scan_code;
reg [7:0] scan_code2, scan_code3;

assign keyboard_clk = PIN_13;
assign keyboard_data = PIN_12;

assign PIN_10 = hsync;
assign PIN_11 = vsync;
assign reset = PIN_5;

assign PIN_7 = clk_VGA;
assign PIN_6 = pixel_out;         //obraz pouze pokud jsme v tisknutelne zone
assign PIN_15 = clk_VGA;
assign PIN_14 = pixel_out;         //obraz pouze pokud jsme v tisknutelne zone


assign PIN_24 = scan_code_buffer[7];
assign PIN_23 = scan_code_buffer[6];
assign PIN_22 = scan_code_buffer[5];
assign PIN_21 = scan_code_buffer[4];
assign PIN_20 = scan_code_buffer[3];
assign PIN_19 = scan_code_buffer[2];
assign PIN_18 = scan_code_buffer[1];
assign PIN_17 = scan_code_buffer[0];

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [25:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b101010001110111011100010101;

    // increment the blink_counter every clock
    always @(posedge clk_VGA) begin
        blink_counter <= blink_counter + 1;
    end

    // light up the LED according to the pattern
    assign LED = blink_pattern[blink_counter[25:21]];


    ps2_interface2 ps2 (CLK, keyboard_clk, keyboard_data, is_valid, scan_code,);
    always @ (posedge CLK) begin
      if(is_valid) if((scan_code !== 8'hf0) & (scan_code !== 8'h00)) scan_code_buffer = scan_code;
      end

scancode_to_ascii keyboard_decode(scan_code_buffer, asci);

    pll core_clock(CLK, , clk_VGA, PIN_5);				//PLL obvod generujici clk pro jadro procesoru
    vga vga_output(clk_VGA, reset, pixel_data, pixel_out, hsync, vsync, , end_of_line, end_of_frame, horizontal, vertical);	//vystup na VGA, hsync, vsync
    ascii_to_pixel ascii(reset, end_of_line, end_of_frame, asci, pixel_data);

    /*always begin
      if((vertical > 280) && (vertical <= 300)) begin
        if((horizontal >= 400 - shift_left) && (horizontal < 416 - shift_left)) asci = scan_code_buffer1high;
        else if((horizontal >= 416 - shift_left) && (horizontal < 432 - shift_left)) asci[7:0] = scan_code_buffer1low;
        else asci[7:0] = 0;
      end
      if((vertical > 300) && (vertical <= 320)) begin
        if((horizontal >= 400 - shift_left) && (horizontal < 416 - shift_left)) asci = scan_code_buffer2high;
        else if((horizontal >= 416 - shift_left) && (horizontal < 432 - shift_left)) asci[7:0] = scan_code_buffer2low;
        else asci[7:0] = 0;
      end
      if((vertical > 320) && (vertical <= 340)) begin
        if((horizontal >= 400 - shift_left) && (horizontal < 416 - shift_left)) asci = scan_code_buffer3high;
        else if((horizontal >= 416 - shift_left) && (horizontal < 432 - shift_left)) asci[7:0] = scan_code_buffer3low;
        else asci[7:0] = 0;
      end
      if((vertical > 340) && (vertical <= 360)) begin
        if((horizontal >= 400 - shift_left) && (horizontal < 416 - shift_left)) asci = scan_code_buffer4high;
        else if((horizontal >= 416 - shift_left) && (horizontal < 432 - shift_left)) asci[7:0] = scan_code_buffer4low;
        else asci[7:0] = 0;
      end
      else asci[7:0] = 0;
    end*/
endmodule
