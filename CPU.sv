module CPU(
  input logic keyboard_data, keyboard_clock,
  input logic CLK_VGA, CLK_CPU, reset,
  output logic hsync, vsync, VGA_pixel
  );

    logic memory_enable, cache_stall;
    logic [1:0] store_size;
    logic [31:0] nextPC, instr_fetch, mem_addr, write_data, read_data;

    logic [7:0] pressed_key;
    logic clean_key_buffer;

    logic video_write_enable;
    logic [7:0] video_write_data;
    logic [10:0] video_write_addr;

display_engine display_engine(
                              .CLK_CPU(CLK_CPU),
                              .CLK_VGA(CLK_VGA),
                              .reset(reset),
                              .video_write_enable(video_write_enable),
                              .video_write_data(video_write_data),
                              .video_write_addr(video_write_addr),
                              .VGA_pixel(VGA_pixel),
                              .hsync(hsync),
                              .vsync(vsync)
  );

  memory memory(
                .CLK_CPU(CLK_CPU),
                .mem_en(memory_enable),
                .store_size(store_size),
                .nextPC(nextPC),
                .mem_addr(mem_addr),
                .write_data(write_data),
                .pressed_key(pressed_key),
                .clean_key_buffer(clean_key_buffer),
                .video_write_enable(video_write_enable),
                .video_write_data(video_write_data),
                .video_write_addr(video_write_addr),
                .stall(cache_stall),
                .instr_fetch(instr_fetch),
                .read_data(read_data)
                );

core core(
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
