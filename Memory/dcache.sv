/*
	Parametry DCache:
		Velikost: 4KB
		Cache Line Size: 4B (32 bitu)
		Asociativita: 4-cestna
		Latence: ?


	adresa[31:0]:
		adresa[1:0] - zarovnani
		adresa[9:2] - 8 bitu pouzito jako adresa pameti cache
		adresa[19:10] - 10 bitu pouzito jako tag
		adresa[31:20] - hornich 12 bitu adresy ignorovano
	Celkem tedy 20 (19:0) adresnich bitu, coz umoznuje adresovat 2^20 Bytu pameti - 1MB

  Data Cache aktualne NEpodporuje nezarovnane zapisy/cteni! Tj. pokud se zapisuje 32 bitu,
  zapis musi byt zarovnan na hranici 32 bitu (podobne s 16 bity), jinak zapis neprobehne.
  V budoucnu by se toto melo predelat, aby cache splnovala standard ISA RISC-V,
  ktery vyzaduje podporu nezarovnanych zapisu. Aktualni stav muze (a pravdepodobne bude)
  zpusobovat chyby.

	Organizace tagu[15:0]:
		tag[9:0] - 10 bitovy tag
		tag[11:10] - 2 bity pouzity na LRU replacement policy
    tag[12] - dirt bit, znaci zda byl blok prepsan
		tag[13] - valid bit, znaci zda jsou data v cache aktualni/validni
		tag[14] - zatim nepouzit
		tag[15] - zatim nepouzit


  Write size[1:0]:
    Ovlada kolik Bytu se bude zapisovat
    "00" - zapisuje se jeden Byte
    "01" - zapisuji se dva Byty
    "10" - zapisuji se ctyry Byty
    "11" - nelegalni hodnota

*/
module dcache(
    input CLK, read_en, write_en, fetch,
    input [19:0] read_addr, write_addr,
    input [31:0] write_data,
    input [1:0] store_size,
    output reg cache_miss,
    output reg [31:0] RDATA_OUT
);

    reg [31:0] MASK;
    reg [7:0] RADDR_TAG, RADDR_CACHE, WADDR_CACHE, WADDR_TAG;
    reg [15:0] tagA_NEW, tagB_NEW, tagC_NEW, tagD_NEW;
    reg [1:0] LRU_A, LRU_B, LRU_C, LRU_D;
    reg [1:0] LRU2_A, LRU2_B, LRU2_C, LRU2_D;
    reg [1:0] set_used;           //ktery set byl pouzit, 00 = A, 01 = B, 10 = C, 11 = D
    reg WE_tag, WE_setA, WE_setB, WE_setC, WE_setD;
    wire [15:0] tagA, tagB, tagC, tagD;
    wire [31:0] RDATA_setA, RDATA_setB, RDATA_setC, RDATA_setD;

    logic [19:0] read_addr_old, write_addr_old;
    logic [2:0] state;

//initial state = 0;

//logika pro meneni stavu cache
always_ff @ (posedge CLK) begin
    case(state)

          2'b00: begin                    //stav == 0, cache je neaktivni
            if(read_en) begin
              state <= 1;
              read_addr_old <= read_addr;
            end
            else if(write_en) begin
              state <= 2;
              write_addr_old <= write_addr;
            end
            else state <= 0;
          end

          2'b01: begin                    //stav == 1, z pameti cache se cte
            if(!cache_miss) begin

              if(read_en) begin
                state <= 1;
                read_addr_old <= read_addr;
              end
              else if(write_en) begin
                state <= 2;
                write_addr_old <= write_addr;
              end
              else state <= 0;

            end
            else
              state <= 3;

          end

          2'b10: begin              //stav == 2, do cache se zapisuje

            if(read_en) begin
              state <= 1;
              read_addr_old <= read_addr;
            end
            else if(write_en) begin
              state <= 2;
              write_addr_old <= write_addr;
            end
            else state <= 0;

          end

          2'b11: begin                    //stav == 3, do cache se fetchuje, cache cte data
            if(fetch) state <= 0;
            else state <= 3;
          end

    endcase
