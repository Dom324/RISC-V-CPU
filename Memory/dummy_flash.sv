/*

	Emulator SPI Flash pro simulaci

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
module dummy_flash(
    input logic resetn,

    //SPI rozhrani
    input logic SPI_CS, SPI_SCK, SPI_SI,
    output logic SPI_SO

);

  logic [7:0] bit_counter;
  logic [255:0] data;

  assign data = 256'h0000000000f00000b70000000004100113000000000020802300000000000000;

always_ff @ (posedge SPI_SCK) begin

  if(!resetn) bit_counter <= 8'b11111111;

  else if(SPI_CS == 0) bit_counter <= bit_counter - 1;

end

always_ff @ (negedge SPI_SCK) begin

  SPI_SO = data[bit_counter];

end

endmodule
