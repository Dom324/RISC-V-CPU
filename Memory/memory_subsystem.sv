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

    input logic mem_en,
    input logic [1:0] store_size,
    input logic [31:0] nextPC, mem_addr, write_data,
    output logic stall,
    output logic [31:0] instr_fetch, read_data,

    //klavesnice
    input logic [7:0] pressed_key,
    output logic clean_key_buffer,
    //klavesnice

    //videopamet
    output logic video_write_enable,
    output logic [31:0] video_write_data,
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
  	input  flash_io2_di,*/
  	input logic flash_io3_di
);

  logic dcache_miss, dcache_miss_prev;
  logic dcache_read_en, dcache_write_en, dcache_fetch;
  logic [31:0] dcache_write_data, dcache_read_data;
  logic [19:0] dcache_read_addr, dcache_write_addr;

  logic icache_miss, icache_miss_prev;
  logic icache_fetch;
  logic [31:0] icache_write_data, icache_read_data;

  logic SPI_data_ready;
  logic [31:0] SPI_data, read_data_mem, word_debug;


always_comb begin

  //video_write_data = write_data[7:0];
  video_write_data = SPI_data;
  video_write_addr = mem_addr[10:0];

//defaultni hodnoty
video_write_enable = 0;
clean_key_buffer = 0;
read_data_mem = 0;
dcache_read_en = 0;
dcache_write_en = 0;
//defaultni hodnoty


  if(mem_en == 1) begin


    if(mem_addr[31:20] == 12'b000000000000) begin         //pouziva se pamet

      case(store_size)        // synopsys full_case parallel_case
        2'b11: begin                  //cte se z pameti
          dcache_read_en = 1;
          dcache_write_en = 0;
          read_data_mem = dcache_read_data;
        end                             //zapisuje se do pameti
        2'b10, 2'b01, 2'b00: begin
          dcache_read_en = 0;
          dcache_write_en = 1;
          read_data_mem = 0;
        end

      endcase
    end


    if( (mem_addr[31:12] == 20'hF0000) && (store_size == 2'b00)) begin       //zapisuje se do videopameti
        video_write_enable = 1;
    end


    if( (mem_addr == 32'hFFFFFFFF) && (store_size == 2'b11)) begin
      clean_key_buffer = 1;
      read_data_mem = {{24{1'b0}}, pressed_key [7:0]};
    end

  end
end

always_ff @ (posedge CLK_CPU) begin

  icache_miss_prev <= icache_miss;
  dcache_miss_prev <= dcache_miss;

end

always_comb begin

  if(icache_miss || dcache_miss) stall = 1;
  else stall = 0;

end

always_comb begin

//defaultni hodnoty
instr_fetch = icache_read_data;
dcache_write_data = write_data;
read_data = read_data_mem;
//defaultni hodnoty

  dcache_write_addr = mem_addr;
  dcache_read_addr = mem_addr;

//icache cache miss
  icache_fetch = SPI_data_ready;
  icache_write_data = SPI_data;
//dcache cache miss
  dcache_fetch = SPI_data_ready;

  if(icache_miss_prev) instr_fetch = SPI_data;
  else if(dcache_miss_prev) begin

    dcache_write_data = SPI_data;
    read_data = SPI_data;

  end
end

spi_controller SPI_Flash(
                        .CLK(CLK_CPU),
                        .resetn(resetn),
                        .icache_miss(icache_miss),
                        .dcache_miss(dcache_miss),
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
                        .word_debug(word_debug)
  );

/*spimemio spi_flash(
                  .clk(CLK_CPU),
                  .resetn(resetn),
                  .valid(1),
                  .ready(SPI_data_ready),
                  .addr(24'h050000),
                  .rdata(SPI_data),

                  .flash_csb(SPI_CS),
                  .flash_clk(SPI_SCK),

                  .flash_io0_oe(flash_io0_oe),
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
                  .flash_io3_di(flash_io3_di),

                  .cfgreg_we(4'b0000),
                  .cfgreg_di(0),
                  .cfgreg_do(),

                  .word_debug(word_debug)
  );*/



/*dcache L1D(
          .CLK(CLK_CPU),
          .read_en(dcache_read_en),
          .write_en(dcache_write_en),
          .fetch(dcache_fetch),
          .cache_miss(dcache_miss),
          .store_size(store_size),
          .read_addr(dcache_read_addr),
          .write_addr(dcache_write_addr),
          .write_data(dcache_write_data),
          .RDATA_OUT(dcache_read_data)
  );*/

  icache L1I(
            .CLK(CLK_CPU),
            .read_en(1),
            .fetch(icache_fetch),
            .cache_miss(icache_miss),
            .read_addr(nextPC[19:0]),
            .write_data(icache_write_data),
            .RDATA_OUT(icache_read_data)
    );

endmodule
