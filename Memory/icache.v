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
		tag[12:10] - 3 bity pouzity na LRU replacement policy
		tag[13] - zatim nepouzit
		tag[14] - dirty bit, znaci zda byl blok prepsan
		tag[15] - valid bit, znaci zda jsou data v cache aktualni/validni


*/
module icache(
    input CLK_cpu, read_en, fetch,
    input [19:0] read_addr, write_addr,
    input [31:0] write_data,
    output reg cache_miss,
    output reg [31:0] RDATA_out
);

    reg [7:0] RADDR_TAG, RADDR_CACHE;
    reg [15:0] tagA_NEW, tagB_NEW, tagC_NEW, tagD_NEW;
    reg [1:0] LRU_A, LRU_B, LRU_C, LRU_D;
    reg [1:0] set_used;           //ktery set byl pouzit, 00 = A, 01 = B, 10 = C, 11 = D
    reg WE_tag, WE_setA, WE_setB, WE_setC, WE_setD;
    wire [15:0] tagA, tagB, tagC, tagD;
    wire [31:0] RDATA_setA, RDATA_setB, RDATA_setC, RDATA_setD;
    reg [31:0] MASK;

always @ (posedge CLK_cpu) begin

  case({read_en, fetch})
        2'b00: RADDR_TAG = 0;    //no op
        2'b01: RADDR_TAG = write_addr[9:2];    //fetch
        2'b10: RADDR_TAG = read_addr[9:2];    //read
        2'b11: RADDR_TAG = 0;    //ilegal
  endcase

  case({read_en, fetch})
        2'b00: RADDR_CACHE = 0;    //no op
        2'b01: RADDR_CACHE = write_addr[9:2];    //fetch
        2'b10: RADDR_CACHE = read_addr[9:2];    //read
        2'b11: RADDR_CACHE = 0;    //ilegal
  endcase

    LRU_A = tagA[11:10];
    LRU_B = tagB[11:10];
    LRU_C = tagC[11:10];
    LRU_D = tagD[11:10];

    tagA_NEW[15:14] = 0;
    tagB_NEW[15:14] = 0;
    tagC_NEW[15:14] = 0;
    tagD_NEW[15:14] = 0;

  //defaultne nastavit write enable porty na 0
    WE_setA = 0;
    WE_setB = 0;
    WE_setC = 0;
    WE_setD = 0;

    WE_tag = 0;
  //defaultne nastavit write enable porty na 0
    cache_miss = 0;
    RDATA_out = 0;



//cteme data
  if((read_en == 1) & (fetch == 0)) begin

    if(tagA[9:0] == read_addr[19:10]) begin
      if(tagA[13] == 1) begin
        RDATA_out = RDATA_setA;
        set_used = 2'b00;
      end
    end

    else if(tagB[9:0] == read_addr[19:10]) begin
      if(tagB[13] == 1) begin
        RDATA_out = RDATA_setB;
        set_used = 2'b01;
      end
    end

    else if(tagC[9:0] == read_addr[19:10]) begin
      if(tagC[13] == 1) begin
        RDATA_out = RDATA_setC;
        set_used = 2'b10;
      end
    end

    else if(tagD[9:0] == read_addr[19:10]) begin
      if(tagD[13] == 1) begin
        RDATA_out = RDATA_setD;
        set_used = 2'b11;
      end
    end
    else begin
      cache_miss = 1;
      RDATA_out = 0;
    end
  end
//konec cteni dat


//zapisujeme novy blok dat z pameti, fetch
  if((read_en == 0) & (fetch == 1)) begin

    LRU_A = tagA[11:10];
    LRU_B = tagB[11:10];
    LRU_C = tagC[11:10];
    LRU_D = tagD[11:10];
    MASK = 32'h00000000;

    if((LRU_A <= LRU_B) & (LRU_A <= LRU_C) & (LRU_A <= LRU_D))    //LRU_A je nejmensi
        set_used = 2'b00;
    else if((LRU_B <= LRU_C) & (LRU_B <= LRU_D))                  //LRU_B je nejmensi
        set_used = 2'b01;
    else if(LRU_C <= LRU_D)                                       //LRU_C je nejmensi
        set_used = 2'b10;
    else set_used = 2'b11;                                    //LRU_D je nejmensi

    case(set_used)
      2'b00: WE_setA = 1;
      2'b01: WE_setB = 1;
      2'b10: WE_setC = 1;
      2'b11: WE_setD = 1;
    endcase
  end
