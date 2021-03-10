module core(
  input logic CLK,										//vstupni CLK
  input logic resetn,
  input logic mem_read_data_valid, mem_write_ready,
  input logic [31:0] instr_fetch, mem_read_data, 				//vstupni instrukce + prectena data z pameti
  input logic fetch_valid,
  output logic memory_en_out,								//vystupni signal memory_en -> pokud je 1, pamet se bude pouzivat
  output logic [1:0] store_size,						//"00" - zapisuje se 8 bitu, "01" zapisuje se 16 bitu, "10" zapisuje se 32 bitu, "11" z pameti se cte
  output logic [31:0] PCfetch,							//adresa z ktere se bude nacitat pristi instrukce
  output logic [31:0] mem_write_data, mem_addr,			//data na zapsani, adresa kam zapisovat/cist
  //output logic [31:0] debug,
  output logic fetch_enable,

  input logic [7:0] DIP_switch,
  output logic [31:0] debug,
  input logic stall_debug
);

  logic [31:0] instr_fetch_exec, reg_rd1, reg_rd2;

  logic [31:0] PCmux, PCplus4, wd, rd1, rd2, aluB, aluA, imm, memData, aluRes;
  logic [31:0] nextPC, PC;
  logic [2:0] funct3, aluOp;
  logic [6:0] funct7;
  logic [6:0] op;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] instrType;
  logic we_reg, we_reg_controller, pcControl, aluBsel, aluAsel;
  logic [1:0] wdSelect;

  logic decoder_stall, memory_en, fetch_valid_exec;
  logic stall_pc, new_instr, stall_from_reg;

  logic branch_taken;
  logic jump, branch;

  logic aluA_rdy, aluB_rdy, rd1_rdy, rd2_rdy, aluRes_rdy;

  //assign debug = {3'b000, stall_pc, instr_fetch[27:0]};

  assign memory_en_out = memory_en & fetch_valid_exec & aluRes_rdy;

always_comb begin

  case(DIP_switch[6:0])
    7'b1000000: debug = PC;
    7'b1000001: debug = nextPC;
    7'b1000010: debug = instr_fetch_exec;
    7'b1000011: debug = {3'b000, stall_pc, 3'b000, fetch_valid_exec, 3'b000, decoder_stall,
    3'b000, stall_debug, 3'b000, resetn, 3'b000, mem_write_ready, 3'b000, we_reg,  4'b0000};
    7'b1000100: debug = aluRes;
    7'b1000101: debug = memData;
    7'b1000110: debug = mem_write_data;
    7'b1000111: debug = aluA;
    7'b1001000: debug = aluB;
    7'b1001001: debug = rd1;
    7'b1001010: debug = rd2;
    7'b1001011: debug = {rs1, rs2, 22'h000000};
    7'b1001100: debug = reg_rd1;
    7'b1001101: debug = reg_rd2;
    7'b1001110: debug = {1'b0, aluOp, 1'b0, funct3, 1'b0, funct7, 3'b000, branch_taken, 12'h000};
    7'b1001111: debug = PCmux;
    default: debug = PC;
  endcase

end

  decode decoder(instr_fetch_exec, funct3, aluOp, funct7, op, rd, rs1, rs2, imm, instrType, decoder_stall, mem_write_ready, mem_read_data_valid);

  controller controller(
      .CLK,
      .op,
      .instrType,
      .funct3,
      .we_reg(we_reg_controller),
      .pcControl,
      .memory_en,
      .aluAsel,
      .aluBsel,
      .wdSelect,
      .store_size,
      .jump,
      .branch
    );

  regfile regfile(CLK, we_reg, wd, rd, rs1, rs2, rd1, rd2, new_instr, reg_rd1, reg_rd2, rd1_rdy, rd2_rdy);

  main_controller main_controller(
    .CLK,
    .resetn,
    .decoder_stall,
    .we_reg_controller,
    .fetch_valid,
    .PCmux,
    .instr_fetch,
    .PC,
    .nextPC,
    .instr_fetch_exec,
    .fetch_enable,
    .we_reg,
    .fetch_valid_exec,
    .stall_pc,
    .stall_debug(stall_debug),
    .new_instr(new_instr),
    .branch,
    .jump,
    .aluRes_rdy
    );

    branch_unit branch_unit(
      .rd1(rd1),
      .rd2(rd2),
      .funct3,
      .branch_taken(branch_taken)
      );

always_comb begin

  wd = 0;

  if(!jump) begin

    if(wdSelect == 2'b00) wd = aluRes;
    else if(wdSelect == 2'b01) wd = memData;
    else if(wdSelect == 2'b10) wd = PCplus4;
    else wd = imm;      //wdSel == 3

  end
  else wd = PC;

end

always_comb begin

  if(aluBsel) begin
    aluB = rd2;
    aluB_rdy = rd2_rdy;
  end
  else begin
    aluB = imm;
    aluB_rdy = 1;
  end

  if(aluAsel) begin
    aluA = rd1;
    aluA_rdy = rd1_rdy;
  end
  else begin
    aluA = PC;
    aluA_rdy = 1;
  end

  if(aluA_rdy & aluB_rdy) aluRes_rdy = 1;
  else aluRes_rdy = 0;

end

  alu alu(aluA, aluB, aluOp, funct7, aluRes);

  //logika PC
  assign PCplus4 = PC + 4;

  //mux2 #(32) pcSelect(pcControl, PCplus4, {PC + imm}, PCmux);

always_comb begin

  if(pcControl) begin

    if(jump) PCmux = aluRes;

    else begin
      if(branch_taken) PCmux = aluRes;
      else PCmux = PCplus4;
    end

  end
  else PCmux = PCplus4;

end

  //assign PCfetch = nextPC + 16'h1000;
  assign PCfetch = nextPC;


//load store unit
  assign mem_addr = aluRes;

always_comb begin

//defaultni hodnoty
memData = 0;
mem_write_data = 0;
//defaultni hodnoty

  if(op == 7'b0000011) begin			//jedna se o LOAD instrukci, nacitaji se data z pameti

    case(funct3)

		  3'b000: memData = {{24{mem_read_data[7]}}, mem_read_data[7:0]};				//instrukce LB, z pameti se nacita jeden Byte, dela se sign extension
		  3'b001: memData = {{16{mem_read_data[7]}}, mem_read_data[15:0]};			//instrukce LH, z pameti se nacitaji dva Byty, dela se sign extension
		  3'b010: memData = mem_read_data;											                //instrukce LW, z pameti se nacita ctyri Byty
		  3'b100: memData = {{24{1'b0}}, mem_read_data[7:0]};						     	  //instrukce LBU, z pameti se nacita jeden Byte, nedela se sign extension
		  3'b101: memData = {{16{1'b0}}, mem_read_data[15:0]};						      //instrukce LHU, z pameti se nacitaji dva Byty, nedela se sign extension
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
