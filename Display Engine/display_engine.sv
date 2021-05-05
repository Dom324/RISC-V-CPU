module display_engine(
  input logic CLK_CPU, CLK_VGA, resetn,

  input logic video_write_enable,
  input logic [7:0] video_write_data,
  input logic [10:0] video_write_addr,

  input logic [7:0] DIP_switch,
  input logic [31:0] debug,

  output logic VGA_pixel, hsync, vsync
);

  logic newData, newData_reg, end_of_line, end_of_frame;
  logic [7:0] videopamet_read, znak, znak_debug;
  logic [15:0] pixel_row, pixel_row_reg;
  logic [4:0] line_number;
  logic [10:0] read_addr;

  logic [10:0] horizontal_line;
  logic [9:0] vertical_line;

  logic [3:0] debug_symbol;
  logic [31:0] debug_reg1, debug_reg2, debug_reg3;
  logic [7:0] DIP_switch_reg1, DIP_switch_reg2, DIP_switch_reg3;
  logic [2:0] counter;
  logic valid;


always_ff @ (posedge CLK_VGA) begin

  if(!end_of_frame) begin

    if(newData) read_addr <= read_addr + 1;

    if(end_of_line)
      if(line_number < 19) read_addr <= read_addr - 50;

  end
  else read_addr <= 0;
    //end
    //else read_addr = 0;
end

always_comb begin

  //if(counter == 3'b101) valid = 1;
  //else valid = 0;

end

always_ff @ (posedge CLK_CPU) begin

  if(counter == 3'b000) begin
    DIP_switch_reg1 <= DIP_switch;
    debug_reg1 <= debug;
  end

  counter <= counter + 1;

end

always_ff @ (posedge CLK_VGA) begin

  //if(valid == 1) begin
    DIP_switch_reg2 <= DIP_switch_reg1;
    DIP_switch_reg3 <= DIP_switch_reg2;

    debug_reg2 <= debug_reg1;
    debug_reg3 <= debug_reg2;
  //end

end

bin_to_hex_ascii one(debug_symbol, znak_debug);

always_comb begin
  if(horizontal_line[10:4] == 7'b0000000) debug_symbol = debug_reg3[31:28];
  else if(horizontal_line[10:4] == 7'b0000001) debug_symbol = debug_reg3[27:24];
  else if(horizontal_line[10:4] == 7'b0000010) debug_symbol = debug_reg3[23:20];
  else if(horizontal_line[10:4] == 7'b0000011) debug_symbol = debug_reg3[19:16];
  else if(horizontal_line[10:4] == 7'b0000100) debug_symbol = debug_reg3[15:12];
  else if(horizontal_line[10:4] == 7'b0000101) debug_symbol = debug_reg3[11:8];
  else if(horizontal_line[10:4] == 7'b0000110) debug_symbol = debug_reg3[7:4];
  else debug_symbol = debug_reg3[3:0];       //if(horizontal_line[10:4] == 7)
end

always_comb begin

  if(DIP_switch_reg3[6:0] == 7'b0000000) begin

    znak = videopamet_read;

  end else begin

    if( (horizontal_line[10:4] == 7'b0000000) ||
        (horizontal_line[10:4] == 7'b0000001) ||
        (horizontal_line[10:4] == 7'b0000010) ||
        (horizontal_line[10:4] == 7'b0000011) ||
        (horizontal_line[10:4] == 7'b0000100) ||
        (horizontal_line[10:4] == 7'b0000101) ||
        (horizontal_line[10:4] == 7'b0000110) ||
        (horizontal_line[10:4] == 7'b0000111) ) znak = znak_debug;
    else begin

      /*if(horizontal_line[4] == 1) znak = 8'hff;
      else znak = videopamet_read;*/

      znak = videopamet_read;

    end

  end

end

always_ff @ (posedge CLK_VGA) begin

  newData_reg <= newData;

  if(newData_reg) pixel_row_reg <= pixel_row;
  else pixel_row_reg <= pixel_row_reg;

end

vga vga(
        .CLK_VGA(CLK_VGA),
        .resetn(resetn),
        .pixel_row(pixel_row),
        .pixel(VGA_pixel),
        .h_sync(hsync),
        .v_sync(vsync),
        .newData(newData),
        .end_of_line(end_of_line),
        .end_of_frame(end_of_frame),
        .line_number(line_number),
        .horizontal_line(horizontal_line),
        .vertical_line(vertical_line)
        );

ascii_to_pixel ascii_to_pixel(
                              .ascii(znak),
                              .pixel_row(pixel_row),
                              .line_number(line_number)
                              );

/*defparam video_memory.ram512X8_inst1.INIT_0 =
256'h00000000000000000000000000000000004b494e494d4f4400410041444e4f54;
defparam video_memory.ram512X8_inst2.INIT_0 =
256'h00000000000000000000000000000000000000000000000000000000ff000042;
defparam video_memory.ram512X8_inst3.INIT_0 =
256'h0000000000000000000000000000000000000000000000000000000000000043;*/

RAM1536x8 video_memory(
                        .RCLK(CLK_VGA),
                        .RE(1'b1),
                        .WCLK(CLK_CPU),
                        .WE(video_write_enable),
                        .RADDR(read_addr),
                        .WADDR(video_write_addr),
                        .WDATA(video_write_data[7:0]),
                        .RDATA_OUT(videopamet_read)
                        );

endmodule
