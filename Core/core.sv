module core(
  input logic CLK,										//vstupni CLK
  input logic resetn,
  input logic mem_read_data_valid, mem_write_ready,
  input logic [31:0] instr_fetch, mem_read_data, 				//vstupni instrukce + prectena data z pameti
  input logic fetch_valid,
  output logic memory_en_out,								//vystupni signal memory_en -> pokud je 1, pamet se bude pouzivat
  output logic [1:0] store_size,						//"00" - zapisuje se 8 bitu, "01" zapisuje se 16 bitu, "10" zapisuje se 32 bitu, "11" z pameti se cte
  output logic [19:0] PCfetch,							//adresa z ktere se bude nacitat pristi instrukce
  output logic [31:0] mem_write_data, mem_addr,			//data na zapsani, adresa kam zapisovat/cist
  //output logic [31:0] debug,
  output logic fetch_enable,

  input logic [7:0] DIP_switch,
  output logic [31:0] debug,
  input logic stall_debug
);

  logic [31:0] instr_fetch_exec, reg_rd1, reg_rd2;

  logic [31:0] wd, rd1, rd2, aluB, aluA, imm, memData, aluRes;
  logic [19:0] nextPC, PC, PCmux, PCplus4;
  logic [2:0] funct3, aluOp;
  logic [6:0] funct7;
  logic [6:0] op;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] instrType;
  logic we_reg, we_reg_controller, aluBsel, aluAsel;
  logic [1:0] wdSelect;

  logic memory_en, fetch_valid_exec;
  logic stall_pc, new_instr, stall_from_reg;

  logic branch_taken;
  logic jump, branch;
  logic PCmux_valid;

  logic aluA_rdy, aluB_rdy, rd1_rdy, rd2_rdy, aluRes_rdy, branch_unit_rdy;
  logic mem_adress_valid, load_store_unit_rdy, load_store_rdata_valid;

  logic [31:0] agu_read_data;

  logic unknown_instr;
  logic [1:0] ld_state;

  //assign debug = {3'b000, stall_pc, instr_fetch[27:0]};


always_comb begin

  case(DIP_switch[6:0])
    7'b1000000: debug = {12'h000, PC};
    7'b1000001: debug = {12'h000, nextPC};
    7'b1000010: debug = instr_fetch_exec;
    7'b1000011: debug = {3'b000, stall_pc, 3'b000, fetch_valid_exec, 3'b000, unknown_instr,
    3'b000, stall_debug, 3'b000, resetn, 3'b000, mem_write_ready, 3'b000, we_reg, 3'b000, branch_taken};
    7'b1000100: debug = aluRes;
    7'b1000101: debug = memData;
    7'b1000110: debug = mem_write_data;
    7'b1000111: debug = aluA;
    7'b1001000: debug = aluB;
    7'b1001001: debug = rd1;
    7'b1001010: debug = rd2;
    7'b1001011: debug = {rs1, rs2, 22'h000000};
    //7'b1001100: debug = reg_rd1;
    //7'b1001101: debug = reg_rd2;
    7'b1001110: debug = {1'b0, aluOp, 1'b0, funct3, 1'b0, funct7, 2'b00, store_size, 3'b000, memory_en, 3'h000, memory_en_out, 2'b00, ld_state};
    //7'b1001111: debug = PCmux;
    7'b1010000: debug = agu_read_data;
    7'b1010001: debug = mem_read_data;
    default: debug = {12'h000, PC};
  endcase

end

  decode decoder(instr_fetch_exec, funct3, aluOp, funct7, op, rd, rs1, rs2, imm, instrType, unknown_instr);

  controller controller(
      .op,
      .instrType,
      .funct3,
      .we_reg(we_reg_controller),
      .memory_en,
      .aluAsel,
      .aluBsel,
      .wdSelect,
      .store_size,
      .jump,
      .branch
    );

  regfile regfile(CLK, we_reg, wd, rd, rs1, rs2, rd1, rd2, new_instr, rd1_rdy, rd2_rdy);

  main_controller main_controller(
    .CLK,
    .resetn,
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
    .aluRes_rdy,
    .branch_unit_rdy,
    .load_store_unit_rdy,
    .load_store_rdata_valid,
    .unknown_instr,
    .PCmux_valid
    );

    branch_unit branch_unit(
      .rd1(rd1),
      .rd2(rd2),
      .funct3,
      .branch_taken(branch_taken)
      );

always_comb begin

  wd = 0;

  if(wdSelect == 2'b00) wd = aluRes;
  else if(wdSelect == 2'b01) wd = agu_read_data;
  else if(wdSelect == 2'b10) wd = {12'h000, PCplus4};
  else wd = imm;      //wdSel == 3

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
    aluA = {12'h000, PC};
    aluA_rdy = 1;
  end

  if(aluA_rdy & aluB_rdy) aluRes_rdy = 1;
  else aluRes_rdy = 0;

  branch_unit_rdy = rd1_rdy & rd2_rdy;

end

  //alu alu(aluA, aluB, aluOp, funct7, aluRes);

  alu alu(
    .a(aluA),
    .b(aluB),
    .aluOp,
    .funct7,
    .out(aluRes)
  );

  //logika PC
  assign PCplus4 = PC + 4;

  //mux2 #(32) pcSelect(pcControl, PCplus4, {PC + imm}, PCmux);

always_comb begin

  if(jump) begin                //jump
    PCmux = aluRes[19:0];
    PCmux_valid = aluRes_rdy;
  end
  else if(branch) begin         //branch

    if(branch_taken) begin
      PCmux = aluRes[19:0];
      PCmux_valid = aluRes_rdy & branch_unit_rdy;
    end
    else begin
      PCmux = PCplus4;
      PCmux_valid = branch_unit_rdy;
    end

  end

  else begin                //ordinary instr
    PCmux = PCplus4;
    PCmux_valid = 1;
  end

end

  //assign PCfetch = nextPC + 16'h1000;
  assign PCfetch = nextPC;


//load store unit
  assign mem_addr = aluRes;

  assign mem_adress_valid = fetch_valid_exec & aluRes_rdy;

  load_store_unit load_store_unit(
    .CLK,
    .resetn,
    .new_instr,
    .memory_en,
    .mem_read_data_valid,
    .mem_write_ready,
    .mem_adress_valid,
    .store_size,
    .funct3,
    .mem_read_data,
    .mem_write_data,
    .agu_read_data,
    .memory_en_out,
    .load_store_unit_rdy,
    .load_store_rdata_valid,
    .rd2,
    .ld_state
    );

endmodule
