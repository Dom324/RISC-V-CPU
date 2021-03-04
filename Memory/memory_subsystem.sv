/*
Mapa pametovych adres:
    programova pamet - adresy 0x00000000 az 0x000AEFFF (~0.7MB)
    pamet pro promene - adresy 0x000AF000 az 0x000AFFFF
    videopamet - adresy 0xF0000000 az 0xF00005DC (1500B)
    Look Up Table (LUT) pro znaky definovane programem - zatim neexistuje
    zmacknuta klavesa - adresa 0xFFFFFFFF (1B)


	adresa[31:0]:
		adresa[1:0] - adresy instrukci jsou (mely by byt) vzdy zarovnany na hranici 4B. Tzn. spodni dva bity adresy by vzdy mely byt 00, lze je tedy ignorovat
		adresa[9:2] - 8 bitu pouzito jako adresa pameti cache
		adresa[19:10] - 10 bitu pouzito jako tag
		adresa[31:20] - hornich 12 bitu adresy ignorovano
	Celkem tedy 20 (19:0) adresnich bitu, coz umoznuje adresovat 2^20 Bytu pameti - 1MB

Do videopameti zatim lze zapisovat jen po 8 bitech
*/
module memory(
    input logic CLK_CPU, resetn, resetp,

    input logic mem_en, fetch_enable,
    input logic [1:0] store_size,
    input logic [31:0] nextPC, mem_addr, write_data,
    output logic fetch_valid, read_data_valid, write_ready,
    output logic [31:0] instr_fetch, mem_read_data,

    //klavesnice
    input logic [7:0] pressed_key,
    input logic keyboard_valid,
    output logic clean_key_buffer,
    //klavesnice

    //videopamet
    output logic video_write_enable,
    output logic [7:0] video_write_data,
    output logic [10:0] video_write_addr,
    //videopamet

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

  	input  flash_io0_di,
  	input  flash_io1_di,
  	input  flash_io2_di,
  	input logic flash_io3_di*/

    input logic [7:0] DIP_switch,
    output logic [31:0] debug
);

  logic dcache_miss, dcache_write_ready;
  logic dcache_read_en, dcache_write_en, dcache_fetch, dcache_read_data_valid;
  logic [31:0] dcache_write_data, dcache_read_data;

  logic icache_miss;
  logic icache_fetch;
  logic [31:0] icache_read_data;

  logic SPI_data_ready;
  logic [31:0] SPI_data;

  logic [1:0] d_i_mode;

  logic [31:0] debug_SPI, debug_icache;

  //logic [1:0] icache_debug;
  //assign dcache_miss = 0;
  //assign dcache_stall = 0;

  assign video_write_data = write_data[7:0];
  assign video_write_addr = mem_addr[10:0];

always_comb begin

  if(DIP_switch[5]) debug = debug_icache;
  else debug = debug_SPI;

end

always_comb begin

  //video_write_data = {3'b000, icache_miss, 3'b000, SPI_data_ready, 3'b000, dcache_miss, 4'b000, icache_read_data[7:0], SPI_data[7:0]};
  //video_write_data = SPI_data;

//defaultni hodnoty
video_write_enable = 0;
clean_key_buffer = 0;
mem_read_data = 0;
dcache_read_en = 0;
dcache_write_en = 0;
read_data_valid = 0;
write_ready = 0;
//defaultni hodnoty


  if(mem_en == 1) begin


    if(mem_addr[31:20] == 12'b000000000000) begin         //pouziva se pamet

      mem_read_data = dcache_read_data;
      read_data_valid = dcache_read_data_valid;
      write_ready = dcache_write_ready;

      case(store_size)
        2'b11: begin                  //cte se z pameti
          dcache_read_en = 1;
          dcache_write_en = 0;

        end                             //zapisuje se do pameti
        2'b10, 2'b01, 2'b00: begin
          dcache_read_en = 0;
          dcache_write_en = 1;
        end

        default: begin
          dcache_read_en = 0;
          dcache_write_en = 0;
        end

      endcase

    end
    else if( (mem_addr[31:12] == 20'hF0000) && (store_size == 2'b00)) begin       //zapisuje se do videopameti

        video_write_enable = 1;
        write_ready = 1;

    end
    else if( (mem_addr == 32'hFFFFFFFF) && (store_size == 2'b11)) begin

      clean_key_buffer = 1;
      mem_read_data = {{24{1'b0}}, pressed_key [7:0]};
      read_data_valid = keyboard_valid;

    end
    else begin

      video_write_enable = 0;
      clean_key_buffer = 0;
      mem_read_data = 0;
      dcache_read_en = 0;
      dcache_write_en = 0;

    end

  end
  else begin

    video_write_enable = 0;
    clean_key_buffer = 0;
    mem_read_data = 0;
    dcache_read_en = 0;
    dcache_write_en = 0;

  end

end

always_comb begin

//defaultni hodnoty
instr_fetch = icache_read_data;
dcache_write_data = write_data;
//defaultni hodnoty

//icache cache miss
  icache_fetch = SPI_data_ready & d_i_mode[1];
//dcache cache miss
  dcache_fetch = SPI_data_ready & d_i_mode[0];

  /*if(icache_miss_prev) instr_fetch = SPI_data;
  else if(dcache_miss_prev) begin

    dcache_write_data = SPI_data;
    read_data = SPI_data;

  end*/
end

spi_controller SPI_Flash(
                        .CLK(CLK_CPU),
                        .resetn(resetn),
                        .icache_miss(icache_miss),
                        .dcache_miss(dcache_miss),
                        .mode(d_i_mode),
                        .SPI_data_ready(SPI_data_ready),
                        .dcache_addr(mem_addr[19:0]),
                        .icache_addr(nextPC[19:0]),
                        .SPI_data(SPI_data),
                        .SPI_CS(SPI_CS),
                        .SPI_SCK(SPI_SCK),
                        .SPI_SI(SPI_SI),
                        .SPI_SO(SPI_SO),

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
                        .flash_io3_di(flash_io3_di),*/

                        .DIP_switch(DIP_switch),
                        .debug(debug_SPI)
  );



dcache L1D(
          .resetn(resetn),
          .CLK(CLK_CPU),
          .read_en(dcache_read_en),
          .write_en(dcache_write_en),
          .fetch(dcache_fetch),
          .cache_miss(dcache_miss),
          .store_size(store_size),

          .mem_addr(mem_addr[19:0]),

          .RDATA_OUT(dcache_read_data),
          .RDATA_valid(dcache_read_data_valid),

          .write_data_from_cpu(dcache_write_data),
          .write_data_SPI(SPI_data),
          .write_ready(dcache_write_ready)
  );

  icache L1I(
            .fetch_valid(fetch_valid),
            .resetn(resetn),
            .CLK(CLK_CPU),
            .read_en(fetch_enable),
            .fetch(icache_fetch),
            .cache_miss(icache_miss),
            .read_addr(nextPC[19:0]),
            .write_data(SPI_data),
            .RDATA_OUT(icache_read_data),

            .debug(debug_icache),
            .DIP_switch(DIP_switch)
    );

endmodule
