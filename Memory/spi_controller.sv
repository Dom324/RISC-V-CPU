/*

	SPI Kontroler

Pamet flash ma kapacitu 1MB. Cast teto kapacity zabira FPGA, takze pro procesor zbyva ~0.7MB
Konkretne se jedna o adresy 0x50000 az 0xFFFFF (vcetne).
Jelikoz je nevyhodne, aby pamet zacinala na adrese 0x50000, dela kontroler preklad z adresy CPU na adresu flash pameti:
┌────────┬─────────┬─────────┐
|________|   CPU   |  Flash  |
|Zacatek:| 0x00000 | 0x50000 |
|Konec:  | 0xAFFFF | 0xFFFFF |
└────────┴─────────┴─────────┘
Tento preklad se provadi prictenim konstanty 0x50000 k adrese CPU.
Zaroven kontroler provadi rozsireni adresy z 20 bitu na 24 bitu (horni 4 bity se nastavi na 0)

Postup cteni dat z flash pameti:
  1. Na pinu SPI_SCK je hodinovy signal
  2. Kontroler nastavi pin SPI_CS na log. 0
  3. Kontroler postupne posle na pin SPI_SI opcode "0x03" (v binarni SPI_SOustave "00000011") - tim pameti flash rekne, ze chce cist data
  4. Kontroler postupne posle na pin SPI_SI 24 adresnich bitu
  5. Kontroler cte data z pinu SPI_SO
  6. Az kontroler uspesne obdrzi vsech 32 bitu dat, nastavi pin SPI_CS na log. 1 a tim ukonci cteni

*/
module spi_controller(
    input logic CLK, icache_miss, dcache_miss,
    output logic SPI_data_ready,

    input logic [19:0] dcache_addr, icache_addr,
    output logic [31:0] SPI_data,

    //SPI rozhrani
    output logic SPI_CS, SPI_SCK, SPI_SI,
    input logic SPI_SO
    //SPI rozhrani
);

localparam opcode = 8'h03;					//opcode na cteni dat

  logic [2:0] bit_counter;
  logic [1:0] byte_counter;
  logic [4:0] bits_received;
  logic [7:0] flash_byte;

  logic [23:0] flash_addr;
  logic busy;
  logic receiving;

  assign SPI_SCK = CLK;         //clock pro SPI sbernici
  assign SPI_CS = busy;         //enable pin pro flash pamet


  //SPI_SI bit na vystupu
  decoder_3to8_inv output_select(bit_counter, flash_byte, SPI_SI);
  shift_reg #(32) SPI_buffer(CLK, receiving, SPI_SO, SPI_data);

always_ff @ (posedge CLK) begin

  flash_addr [23:20] = 4'b0000;

  if(!busy) begin

    if(icache_miss == 1) begin
      flash_addr[19:0] <= icache_addr + 19'h50000;
      busy <= 1;
    end
    else if(dcache_miss == 1) begin
      flash_addr[19:0] <= dcache_addr + 19'h50000;
      busy <= 1;
    end
    else begin
      flash_addr <= flash_addr;
      busy <= 0;
    end

  end
  else begin

    flash_addr[19:0] <= flash_addr[19:0];

    if(SPI_data_ready) begin
      busy <= 0;
    end
    else busy <= 1;

  end
end

always_ff @ (posedge CLK) begin

  if(busy) begin

    if(byte_counter != 2'b11) begin

      if(bit_counter == 3'b111) byte_counter <= byte_counter + 1;
      else byte_counter <= byte_counter;

      bit_counter <= bit_counter + 1;

    end
    else begin

      if(bit_counter == 3'b111) begin

        bit_counter <= 0;
        byte_counter <= 0;

      end
      else bit_counter <= bit_counter + 1;

    end
  end
  else begin
    bit_counter <= 0;
    byte_counter <= 0;
  end
end

always_ff @ (posedge CLK) begin

  if( (byte_counter == 2'b11) && (bit_counter == 3'b111) ) receiving <= 1;
  else if(bits_received == 5'b11111) receiving <= 0;
  else receiving <= receiving;

  if(receiving == 1) bits_received <= bits_received + 1;
  else bits_received <= 0;

  if(bits_received == 5'b11111) SPI_data_ready = 1;
  else SPI_data_ready = 0;

end

always_comb begin

  if(byte_counter == 2'b00) flash_byte = opcode;
  else if(byte_counter == 2'b01) flash_byte = flash_addr[23:16];
  else if(byte_counter == 2'b10) flash_byte = flash_addr[15:8];
  else flash_byte = flash_addr[7:0];

end

endmodule