//konec zapisovani noveho bloku


  if(~cache_miss) begin      //Aktualizace tagu pokud neni cache miss

    WE_tag = 1;
    tagA_NEW[13:0] = tagA[13:0];
    tagB_NEW[13:0] = tagB[13:0];
    tagC_NEW[13:0] = tagC[13:0];
    tagD_NEW[13:0] = tagD[13:0];

    case(set_used)          //aktualizace LRU bitu
      2'b00: begin
        if(LRU_B < LRU_A) tagB_NEW[11:10] = LRU_B + 1;
        if(LRU_C < LRU_A) tagC_NEW[11:10] = LRU_C + 1;
        if(LRU_D < LRU_A) tagD_NEW[11:10] = LRU_D + 1;
        tagA_NEW[11:10] = 0;
      end
      2'b01: begin
        if(LRU_A < LRU_B) tagA_NEW[11:10] = LRU_A + 1;
        if(LRU_C < LRU_B) tagC_NEW[11:10] = LRU_C + 1;
        if(LRU_D < LRU_B) tagD_NEW[11:10] = LRU_D + 1;
        tagB_NEW[11:10] = 0;
      end
      2'b10: begin
        if(LRU_A < LRU_C) tagA_NEW[11:10] = LRU_A + 1;
        if(LRU_B < LRU_C) tagB_NEW[11:10] = LRU_B + 1;
        if(LRU_D < LRU_C) tagD_NEW[11:10] = LRU_D + 1;
        tagC_NEW[11:10] = 0;
      end
      2'b11: begin
        if(LRU_A < LRU_D) tagA_NEW[11:10] = LRU_A + 1;
        if(LRU_B < LRU_D) tagB_NEW[11:10] = LRU_B + 1;
        if(LRU_C < LRU_D) tagC_NEW[11:10] = LRU_C + 1;
        tagD_NEW[11:10] = 0;
      end
    endcase

    if(fetch == 1) begin
      case(set_used)
        2'b00: begin
          tagA_NEW[13] = 1;                   //valid bit == 1
          tagA_NEW[12] = 0;                   //dirt bit == 0
          tagA_NEW[9:0] = write_addr[19:10];  //tag
        end
        2'b01: begin
          tagB_NEW[13] = 1;                   //valid bit == 1
          tagB_NEW[12] = 0;                   //dirt bit == 0
          tagB_NEW[9:0] = write_addr[19:10];  //tag
        end
        2'b10: begin
          tagC_NEW[13] = 1;                   //valid bit == 1
          tagC_NEW[12] = 0;                   //dirt bit == 0
          tagC_NEW[9:0] = write_addr[19:10];  //tag
        end
        2'b11: begin
          tagD_NEW[13] = 1;                   //valid bit == 1
          tagD_NEW[12] = 0;                   //dirt bit == 0
          tagD_NEW[9:0] = write_addr[19:10];  //tag
        end
      endcase
    end
  end



end

RAM256x32 icache_setA(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(fetch),
                      .WE_c(fetch),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setA)
                      );

RAM256x16 icache_tagA(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagA)
                      );

RAM256x32 icache_setB(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(fetch),
                      .WE_c(fetch),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setB)
                      );

RAM256x16 icache_tagB(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagB)
                      );

RAM256x32 icache_setC(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(fetch),
                      .WE_c(fetch),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setC)
                      );

RAM256x16 icache_tagC(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(0),
                      .RDATA_OUT(tagC)
                      );

RAM256x32 icache_setD(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(fetch),
                      .WE_c(fetch),
                      .RADDR_c(RADDR_CACHE),
                      .WADDR_c(write_addr[9:2]),
                      .MASK_IN(0),
                      .WDATA_IN(write_data),
                      .RDATA_OUT(RDATA_setD)
                      );

RAM256x16 icache_tagD(.RCLK_c(CLK_cpu),
                      .RCLKE_c(read_en),
                      .RE_c(read_en),
                      .WCLK_c(CLK_cpu),
                      .WCLKE_c(WE_tag),
                      .WE_c(WE_tag),
                      .RADDR_c(RADDR_TAG),
                      .WADDR_c(write_addr[9:2]),
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
