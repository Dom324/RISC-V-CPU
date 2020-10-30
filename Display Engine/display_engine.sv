module display_engine(
  input logic CLK_CPU, CLK_VGA,

  input logic video_write_enable,
  input logic [7:0] video_write_data,
  input logic [10:0] video_write_addr,

  output logic VGA_pixel, hsync, vsync
);

RAM1536x8 video_memory(
                        .RCLK_c(CLK_VGA),
                        .RCLKE_c(1),
                        .RE_c(1),
                        .WCLK_c(CLK_CPU),
                        .WCLKE_c(CLK_CPU),
                        .WE_c(video_write_enable),
                        .RADDR_c(),
                        .WADDR_c(video_write_addr),
                        .WDATA_IN(video_write_data),
                        .RDATA_OUT()
                        );

endmodule
