module core(
  input logic CLK,										//vstupni CLK
  input logic resetn,
  input logic mem_read_data_valid, mem_write_ready,
  input logic [31:0] instr_fetch, mem_read_data, 				//vstupni instrukce + prectena data z pameti
  input logic fetch_valid,
  output logic memory_en,								//vystupni signal memory_en -> pokud je 1, pamet se bude pouzivat
  output logic [1:0] store_size,						//"00" - zapisuje se 8 bitu, "01" zapisuje se 16 bitu, "10" zapisuje se 32 bitu, "11" z pameti se cte
  output logic [31:0] PCfetch,							//adresa z ktere se bude nacitat pristi instrukce
  output logic [31:0] mem_write_data, mem_addr,			//data na zapsani, adresa kam zapisovat/cist
  output logic [31:0] debug
);

  logic stall_pc, stall_reg, stall_mem, fetch_valid_exec, mem_read_data_valid_exec;
  logic [31:0] instr_fetch_exec, PCmux, PCplus4, wd, rd1, rd2, aluB, aluA, imm, memData, aluRes;
  logic [31:0] mem_read_data_exec;
  logic [31:0] nextPC, PC, PC_reg, nextPC_reg;
  logic [2:0] funct3, aluOp;
  logic [6:0] funct7;
  logic [6:0] op;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] instrType;
  logic we_reg, we_reg_controller, pcControl, aluBsel, aluAsel;
  logic [1:0] wdSel;

  assign debug = {3'b000, stall_pc, instr_fetch[27:0]};

  decode decoder(instr_fetch_exec, funct3, aluOp, funct7, op, rd, rs1, rs2, imm, instrType);

  controller controller(CLK, op, instrType, funct3, we_reg_controller, pcControl, memory_en,
  aluBsel, aluAsel, wdSel, store_size, controller_stall, jump, mem_write_ready, mem_read_data_valid);

  regfile regfile(CLK, we_reg, wd, rd, rs1, rs2, rd1, rd2);

always_comb begin

  if(!jump) begin

    if(wdSel == 0) wd = aluRes;
    else if(wdSel == 1) wd = memData;
    else if(wdSel == 2) wd = PCplus4;
    else if(wdSel == 3) wd = imm;

  end
  else wd = PC;

end

always_comb begin

  if(aluBsel) aluB = rd2;
  else aluB = imm;

  if(aluAsel) aluA = rd1;
  else aluA = PC;

end

  alu alu(aluA, aluB, aluOp, funct7, aluRes);

  //logika PC
  assign PCplus4 = PC + 4;

  mux2 #(32) pcSelect(pcControl, PCplus4, aluRes, PCmux);

  assign PCfetch = nextPC + 16'h1000;

always_ff @ (posedge CLK) begin

    instr_fetch_exec <= instr_fetch;
    fetch_valid_exec <= fetch_valid;

    mem_read_data_exec <= mem_read_data;
    mem_read_data_valid_exec <= mem_read_data_valid;

end

always_ff @ (posedge CLK) begin

  if(!resetn) begin
    PC_reg <= 32'hFFFFFFFC;
    nextPC_reg <= 32'h0;
  end
  else begin

    //if(!stall_pc & (nextPC <= 32'h00000008))
      //PC <= nextPC;

    PC_reg <= PC;
    nextPC_reg <= nextPC;

  end
end

always_comb begin

  if(stall_pc) PC = PC_reg;
  else PC = nextPC_reg;

  if(stall_pc) nextPC = nextPC_reg;
  else nextPC = PCmux;


end
  //logika PC

  //stall logika
always_comb begin

  if(fetch_valid_exec) begin

    if(controller_stall) begin
      stall_pc = 1;
      stall_reg = 1;
    end
    else begin
      stall_pc = 0;
      stall_reg = 0;
    end

  end
  else begin

    stall_pc = 1;
    stall_reg = 1;

  end

  if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

end
  //stall logika

//load store unit
  assign mem_addr = aluRes;

always_comb begin

//defaultni hodnoty
memData = 0;
mem_write_data = 0;
//defaultni hodnoty

  if(funct7 == 7'b0000011) begin			//jedna se o LOAD instrukci, nacitaji se data z pameti

    case(funct3)       // synopsys full_case

		  3'b000: memData = {{24{mem_read_data[7]}}, mem_read_data[7:0]};				//instrukce LB, z pameti se nacita jeden Byte, dela se sign extension
		  3'b001: memData = {{16{mem_read_data[7]}}, mem_read_data[15:0]};			//instrukce LH, z pameti se nacitaji dva Byty, dela se sign extension
		  3'b010: memData = mem_read_data;											                //instrukce LW, z pameti se nacita ctyri Byty
		  3'b100: memData = {{24{1'b0}}, mem_read_data[7:0]};						     	  //instrukce LBU, z pameti se nacita jeden Byte, nedela se sign extension
		  3'b101: memData = {{16{1'b0}}, mem_read_data[15:0]};						      //instrukce LHU, z pameti se nacitaji dva Byty, nedela se sign extension
		//default: memData = 0;
	  endcase
	end

	if(op == 7'b0100011) begin			//jedna se o STORE instrukci, do pameti se ukladaji data

    case(funct3)      // synopsys full_case

	    3'b000: mem_write_data = {{24{1'b0}}, rd2[7:0]};				//instrukce SB, do pameti se uklada jeden Byte
		  3'b001: mem_write_data = {{16{1'b0}}, rd2[15:0]};				//instrukce SH, do pameti se ukladaji dva Byty
		  3'b010: mem_write_data = rd2;									//instrukce SW, do pameti se ukladaji ctyri Byty
		//default: mem_write_data = 0;
	  endcase
	end
end
endmodule
