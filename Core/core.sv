module core(
  input logic CLK,										//vstupni CLK
  input logic reset,
  input logic stall_mem,								//zastavit zpracovani instrukci, signal z pameti
  input logic [31:0] instr_fetch, mem_read_data, 				//vstupni instrukce + prectena data z pameti
  output logic memory_en,								//vystupni signal memory_en -> pokud je 1, pamet se bude pouzivat
  output logic [1:0] store_size,						//"00" - zapisuje se 8 bitu, "01" zapisuje se 16 bitu, "10" zapisuje se 32 bitu, "11" z pameti se cte
  output logic [31:0] nextPC,							//adresa z ktere se bude nacitat pristi instrukce
  output logic [31:0] mem_write_data, mem_addr			//data na zapsani, adresa kam zapisovat/cist
);

  logic stall_pc, stall_reg;
  logic [31:0] PC, PCplus4, wd, rd1, rd2, aluB, imm, memData, aluRes;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [6:0] op;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] instrType;
  logic we_reg, we_reg_controller, pcControl, aluBSel;
  logic [1:0] wdSel;


  //logika PC
  assign PCplus4 = PC + 4;

  mux4 #(32) pcSelect({pcControl, stall_pc}, PCplus4, aluRes, PC, PC, nextPC);

  always_ff @ (posedge CLK) begin
    //if(!reset)
      PC = nextPC;
    //else PC = 0;
  end
  //logika PC


  //stall logika
  always_comb begin

    if(stall_mem == 1) begin
	  stall_pc = 1;
	  stall_reg = 1;
	end
	else begin
	  stall_pc = 0;
	  stall_reg = 0;
	end

    if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

  end
  //stall logika


  decode decoder(instr_fetch, funct3, funct7, op, rd, rs1, rs2, imm, instrType);

  controller controller(op, instrType, funct3, we_reg_controller, pcControl, memory_en, aluBSel, wdSel, store_size);

  mux4 #(32) wdSelect(wdSel, aluRes, memData, PCplus4, imm, wd);

  regfile regfile(CLK, we_reg, wd, rd, rs1, rs2, rd1, rd2);

  mux2 #(32) aluBselect(aluBSel, rd2, imm, aluB);

  alu alu(rd1, aluB, funct3, funct7, aluRes);

  //load store unit
  assign mem_addr = aluRes;
  always_comb begin

    if(funct7 == 7'b0000011) begin			//jedna se o LOAD instrukci, nacitaji se data z pameti

      case(funct3)

		3'b000: memData = {{24{mem_read_data[7]}}, mem_read_data[7:0]};				//instrukce LB, z pameti se nacita jeden Byte, dela se sign extension
		3'b001: memData = {{16{mem_read_data[7]}}, mem_read_data[15:0]};			//instrukce LH, z pameti se nacitaji dva Byty, dela se sign extension
		3'b010: memData = mem_read_data;											//instrukce LW, z pameti se nacita ctyri Byty
		3'b100: memData = {{24{1'b0}}, mem_read_data[7:0]};							//instrukce LBU, z pameti se nacita jeden Byte, nedela se sign extension
		3'b101: memData = {{16{1'b0}}, mem_read_data[15:0]};						//instrukce LHU, z pameti se nacitaji dva Byty, nedela se sign extension
		default: memData = 0;
	  endcase
	end
	else memData = 0;

	if(op == 7'b0100011) begin			//jedna se o STORE instrukci, do pameti se ukladaji data

	  case(funct3)

	  3'b000: mem_write_data = {{24{1'b0}}, rd2[7:0]};				//instrukce SB, do pameti se uklada jeden Byte
		3'b001: mem_write_data = {{16{1'b0}}, rd2[15:0]};				//instrukce SH, do pameti se ukladaji dva Byty
		3'b010: mem_write_data = rd2;									//instrukce SW, do pameti se ukladaji ctyri Byty
		default: mem_write_data = 0;
	  endcase
	end
	else mem_write_data = 0;
  end
endmodule
