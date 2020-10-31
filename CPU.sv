module CPU(
  input keyboard_data, keyboard_clock,
  input CLK_VGA, CLK_CPU, reset,
  output hsync, vsync, VGA_pixel
  );

display_engine display_engine(
                              .CLK_CPU(CLK_CPU),
                              .CLK_VGA(CLK_VGA),
                              .video_write_enable(),
                              .video_write_data(),
                              .video_write_addr(),
                              .VGA_pixel(VGA_pixel),
                              .hsync(hsync),
                              .vsync(vsync)
  );

endmodule
