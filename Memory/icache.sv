/*
	Parametry ICache:
		Velikost: 4KB
		Cache Line Size: 4B (32 bitu)
		Asociativita: 4-cestna
		Latence: ?


	adresa[31:0]:
		adresa[1:0] - adresy instrukci jsou (mely by byt) vzdy zarovnany na hranici 4B. Tzn. spodni dva bity adresy by vzdy mely byt 00, lze je tedy ignorovat
		adresa[9:2] - 8 bitu pouzito jako adresa pameti cache
		adresa[19:10] - 10 bitu pouzito jako tag
		adresa[31:20] - hornich 12 bitu adresy ignorovano
	Celkem tedy 20 (19:0) adresnich bitu, coz umoznuje adresovat 2^20 Bytu pameti - 1MB


	Organizace tagu[15:0]:
		tag[9:0] - 10 bitovy tag
		tag[12:10] - 2 bity pouzity na LRU replacement policy
    tag[12] - dirty bit
		tag[13] - valid bit
		tag[14] - zatim nepouzit
		tag[15] - zatim nepouzit


*/
module icache(
    input logic CLK, read_en, fetch,
    input logic [19:0] read_addr,
    input logic [31:0] write_data,
    output logic cache_miss,
    output logic [31:0] RDATA_OUT
);

    logic [7:0] RADDR_TAG, RADDR_CACHE;
    logic [15:0] tagA_NEW, tagB_NEW, tagC_NEW, tagD_NEW;
    logic [1:0] LRU_A, LRU_B, LRU_C, LRU_D;
    logic [1:0] set_used;           //ktery set byl pouzit, 00 = A, 01 = B, 10 = C, 11 = D
    logic WE_tag, WE_setA, WE_setB, WE_setC, WE_setD;
    logic [15:0] tagA, tagB, tagC, tagD;
    logic [31:0] RDATA_setA, RDATA_setB, RDATA_setC, RDATA_setD;
    logic [31:0] MASK;

    logic [19:0] read_addr_old;
    logic [1:0] state;

//initial state = 0;

//logika pro meneni stavu cache
always_ff @ (posedge CLK) begin
    case(state)

          2'b00: begin                    //stav == 0, cache je neaktivni
            if(read_en) begin
              state <= 1;
              read_addr_old <= read_addr;
            end
            else state <= 0;
          end

          2'b01: begin                    //stav == 1, z pameti cache se cte
            if(!cache_miss) begin

              if(read_en) begin
                state <= 1;
                read_addr_old <= read_addr;
              end
              else state <= 0;

            end
            else state <= 2;

          end

          2'b10: begin                    //stav == 2, do cache se zapisuje
            if(fetch) state <= 0;
            else state <= 2;
          end

          2'b11: state <= 0;              //stav == 3, nelegalni stav
    endcase
end



always_comb begin

  RADDR_TAG = read_addr[9:2];    //read
  RADDR_CACHE = read_addr[9:2];    //read

case(state)
  2'b00: begin
    cache_miss = 0;
    RDATA_OUT = 0;              //dont care
    set_used = 2'b00;           //dont care

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
      RDATA_OUT = 0;           //dont care
      set_used = 2'b00;           //dont care
    end
    //konec cteni dat
  end

  2'b10: begin

    if(fetch) begin

      cache_miss = 0;
      RDATA_OUT = write_data;

      if(tagA[13] == 0) set_used = 2'b00;
      else if(tagB[13] == 0) set_used = 2'b01;
      else if(tagC[13] == 0) set_used = 2'b10;
      else if(tagD[13] == 0) set_used = 2'b11;

      else begin

        if((LRU_A <= LRU_B) & (LRU_A <= LRU_C) & (LRU_A <= LRU_D))    //LRU_A je nejmensi
          set_used = 2'b00;
        else if((LRU_B <= LRU_C) & (LRU_B <= LRU_D))                  //LRU_B je nejmensi
          set_used = 2'b01;
        else if(LRU_C <= LRU_D)                                       //LRU_C je nejmensi
          set_used = 2'b10;
        else set_used = 2'b11;                                        //LRU_D je nejmensi

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
    RDATA_OUT = 0;
    set_used = 2'b00;       //dont care

  end
endcase

end



always_comb begin

  tagA_NEW[15:14] = 0;
  tagB_NEW[15:14] = 0;
  tagC_NEW[15:14] = 0;
  tagD_NEW[15:14] = 0;

  LRU_A = tagA[11:10];
  LRU_B = tagB[11:10];
  LRU_C = tagC[11:10];
  LRU_D = tagD[11:10];

