/*
      Obvod bere jako vstup hodinovy a datovy signal z klavesnice
      Klavesnice posila data v 11 bitovych "paketech" (data posila kdyz je clk_keyboard log 0):

          1 start bit.  This is always 0.
          8 data bits, least significant bit first.
          1 parity bit (odd parity).
          1 stop bit.  This is always 1.

          Viz. http://www.burtonsys.com/ps2_chapweske.htm

          Parity bit == "The parity bit is set if there is an even number of 1's in the data bits and reset (0) if there is an odd number of 1's in the data bits.  The number of 1's in the data bits plus the parity bit always add up to an odd number (odd parity.)"

      Pokud 11 bitovy paket splnuje pozadavky (obsahuje zacatecni i koncovy bit a kontrolni parity bit je nastaven spravne),
      tak obvod na vystup "scancode" posle tzv. scan code zmacknute klavesy (scan code je neco jako ascii tabulka, viz. http://www.philipstorr.id.au/pcbook/book3/scancode.htm)
      Zaroven obvod nastavi vystup "is_valid" na log 1, aby indikoval, ze posila validni scan code

      Obvod je implementovan pomoci 4 stavoveho FSM (Finite State Machine):
        Stav 1: klavesnice neposila data, kdyz obvod obdzi zacatecni bit, prejde do stavu 2
        Stav 2: obvod postupne uklada 8 datovych bitu do bufferu
        Stav 3: pokud je kontrolni bit nastaven spravne, obvod prejde do stavu 3, jinak prejde do stavu 1
        Stav 4: pokud je koncovy bit nastaven spravne (== 1), obvod posle scan code z bufferu na vystup, prejde zpet do stavu 1

      Obvod pouziva 13 bitu pameti (8 bitu zabira buffer, 4 bity na indikaci stavu FSM)

*/

module ps2_interface(
  input logic clk_keyboard, clk_cpu, data,            //vstupni hodinovy signal a data z klavesnice
  output logic [7:0] scancode,         //scan code - neco jako ascii, ale pro klavesnice
  output logic is_valid_out
);
  logic [7:0] buffer;       //zde se ukladaji jednotlive datove bity
  logic [3:0] FSM_state;		//stav FSM
  logic [3:0] FSM_state_next; //pristi stav FSM
  logic ps2_clk_prev, is_valid;

always_ff @ (negedge clk_keyboard) begin

  FSM_state <= FSM_state_next;      //na konci cyklu se aktualizuje stav FSM

  case(FSM_state)
    //Stav 1: data == 0 -> klavesnice bude posilat data
    //Stav 2: ukladani dat do bufferu
    1: buffer[0] <= data;
    2: buffer[1] <= data;
    3: buffer[2] <= data;
    4: buffer[3] <= data;
    5: buffer[4] <= data;
    6: buffer[5] <= data;
    7: buffer[6] <= data;
    8: buffer[7] <= data;
    //Posledni bit ulozen do bufferu, pokracuje se na Stav 3
    //Stav 3: pokud je pocet log 1 v bufferu a parity bitu lichy (celkem 9 bitu, "lichost" lze zjistit pomoci log fce XOR), pokracuj na Stav 4, jinak jdi na Stav 1
    //Stav 4: pokud data == 1, posli na vystup obsah bufferu + "is_valid" nastav na log 1, nasledne se vzdy vrati na Stav 1
  endcase

end

always_comb begin

  scancode = buffer;
  is_valid = 0;

  case(FSM_state)
    //Stav 1: data == 0 -> klavesnice bude posilat data
    0: begin if(data == 0) FSM_state_next = 4'b0001;
       else FSM_state_next = 0; end


    //Stav 2: ukladani dat do bufferu
    1: begin //buffer[0] = data;
             FSM_state_next = 2; end
    2: begin //buffer[1] = data;
             FSM_state_next = 3; end
    3: begin //buffer[2] = data;
             FSM_state_next = 4; end
    4: begin //buffer[3] = data;
             FSM_state_next = 5; end
    5: begin //buffer[4] = data;
             FSM_state_next = 6; end
    6: begin //buffer[5] = data;
             FSM_state_next = 7; end
    7: begin //buffer[6] = data;
             FSM_state_next = 8; end
    8: begin //buffer[7] = data;
             FSM_state_next = 9; end
    //Posledni bit ulozen do bufferu, pokracuje se na Stav 3

    //Stav 3: pokud je pocet log 1 v bufferu a parity bitu lichy (celkem 9 bitu, "lichost" lze zjistit pomoci log fce XOR), pokracuj na Stav 4, jinak jdi na Stav 1
    9: if(data ^ buffer[0] ^ buffer[1] ^ buffer[2] ^ buffer[3] ^ buffer[4] ^ buffer[5] ^ buffer[6] ^ buffer[7])
            FSM_state_next = 10;
       else FSM_state_next = 0;

    //Stav 4: pokud data == 1, posli na vystup obsah bufferu + "is_valid" nastav na log 1, nasledne se vzdy vrati na Stav 1
    10: begin
          FSM_state_next = 0;
          is_valid = 1;
        end

    default: FSM_state_next = 0;

  endcase

end

always_ff @ (posedge clk_cpu) begin

  ps2_clk_prev <= clk_keyboard;

  if(!ps2_clk_prev & clk_keyboard) is_valid_out = is_valid;
  else is_valid_out = 0;

end

endmodule
