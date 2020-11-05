/*
Mapa pametovych adres:
    uzivatelska pamet - adresy 0x00000000 az 0x000FFFFF (1MB)
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
    input CLK_CPU, mem_en,
    input [1:0] store_size,
    input [31:0] nextPC, mem_addr, write_data,

    //klavesnice
    input wire [7:0] pressed_key,
    output reg clean_key_buffer,
    //klavesnice

    //videopamet
    output reg video_write_enable,
    output reg [7:0] video_write_data,
    output reg [10:0] video_write_addr,
    //videopamet

    output reg stall,
    output logic [31:0] instr_fetch, read_data
);

  wire dcache_miss;
  reg dcache_read_en, dcache_write_en, dcache_fetch;
  reg [31:0] dcache_write_data, dcache_write_addr, dcache_read_data;

  wire icache_miss;
  reg icache_fetch;
  reg [31:0] icache_write_data, icache_write_addr;

  reg busy;         //indikuje, zda je pamet uprostred zapisu, cteni, fetche


always @ (posedge CLK_CPU) begin

  stall = 0;
  read_data = 0;

  dcache_read_en = 0;
  dcache_write_en = 0;
  dcache_fetch = 0;
  dcache_write_addr = 0;
  dcache_write_data = 0;

  icache_fetch = 0;
  icache_write_addr = 0;
  icache_write_data = 0;

  video_write_enable = 0;
  video_write_data = write_data[7:0];
  video_write_addr = mem_addr[10:0];

  clean_key_buffer = 0;

  if(mem_en == 1) begin

    if(mem_addr[31:20] == 12'b000000000000) begin         //pouziva se pamet
      case(store_size)
        2'b11: begin                  //cte se z pameti
          read_data = dcache_read_data;
          dcache_read_en = 1;
          dcache_write_en = 0;
          dcache_fetch = 0;
          dcache_write_data = 0;
      end                             //zapisuje se do pameti
        2'b10, 2'b01, 2'b00: begin
          dcache_read_en = 0;
          dcache_write_en = 1;
          dcache_fetch = 0;
          dcache_write_data = write_data;
        end
      endcase
    end

    if(mem_addr[31:12 == 20'hF0000]) begin              //zapisuje se do videopameti
      if(store_size == 2'b00) begin                      //zapisuje se 8 bitu
        video_write_enable = 1;
      end
    end

    if(mem_addr == 32'hFFFFFFFF) begin
      if(store_size == 2'b11) begin
        clean_key_buffer = 1;
        read_data = {{24{1'b0}}, pressed_key [7:0]};
      end
    end
  end
end


dcache L1D(
          .CLK(CLK_CPU),
          .read_en(dcache_read_en),
          .write_en(dcache_write_en),
          .fetch(dcache_fetch),
          .cache_miss(dcache_miss),
          .store_size(store_size),
          .read_addr(mem_addr[19:0]),
          .write_addr(mem_addr[19:0]),
          .write_data(dcache_write_data),
          .RDATA_out(dcache_read_data),
          .TAG_OUT()                     //doplnit
  );

  icache L1I(
            .CLK(CLK_CPU),
            .read_en(1),
            .fetch(icache_fetch),
            .cache_miss(icache_miss),
            .read_addr(nextPC[19:0]),
            .write_addr(0),
            .write_data(icache_write_data),
            .RDATA_out(instr_fetch)
    );

endmodule