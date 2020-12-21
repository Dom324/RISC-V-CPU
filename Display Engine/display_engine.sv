module display_engine(
  input logic CLK_CPU, CLK_VGA, resetn,

  input logic video_write_enable,
  input logic [31:0] video_write_data,
  input logic [10:0] video_write_addr,

  output logic VGA_pixel, hsync, vsync
);

  logic newData, end_of_line, end_of_frame;
  logic [7:0] ascii, videopamet_read, znak, znak1, znak2, znak3, znak4, znak5, znak6, znak7, znak8;
  logic [15:0] pixel_row;
  logic [4:0] line_number;
  logic [10:0] read_addr;

  logic [10:0] horizontal_line;
  logic [9:0] vertical_line;


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

bin_to_hex_ascii one(video_write_data[31:28], znak1);
bin_to_hex_ascii two(video_write_data[27:24], znak2);
bin_to_hex_ascii three(video_write_data[23:20], znak3);
bin_to_hex_ascii four(video_write_data[19:16], znak4);
bin_to_hex_ascii five(video_write_data[15:12], znak5);
bin_to_hex_ascii six(video_write_data[11:8], znak6);
bin_to_hex_ascii seven(video_write_data[7:4], znak7);
bin_to_hex_ascii eight(video_write_data[3:0], znak8);

always_comb begin

  znak = videopamet_read;

  //if(vertical_line[9:5] == 0) begin
    if(horizontal_line[10:4] == 0) znak = znak1;
    else if(horizontal_line[10:4] == 1) znak = znak2;
    else if(horizontal_line[10:4] == 2) znak = znak3;
    else if(horizontal_line[10:4] == 3) znak = znak4;
    else if(horizontal_line[10:4] == 4) znak = znak5;
    else if(horizontal_line[10:4] == 5) znak = znak6;
    else if(horizontal_line[10:4] == 6) znak = znak7;
    else if(horizontal_line[10:4] == 7) znak = znak8;
    else znak = videopamet_read;
  //end


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

defparam video_memory.ram512X8_inst1.INIT_0 =
256'h00000000000000000000000000000000004b494e494d4f4400410041444e4f54;
defparam video_memory.ram512X8_inst2.INIT_0 =
256'h00000000000000000000000000000000000000000000000000000000ff000042;
defparam video_memory.ram512X8_inst3.INIT_0 =
256'h0000000000000000000000000000000000000000000000000000000000000043;

RAM1536x8 video_memory(
                        .RCLK(CLK_VGA),
                        .RE(1),
                        .WCLK(CLK_CPU),
                        .WE(video_write_enable),
                        .RADDR(read_addr),
                        .WADDR(video_write_addr),
                        .WDATA(video_write_data[7:0]),
                        .RDATA_OUT(videopamet_read)
                        );

endmodule