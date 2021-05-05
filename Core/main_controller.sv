module main_controller(
  input logic CLK,
  input logic resetn,
  input logic we_reg_controller,
  input logic fetch_valid,
  input logic [19:0] PCmux,
  input logic [31:0] instr_fetch,

  output logic [19:0] PC,
  output logic [19:0] nextPC,
  output logic [31:0] instr_fetch_exec,
  output logic fetch_enable,
  output logic we_reg,
  output logic fetch_valid_exec,
  output logic stall_pc,

  input logic stall_debug,

  input logic unknown_instr,
  input logic branch,
  input logic jump,

  output logic new_instr,

  input logic aluRes_rdy,
  input logic branch_unit_rdy,
  input logic load_store_unit_rdy,
  input logic load_store_rdata_valid,
  input logic PCmux_valid
  );

  logic fetch_valid_buffer;
  logic [31:0] instr_fetch_buffer;
  logic [19:0] PC_reg, nextPC_reg;

  logic stall_reg;

  logic instr_executed, instr_executed_reg;

  logic been_there_done_that;
  logic stall_debug2;

always_ff @ (posedge CLK) begin

  //if(PC == 32'h00000048) stall_debug2 <= stall_debug;
  //else if(PC == 32'h00000054) stall_debug2 <= stall_debug;
  //else if(PC == 32'h000000d8) stall_debug2 <= stall_debug;
  //else stall_debug2 <= 0;

end

always_comb begin

//slo by vylepsit
//instrukce ktere neskacou muzou fetchovat uz o cyklus drive

if(PCmux_valid & !unknown_instr) fetch_enable = 1;
else fetch_enable = 0;

  /*if(branch) begin

    if(instr_executed & branch_unit_rdy) fetch_enable = 1;
    else fetch_enable = 0;

  end else begin

    if(instr_executed) fetch_enable = 1;
    else fetch_enable = 0;

  end*/

end

always_ff @ (posedge CLK) begin

  if(!resetn) begin
    fetch_valid_buffer <= 1;
    instr_fetch_buffer <= 32'h00000033;
    //stall_debug_buffer <= 0;
  end
  else begin

    instr_fetch_buffer <= instr_fetch_exec;

    if(instr_executed) begin

      fetch_valid_buffer <= 0;

    end
    else begin

      if(new_instr) fetch_valid_buffer <= 1;
      else fetch_valid_buffer <= fetch_valid_buffer;

    end

  end

end

always_ff @ (posedge CLK) begin

  if(!resetn) instr_executed_reg <= 1;
  else instr_executed_reg <= instr_executed;

end

always_comb begin

  instr_executed = instr_executed_reg;

  if(unknown_instr) instr_executed = 0;
  else begin

    if(fetch_valid_exec) begin

      if(instr_executed_reg) begin

        if(new_instr) begin

          if(stall_pc) instr_executed = 0;
          else instr_executed = 1;

        end
        else instr_executed = 1;

      end else begin
        if(stall_pc) instr_executed = 0;
        else instr_executed = 1;
      end

    end else instr_executed = instr_executed_reg;

  end

end

always_comb begin

  fetch_valid_exec = fetch_valid_buffer;
  instr_fetch_exec = instr_fetch_buffer;
  new_instr = 0;

    if(fetch_valid) begin     //instrukce z icache je valid

      if(!fetch_valid_buffer) begin

        if(!stall_debug) begin

          if(instr_executed_reg) begin

            instr_fetch_exec = instr_fetch;
            new_instr = 1;

            if(unknown_instr) fetch_valid_exec = 0;
            else fetch_valid_exec = 1;

          end

        end

      end

    end

end


always_ff @ (posedge CLK) begin

  if(!resetn) begin
    PC_reg <= 20'hFFFFC;
    nextPC_reg <= 20'h00000;
  end
  else begin

    //if(!stall_pc & (nextPC <= 32'h00000008))
      //PC <= nextPC;

    //if(PCmux != 32'h00000044)begin
      PC_reg <= PC;
      nextPC_reg <= nextPC;
    //end

  end

end

  /*assign PC = stall_pc_delayed ? PC_reg : nextPC_reg;
  assign nextPC = stall_pc_delayed ? nextPC_reg : PCmux;*/

always_comb begin

  PC = PC_reg;
  nextPC = PCmux;

  if(new_instr & instr_executed_reg) PC = nextPC_reg;
  else PC = PC_reg;

  /*if(branch || jump) begin

    if(aluRes_rdy) nextPC = PCmux;
    else nextPC = nextPC_reg;

  end
  else begin

    if(new_instr) nextPC = PCmux;
    else nextPC = nextPC_reg;

  end*/

end

  //logika PC

  //stall logika
always_comb begin

  if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

end

always_comb begin

  if(fetch_valid_exec) begin

    /*if(stall_debug) begin
      stall_pc = 1;
      stall_reg = 1;
    end
    else*/

    if(!aluRes_rdy) begin
      stall_pc = 1;
      stall_reg = 1;
    end
    else if(!load_store_unit_rdy) begin

      stall_pc = 1;
      stall_reg = 1;

    end
    else if(!branch_unit_rdy) begin
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

end
  //stall logika




endmodule