end

always_comb begin

  case(state)
    2'b00: RADDR_TAG = 0;                  //dont care
    2'b01: RADDR_TAG = read_addr[9:2];     //read
    2'b10: RADDR_TAG = write_addr[9:2];    //write
    2'b11: RADDR_TAG = read_addr[9:2];     //fetch read
    default: RADDR_TAG = 0;                 //dont care
  endcase

  RADDR_CACHE = read_addr[9:2];     //read

  case(state)
    2'b00: WADDR_TAG = 0;                  //dont care
    2'b01: WADDR_TAG = read_addr[9:2];     //read
    2'b10: WADDR_TAG = write_addr[9:2];    //write
    2'b11: WADDR_TAG = read_addr[9:2];     //fetch read
    default: WADDR_TAG = 0;                 //dont care
  endcase

  case(state)
    2'b00: WADDR_CACHE = 0;                  //dont care
    2'b01: WADDR_CACHE = 0;     //read
    2'b10: WADDR_CACHE = write_addr[9:2];    //write
    2'b11: WADDR_CACHE = read_addr[9:2];     //fetch read
    default: WADDR_CACHE = 0;                 //dont care
  endcase


  case(state)
    2'b00: begin
      cache_miss = 0;
      RDATA_OUT = 0;      //dont care
      set_used = 0;       //dont care
    end

    2'b01: begin


      //cteme data
      if( (tagA[9:0] == read_addr[19:10]) & (tagA[13] == 1) ) begin
        RDATA_OUT = RDATA_setA;
        set_used = 2'b00;
        cache_miss = 0;
      end

      else if( (tagB[9:0] == read_addr[19:10]) & (tagB[13] == 1) ) begin
          RDATA_OUT = RDATA_setB;
          set_used = 2'b01;
          cache_miss = 0;
      end

      else if( (tagC[9:0] == read_addr[19:10]) & (tagC[13] == 1) ) begin
          RDATA_OUT = RDATA_setC;
          set_used = 2'b10;
          cache_miss = 0;
      end

      else if( (tagD[9:0] == read_addr[19:10]) & (tagD[13] == 1) ) begin
          RDATA_OUT = RDATA_setD;
          set_used = 2'b11;
          cache_miss = 0;
      end

      else begin

        cache_miss = 1;
        RDATA_OUT = 0;              //dont care
        set_used = 0;               //dont care

      end
      //konec cteni dat
    end

    2'b10: begin             //zapis dat

      cache_miss = 0;
      RDATA_OUT = 0;      //dont care

      //zapisujeme data
      if( ((tagA[9:0] == write_addr[19:10]) & (tagA[13] == 1)) || (tagA[13] == 0) )
        set_used = 2'b00;

      else if( (tagB[9:0] == write_addr[19:10]) & (tagB[13] == 1) || (tagB[13] == 0) )
        set_used = 2'b01;

      else if( (tagC[9:0] == write_addr[19:10]) & (tagC[13] == 1) || (tagC[13] == 0) )
        set_used = 2'b10;

      else if( (tagD[9:0] == write_addr[19:10]) & (tagD[13] == 1) || (tagD[13] == 0) )
        set_used = 2'b11;

      else begin

        //miss
        if( (tagA[9:2] != 8'hAF) && ((LRU2_A <= LRU2_B) & (LRU2_A <= LRU2_C) & (LRU2_A <= LRU2_D)) )
          set_used = 2'b00;

        else if( (tagB[9:2] != 8'hAF) && ((LRU2_B <= LRU2_C) & (LRU2_B <= LRU2_D)) )
          set_used = 2'b01;

        else if( (tagC[9:2] != 8'hAF) && (LRU2_C <= LRU2_D) )
          set_used = 2'b10;

        else if(tagD[9:2] != 8'hAF)
          set_used = 2'b11;

        else set_used = 0;        //dont care

      end
      //konec zapisu dat
    end


    2'b11: begin             //fetch read

      //fetch dat
      if(fetch) begin

        cache_miss = 0;
        RDATA_OUT = write_data;

        if(tagA[13] == 0) set_used = 2'b00;
        else if(tagB[13] == 0) set_used = 2'b01;
        else if(tagC[13] == 0) set_used = 2'b10;
        else if(tagD[13] == 0) set_used = 2'b11;

        else begin

          if( (tagA[9:2] != 8'hAF) && ((LRU2_A <= LRU2_B) & (LRU2_A <= LRU2_C) & (LRU2_A <= LRU2_D)) )
            set_used = 2'b00;

          else if( (tagB[9:2] != 8'hAF) && ((LRU2_B <= LRU2_C) & (LRU2_B <= LRU2_D)) )
            set_used = 2'b01;

          else if( (tagC[9:2] != 8'hAF) && (LRU2_C <= LRU2_D) )
            set_used = 2'b10;

          else if(tagD[9:2] != 8'hAF)
            set_used = 2'b11;

          else set_used = 0;        //dont care

        end
      end
      else begin
        cache_miss = 1;
        RDATA_OUT = 0;           //dont care
        set_used = 2'b00;         //dont care
      end
    end

    default: begin

      cache_miss = 0;
      RDATA_OUT = 0;           //dont care
      set_used = 2'b00;         //dont care

    end
  endcase
end




always_comb begin

//cteme data
  if((state == 2'b01) && (cache_miss == 0)) begin

    MASK = 32'h11111111;
    WE_tag = 1;
    WE_setA = 0;
    WE_setB = 0;
    WE_setC = 0;
    WE_setD = 0;

    tagA_NEW[13:12] = tagA[13:12];
    tagB_NEW[13:12] = tagB[13:12];
    tagC_NEW[13:12] = tagC[13:12];
    tagD_NEW[13:12] = tagD[13:12];

    tagA_NEW[9:0] = tagA[9:0];
    tagB_NEW[9:0] = tagB[9:0];
    tagC_NEW[9:0] = tagC[9:0];
    tagD_NEW[9:0] = tagD[9:0];

  end
//konec cteni dat
  else if(state == 2'b10) begin

    WE_tag = 1;

    //nastaveni masky podle toho kolik Bytu zapisujeme
    if(store_size == 2'b00) begin   //zapisujeme 8 bitu, podle adresy je vybrano 8 bitu ktere budou v MASK nastaveny na 0
      if(write_addr[1:0] == 2'b00) MASK = 32'hffffff00;
      if(write_addr[1:0] == 2'b01) MASK = 32'hffff00ff;
      if(write_addr[1:0] == 2'b10) MASK = 32'hff00ffff;
      if(write_addr[1:0] == 2'b11) MASK = 32'h00ffffff;
    end

    else if(store_size == 2'b01) begin    //zapisujeme 16 bitu, podle adresy je bud 16 dolnich nebo 16 hornich bitu MASKy nastaveno na 1
      if(write_addr[1]) MASK = 32'h0000ffff;
      else MASK = 32'hffff0000;
    end

    else if(store_size == 2'b10) MASK = 32'h00000000;     //zapisujeme 32 bitu, MASK = 0

    else if(store_size == 2'b11) MASK = 32'hffffffff;     //nelegalni operace, nezapisuje se, proto MASK = 32'hffffffff
    //nastaveni masky podle toho kolik Bytu zapisujeme

    case(set_used)
      2'b00: begin
        WE_setA = 1;
        WE_setB = 0;
        WE_setC = 0;
        WE_setD = 0;
      end
      2'b01: begin
        WE_setA = 0;
        WE_setB = 1;
        WE_setC = 0;
        WE_setD = 0;
      end
      2'b10: begin
        WE_setA = 0;
        WE_setB = 0;
        WE_setC = 1;
        WE_setD = 0;
      end
      2'b11: begin
        WE_setA = 0;
        WE_setB = 0;
        WE_setC = 0;
        WE_setD = 1;
      end
    endcase

    if(set_used == 2'b00) begin
      tagA_NEW[13] = 1;                   //valid bit == 1
      tagA_NEW[12] = 1;                   //dirt bit == 1
      tagA_NEW[9:0] = write_addr[19:10];  //tag
    end
    else begin
      tagA_NEW[13:12] = tagA[13:12];
      tagA_NEW[9:0] = tagA[9:0];
    end

    if(set_used == 2'b01) begin
      tagB_NEW[13] = 1;                   //valid bit == 1
      tagB_NEW[12] = 1;                   //dirt bit == 1
      tagB_NEW[9:0] = write_addr[19:10];  //tag
    end
    else begin
      tagB_NEW[13:12] = tagB[13:12];
      tagB_NEW[9:0] = tagB[9:0];
    end

    if(set_used == 2'b10) begin
      tagC_NEW[13] = 1;                   //valid bit == 1
      tagC_NEW[12] = 1;                   //dirt bit == 1
      tagC_NEW[9:0] = write_addr[19:10];  //tag
    end
    else begin
      tagC_NEW[13:12] = tagC[13:12];
      tagC_NEW[9:0] = tagC[9:0];
    end

    if(set_used == 2'b11) begin
      tagD_NEW[13] = 1;                   //valid bit == 1
      tagD_NEW[12] = 1;                   //dirt bit == 1
      tagD_NEW[9:0] = write_addr[19:10];  //tag
    end
    else begin
      tagD_NEW[13:12] = tagD[13:12];
      tagD_NEW[9:0] = tagD[9:0];
    end
  end

  //fetchujeme data
  else if(state == 2'b11) begin

    if(fetch) begin

      MASK = 32'h00000000;

      WE_tag = 1;

      case(set_used)
        2'b00: begin
          WE_setA = 1;
          WE_setB = 0;
          WE_setC = 0;
          WE_setD = 0;
        end
        2'b01: begin
          WE_setA = 0;
          WE_setB = 1;
          WE_setC = 0;
          WE_setD = 0;
        end
        2'b10: begin
          WE_setA = 0;
          WE_setB = 0;
          WE_setC = 1;
          WE_setD = 0;
        end
        2'b11: begin
          WE_setA = 0;
          WE_setB = 0;
          WE_setC = 0;
          WE_setD = 1;
        end
      endcase

      if(set_used == 2'b00) begin
        tagA_NEW[13] = 1;                   //valid bit == 1
        tagA_NEW[12] = 0;                   //dirt bit == 0
        tagA_NEW[9:0] = write_addr[19:10];  //tag
      end
      else begin
        tagA_NEW[13:12] = tagA[13:12];
        tagA_NEW[9:0] = tagA[9:0];
      end

      if(set_used == 2'b01) begin
        tagB_NEW[13] = 1;                   //valid bit == 1
        tagB_NEW[12] = 0;                   //dirt bit == 0
        tagB_NEW[9:0] = write_addr[19:10];  //tag
      end
      else begin
        tagB_NEW[13:12] = tagB[13:12];
        tagB_NEW[9:0] = tagB[9:0];
      end

      if(set_used == 2'b10) begin
        tagC_NEW[13] = 1;                   //valid bit == 1
        tagC_NEW[12] = 0;                   //dirt bit == 0
        tagC_NEW[9:0] = write_addr[19:10];  //tag
      end
      else begin
        tagC_NEW[13:12] = tagC[13:12];
        tagC_NEW[9:0] = tagC[9:0];
      end

      if(set_used == 2'b11) begin
        tagD_NEW[13] = 1;                   //valid bit == 1
        tagD_NEW[12] = 0;                   //dirt bit == 0
        tagD_NEW[9:0] = write_addr[19:10];  //tag
      end
      else begin
        tagD_NEW[13:12] = tagD[13:12];
        tagD_NEW[9:0] = tagD[9:0];
      end
    end
    else begin

      MASK = 32'hffffffff;

      WE_tag = 0;

      WE_setA = 0;
      WE_setB = 0;
      WE_setC = 0;
      WE_setD = 0;

      tagA_NEW[13] = 1;                   //dont care
      tagA_NEW[12] = 1;                   //dont care
      tagA_NEW[9:0] = write_addr[19:10];  //dont care

      tagB_NEW[13] = 1;                   //dont care
      tagB_NEW[12] = 1;                   //dont care
      tagB_NEW[9:0] = write_addr[19:10];  //dont care

      tagC_NEW[13] = 1;                   //dont care
      tagC_NEW[12] = 1;                   //dont care
      tagC_NEW[9:0] = write_addr[19:10];  //dont care

      tagD_NEW[13] = 1;                   //dont care
      tagD_NEW[12] = 1;                   //dont care
      tagD_NEW[9:0] = write_addr[19:10];  //dont care

    end
  end
  //konec fetchovani

  else begin

    MASK = 32'hffffffff;

    WE_tag = 0;

    WE_setA = 0;
    WE_setB = 0;
    WE_setC = 0;
    WE_setD = 0;

    tagA_NEW[13] = 1;                   //dont care
    tagA_NEW[12] = 1;                   //dont care
    tagA_NEW[9:0] = write_addr[19:10];  //dont care

    tagB_NEW[13] = 1;                   //dont care
    tagB_NEW[12] = 1;                   //dont care
    tagB_NEW[9:0] = write_addr[19:10];  //dont care

    tagC_NEW[13] = 1;                   //dont care
    tagC_NEW[12] = 1;                   //dont care
    tagC_NEW[9:0] = write_addr[19:10];  //dont care

    tagD_NEW[13] = 1;                   //dont care
    tagD_NEW[12] = 1;                   //dont care
    tagD_NEW[9:0] = write_addr[19:10];  //dont care

  end
end


//aktualizace LRU
always_comb begin

  if(tagA[9:2] == 8'hAF) LRU2_A = 3;
  else LRU2_A = tagA[11:10];

  if(tagB[9:2] == 8'hAF) LRU2_B = 3;
  else LRU2_B = tagB[11:10];

  if(tagC[9:2] == 8'hAF) LRU2_C = 3;
  else LRU2_C = tagC[11:10];

  if(tagD[9:2] == 8'hAF) LRU2_D = 3;
  else LRU2_D = tagD[11:10];

  LRU_A = tagA[11:10];
  LRU_B = tagB[11:10];
  LRU_C = tagC[11:10];
  LRU_D = tagD[11:10];

  tagA_NEW[15:14] = 0;
  tagB_NEW[15:14] = 0;
  tagC_NEW[15:14] = 0;
  tagD_NEW[15:14] = 0;



  if(
      ((state == 2'b01) && (cache_miss == 0)) ||
      (state == 2'b10) ||
      ((state == 2'b11) && (fetch == 1))
    ) begin

    //aktualizujeme tag, pokud:
    //1. cteme z cache a neni cache cache_miss
    //2. zapisujeme do cache
    //3. fetchuje se z pameti

    case(set_used)          //aktualizace LRU bitu
      2'b00: begin
        if(LRU_B < LRU_A) tagB_NEW[11:10] = LRU_B + 1;
        else tagB_NEW[11:10] = LRU_B;

        if(LRU_C < LRU_A) tagC_NEW[11:10] = LRU_C + 1;
        else tagC_NEW[11:10] = LRU_C;

        if(LRU_D < LRU_A) tagD_NEW[11:10] = LRU_D + 1;
        else tagD_NEW[11:10] = LRU_D;

        tagA_NEW[11:10] = 0;
      end
      2'b01: begin
        if(LRU_A < LRU_B) tagA_NEW[11:10] = LRU_A + 1;
        else tagA_NEW[11:10] = LRU_A;

        if(LRU_C < LRU_B) tagC_NEW[11:10] = LRU_C + 1;
        else tagC_NEW[11:10] = LRU_C;

        if(LRU_D < LRU_B) tagD_NEW[11:10] = LRU_D + 1;
        else tagD_NEW[11:10] = LRU_D;

        tagB_NEW[11:10] = 0;
      end
      2'b10: begin
        if(LRU_A < LRU_C) tagA_NEW[11:10] = LRU_A + 1;
        else tagA_NEW[11:10] = LRU_A;

        if(LRU_B < LRU_C) tagB_NEW[11:10] = LRU_B + 1;
        else tagB_NEW[11:10] = LRU_B;

        if(LRU_D < LRU_C) tagD_NEW[11:10] = LRU_D + 1;
        else tagD_NEW[11:10] = LRU_D;

        tagC_NEW[11:10] = 0;
      end
      2'b11: begin
        if(LRU_A < LRU_D) tagA_NEW[11:10] = LRU_A + 1;
        else tagA_NEW[11:10] = LRU_A;

        if(LRU_B < LRU_D) tagB_NEW[11:10] = LRU_B + 1;
        else tagB_NEW[11:10] = LRU_B;

        if(LRU_C < LRU_D) tagC_NEW[11:10] = LRU_C + 1;
        else tagC_NEW[11:10] = LRU_C;

        tagD_NEW[11:10] = 0;
      end
    endcase
  end
  else begin

    tagA_NEW[11:10] = 0;       //dont care
    tagB_NEW[11:10] = 0;       //dont care
    tagC_NEW[11:10] = 0;       //dont care
    tagD_NEW[11:10] = 0;       //dont care

  end
end

RAM256x32 dcache_setA(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setA),
                      .WE_c(WE_setA),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(WADDR_CACHE),
                      .MASK_IN(MASK[31:0]),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setA)
                      );

RAM256x16 dcache_tagA(.RCLK_c(CLK),
                      .RCLKE_c(read_en || write_en || fetch),
                      .RE_c(read_en || write_en || fetch),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(WADDR_TAG),
                      .MASK_IN(16'h0000),
                      .WDATA_IN(tagA_NEW),
                      .RDATA_OUT(tagA)
                      );

RAM256x32 dcache_setB(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setB),
                      .WE_c(WE_setB),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(WADDR_CACHE),
                      .MASK_IN(MASK[31:0]),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setB)
                      );

RAM256x16 dcache_tagB(.RCLK_c(CLK),
                      .RCLKE_c(read_en || write_en || fetch),
                      .RE_c(read_en || write_en || fetch),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(WADDR_TAG),
                      .MASK_IN(16'h0000),
                      .WDATA_IN(tagB_NEW),
                      .RDATA_OUT(tagB)
                      );

RAM256x32 dcache_setC(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setC),
                      .WE_c(WE_setC),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(WADDR_CACHE),
                      .MASK_IN(MASK[31:0]),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setC)
                      );

RAM256x16 dcache_tagC(.RCLK_c(CLK),
                      .RCLKE_c(read_en || write_en || fetch),
                      .RE_c(read_en || write_en || fetch),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(WADDR_TAG),
                      .MASK_IN(16'h0000),
                      .WDATA_IN(tagC_NEW),
                      .RDATA_OUT(tagC)
                      );

RAM256x32 dcache_setD(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setD),
                      .WE_c(WE_setD),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(WADDR_CACHE),
                      .MASK_IN(MASK[31:0]),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setD)
                      );

RAM256x16 dcache_tagD(.RCLK_c(CLK),
                      .RCLKE_c(read_en || write_en || fetch),
                      .RE_c(read_en || write_en || fetch),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(WADDR_TAG),
                      .MASK_IN(16'h0000),
                      .WDATA_IN(tagD_NEW),
                      .RDATA_OUT(tagD)
                      );
/*
defparam icache_setD_low.INIT_0 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_1 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_2 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_3 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_4 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_5 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_6 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_7 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_8 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_9 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_A =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_B =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_C =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_D =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_E =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setD_low.INIT_F =
256'h0000000000000000000000000000000000000000000000000000000000000000;
*/




endmodule
