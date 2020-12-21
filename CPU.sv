module CPU(
  input logic CLK_VGA, CLK_CPU, resetp, resetn,

  input logic keyboard_data, keyboard_clock,

  output logic hsync, vsync, VGA_pixel,

  //SPI rozhrani
  output logic SPI_CS, SPI_SCK, SPI_SI,
  input logic SPI_SO,

  /*output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input flash_io0_di,
	input flash_io1_di,
	input flash_io2_di,*/
	input logic flash_io3_di
  );

    logic memory_enable, cache_stall;
    logic [1:0] store_size;
    logic [31:0] nextPC, instr_fetch, mem_addr, write_data, read_data;

    logic [7:0] pressed_key;
    logic clean_key_buffer;

    logic video_write_enable;
    logic [31:0] video_write_data;
    logic [10:0] video_write_addr;

display_engine display_engine(
                              .CLK_CPU(CLK_CPU),
                              .CLK_VGA(CLK_VGA),
                              .resetn(resetn),
                              .video_write_enable(video_write_enable),
                              .video_write_data(video_write_data),
                              .video_write_addr(video_write_addr),
                              .VGA_pixel(VGA_pixel),
                              .hsync(hsync),
                              .vsync(vsync)
  );

  memory memory(
                .CLK_CPU(CLK_CPU),
                .resetn(resetn),
                .resetp(resetp),

                .pressed_key(pressed_key),
                .clean_key_buffer(clean_key_buffer),

                .video_write_enable(video_write_enable),
                .video_write_data(video_write_data),
                .video_write_addr(video_write_addr),

                .mem_en(memory_enable),
                .store_size(store_size),
                .nextPC(nextPC),
                .mem_addr(mem_addr),
                .write_data(write_data),
                .stall(cache_stall),
                .instr_fetch(instr_fetch),

                .read_data(read_data),
                .SPI_CS(SPI_CS),
                .SPI_SCK(SPI_SCK),
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

core core(
          .resetn(resetn),
          .CLK(CLK_CPU),
          .stall_mem(cache_stall),
          .instr_fetch(instr_fetch),
          .mem_read_data(read_data),
          .memory_en(memory_enable),
          .store_size(store_size),
          .nextPC(nextPC),
          .mem_write_data(write_data),
          .mem_addr(mem_addr)
          );

keyboard keyboard(
                .CLK(CLK_CPU),
                .keyboard_data(keyboard_data),
                .keyboard_clock(keyboard_clock),
                .clean_key_buffer(clean_key_buffer),
                .pressed_key(pressed_key)
                );

endmodule
