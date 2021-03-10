module main_controller(
  input logic CLK,
  input logic resetn,
  input logic decoder_stall,
  input logic we_reg_controller,
  input logic fetch_valid,
  input logic [31:0] PCmux,
  input logic [31:0] instr_fetch,

  output logic [31:0] PC,
  output logic [31:0] nextPC,
  output logic [31:0] instr_fetch_exec,
  output logic fetch_enable,
  output logic we_reg,
  output logic fetch_valid_exec,
  output logic stall_pc,

  input logic stall_debug,

  output logic new_instr,

  input logic branch,
  input logic jump,

  input logic aluRes_rdy
  );

  logic fetch_valid_buffer;
  logic [31:0] instr_fetch_buffer;
  logic [31:0] PC_reg, nextPC_reg;

  logic stall_reg;

  logic instr_executed, instr_executed_reg;

  //logic fetch_enable_reg;

/*always_ff @ (posedge CLK) begin

  if(!resetn) fetch_enable_reg <= 1;
  else begin

    fetch_enable_reg <= fetch_enable;

    //if(new_instr) begin
      //if(instr_executed) fetch_enable_reg <= 1;
      //else fetch_enable_reg <= 0;
    //end else if(instr_executed) fetch_enable_reg <= 1;

  end

end*/

always_comb begin

//slo by vylepsit
//instrukce ktere neskacou muzou fetchovat uz o cyklus drive

  if(instr_executed) fetch_enable = 1;
  else fetch_enable = 0;

  //fetch_enable = fetch_enable_reg;

  /*if(branch || jump) begin

    if(instr_executed) fetch_enable = 1;
    else fetch_enable = 0;

  end else begin

    if(new_instr) begin

      if(instr_executed) fetch_enable = 1;
      else fetch_enable = 0;

    end
    else begin

      if(instr_executed) fetch_enable = 1;

    end

  end*/

end

always_ff @ (posedge CLK) begin

  if(!resetn) begin
    fetch_valid_buffer <= 0;
    instr_fetch_buffer <= 0;
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

/*fetch_valid_buffer_next = fetch_valid_buffer;

if(fetch_valid) begin     //instrukce z icache je valid

  if(!stall_pc) begin

    fetch_valid_buffer_next = 0;
    instr_fetch_buffer_next = instr_fetch_exec;

  end
  else begin

    fetch_valid_buffer_next = 1;
    instr_fetch_buffer_next = instr_fetch_exec;

  end

end
else begin

  if(stall_pc) begin

    fetch_valid_buffer_next = fetch_valid_exec;
    instr_fetch_buffer_next = instr_fetch_exec;

  end
  else begin
    fetch_valid_buffer_next = 0;
  end*/

end

always_ff @ (posedge CLK) begin

  if(!resetn) instr_executed_reg <= 1;
  else instr_executed_reg <= instr_executed;

end

always_comb begin

  instr_executed = instr_executed_reg;

  /*if(fetch_valid_exec) begin

    if(decoder_stall) instr_executed = 0;
    else instr_executed = 1;

  end
  else instr_executed = 0;*/


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

always_comb begin

  fetch_valid_exec = fetch_valid_buffer;
  instr_fetch_exec = instr_fetch_buffer;
  new_instr = 0;

    if(fetch_valid) begin     //instrukce z icache je valid

      if(!fetch_valid_buffer) begin

        if(!stall_debug) begin

          fetch_valid_exec = 1;
          instr_fetch_exec = instr_fetch;

          new_instr = 1;

        end

      end

    end

end


always_ff @ (posedge CLK) begin

  if(!resetn) begin
    PC_reg <= 32'hFFFFFFFC;
    nextPC_reg <= 32'h00000000;
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
  nextPC = nextPC_reg;

  if(new_instr) PC = nextPC_reg;
  else PC = PC_reg;

  if(branch || jump) begin

    if(aluRes_rdy) nextPC = PCmux;
    else nextPC = nextPC_reg;

  end
  else begin

    if(new_instr) nextPC = PCmux;
    else nextPC = nextPC_reg;

  end

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

    if(!aluRes_rdy)begin
      stall_pc = 1;
      stall_reg = 1;
    end
    else if(decoder_stall) begin
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