//Aktualizace tagu pokud se cte z pameti a neni cache miss
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
//Aktualizace tagu pokud se cte z pameti a neni cache miss

//zapisujeme novy blok dat z pameti, fetch
  else if((state == 2'b10) && (fetch == 1)) begin

    MASK = 32'h00000000;
    WE_tag = 1;

    if(set_used == 2'b00) begin
      WE_setA = 1;

      tagA_NEW[13] = 1;                   //valid bit == 1
      tagA_NEW[12] = 0;                   //dirt bit == 0
      tagA_NEW[9:0] = read_addr_old[19:10];  //tag
    end
    else begin
      WE_setA = 0;

      tagA_NEW[13:12] = tagA[13:12];
      tagA_NEW[9:0] = tagA[9:0];
    end

    if(set_used == 2'b01) begin
      WE_setB = 1;

      tagB_NEW[13] = 1;                   //valid bit == 1
      tagB_NEW[12] = 0;                   //dirt bit == 0
      tagB_NEW[9:0] = read_addr_old[19:10];  //tag
    end
    else begin
      WE_setB = 0;

      tagB_NEW[13:12] = tagB[13:12];
      tagB_NEW[9:0] = tagB[9:0];
    end

    if(set_used == 2'b10) begin
      WE_setC = 1;

      tagC_NEW[13] = 1;                   //valid bit == 1
      tagC_NEW[12] = 0;                   //dirt bit == 0
      tagC_NEW[9:0] = read_addr_old[19:10];  //tag
    end
    else begin
      WE_setC = 0;

      tagC_NEW[13:12] = tagC[13:12];
      tagC_NEW[9:0] = tagC[9:0];
    end

    if(set_used == 2'b11) begin
      WE_setD = 1;

      tagD_NEW[13] = 1;                   //valid bit == 1
      tagD_NEW[12] = 0;                   //dirt bit == 0
      tagD_NEW[9:0] = read_addr_old[19:10];  //tag
    end
    else begin
      WE_setD = 0;

      tagD_NEW[13:12] = tagD[13:12];
      tagD_NEW[9:0] = tagD[9:0];
    end
  end
//konec zapisovani noveho bloku

  else begin    //nezapisuje se ani se necte

    MASK = 32'h11111111;
    WE_tag = 0;
    WE_setA = 0;
    WE_setB = 0;
    WE_setC = 0;
    WE_setD = 0;

    tagA_NEW[13:12] = tagA[13:12];              //dont care
    tagB_NEW[13:12] = tagB[13:12];
    tagC_NEW[13:12] = tagC[13:12];
    tagD_NEW[13:12] = tagD[13:12];

    tagA_NEW[9:0] = tagA[9:0];
    tagB_NEW[9:0] = tagB[9:0];
    tagC_NEW[9:0] = tagC[9:0];
    tagD_NEW[9:0] = tagD[9:0];
  end


  if( ((state == 2'b01) && (cache_miss == 0)) || ((state == 2'b10) && (fetch == 1)) )

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

defparam icache_setA.RAM_low.INIT_0 =
256'hf0000000000fff00000000000000000000000000000000008023011300B70000;
defparam icache_setA.RAM_high.INIT_0 =
256'hf0000000000fff000000000000000000000000000000000000200410F0000000;
defparam icache_tagA.RAM.INIT_0 =
256'hf0000000000fff00000000000000000000000000000000002000200020002000;

defparam icache_setA.RAM_low.INIT_1 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setA.RAM_low.INIT_2 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setA.RAM_low.INIT_3 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setA.RAM_low.INIT_4 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setA.RAM_low.INIT_5 =
256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam icache_setA.RAM_low.INIT_6 =
256'h0000000000000000000000000000000000000000000000000000000000000000;


RAM256x32 icache_setA(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setA),
                      .WE_c(WE_setA),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setA)
                      );

RAM256x16 icache_tagA(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagA)
                      );

RAM256x32 icache_setB(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setB),
                      .WE_c(WE_setB),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setB)
                      );

RAM256x16 icache_tagB(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagB)
                      );

RAM256x32 icache_setC(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setC),
                      .WE_c(WE_setC),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setC)
                      );

RAM256x16 icache_tagC(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagC)
                      );

RAM256x32 icache_setD(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_setD),
                      .WE_c(WE_setD),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setD)
                      );

RAM256x16 icache_tagD(.RCLK_c(CLK),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(read_addr_old[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
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
