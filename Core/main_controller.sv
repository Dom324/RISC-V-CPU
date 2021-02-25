module main_controller(
  input CLK,
  input resetn,
  input decoder_stall,
  input we_reg_controller,
  input fetch_valid,
  input logic [31:0] PCmux,
  input logic [31:0] instr_fetch,

  output logic [31:0] PC,
  output logic [31:0] nextPC,
  output logic [31:0] instr_fetch_exec,
  output logic fetch_enable,
  output logic we_reg,
  output logic fetch_valid_exec,
  output logic stall_pc,
  input logic stall_debug
  );

  logic fetch_valid_buffer;
  logic [31:0] instr_fetch_buffer;
  logic [31:0] PC_reg, nextPC_reg;

  logic stall_reg;

  logic new_instr, instr_executed;

  logic fetch_enable_reg;

always_ff @ (posedge CLK) begin

  if(!resetn) fetch_enable_reg <= 1;
  else begin

    if(new_instr) begin
      if(instr_executed) fetch_enable_reg <= 1;
      else fetch_enable_reg <= 0;
    end else if(instr_executed) fetch_enable_reg <= 1;

  end

end

always_comb begin

  fetch_enable = fetch_enable_reg;

  if(new_instr) begin
    if(instr_executed) fetch_enable = 1;
    else fetch_enable = 0;
  end else if(instr_executed) fetch_enable = 1;

end

always_ff @ (posedge CLK) begin

  if(!resetn) begin
    fetch_valid_buffer <= 0;
    instr_fetch_buffer <= 0;
    //stall_debug_buffer <= 0;
  end
  else begin

    instr_fetch_buffer <= instr_fetch_exec;

    if(instr_executed) fetch_valid_buffer <= 0;
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

always_comb begin

  instr_executed = 0;

  if(fetch_valid_exec) begin

    if(stall_pc) instr_executed = 0;
    else instr_executed = 1;

  end

end

always_comb begin

  fetch_valid_exec = fetch_valid_buffer;
  instr_fetch_exec = instr_fetch_buffer;
  new_instr = 0;

    if(fetch_valid) begin     //instrukce z icache je valid

      if(!fetch_valid_buffer) begin

        fetch_valid_exec = fetch_valid;
        instr_fetch_exec = instr_fetch;

        new_instr = 1;

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

    if(nextPC <= 32'h0000008C)begin
    PC_reg <= PC;
    nextPC_reg <= nextPC;
    end

  end

end

  /*assign PC = stall_pc_delayed ? PC_reg : nextPC_reg;
  assign nextPC = stall_pc_delayed ? nextPC_reg : PCmux;*/

always_comb begin

  if(new_instr) PC = nextPC_reg;
  else PC = PC_reg;

  if(new_instr) nextPC = PCmux;
  else nextPC = nextPC_reg;

end

  //logika PC

  //stall logika
always_comb begin

  if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

end

always_comb begin

  if(fetch_valid_exec) begin

    if(stall_debug) begin
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
