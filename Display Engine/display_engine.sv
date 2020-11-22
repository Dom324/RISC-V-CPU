module display_engine(
  input logic CLK_CPU, CLK_VGA, reset,

  input logic video_write_enable,
  input logic [7:0] video_write_data,
  input logic [10:0] video_write_addr,

  output logic VGA_pixel, hsync, vsync
);

  logic newData, end_of_line, end_of_frame;
  logic [7:0] ascii;
  logic [15:0] pixel_row;
  logic [4:0] line_number;
  logic [10:0] read_addr;


  always_ff @ (posedge CLK_VGA) begin

    //if(!reset) begin
      read_addr = read_addr;

      if(!end_of_frame) begin

        if(newData) read_addr++;

        if(end_of_line)
          if(line_number < 19) read_addr = read_addr - 50;

      end
      else read_addr = 0;
    //end
    //else read_addr = 0;
  end

vga vga(
        .CLK_VGA(CLK_VGA),
        .reset(reset),
        .pixel_row(pixel_row),
        .pixel(VGA_pixel),
        .h_sync(hsync),
        .v_sync(vsync),
        .newData(newData),
        .end_of_line(end_of_line),
        .end_of_frame(end_of_frame),
        .line_number(line_number)
        );

ascii_to_pixel ascii_to_pixel(
                              .ascii(ascii),
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
                        .WDATA(video_write_data),
                        .RDATA_OUT(ascii)
                        );

endmodule
