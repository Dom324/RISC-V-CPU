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
  output logic stall_pc,
  output logic we_reg,
  output logic fetch_valid_exec
  );

  logic fetch_valid_buffer, fetch_valid_buffer_next, decoder_stall_buffer;
  logic [31:0] instr_fetch_buffer, instr_fetch_buffer_next;
  logic [31:0] PC_reg, nextPC_reg;

  logic stall_reg, stall_pc_delayed;

always_ff @ (posedge CLK, negedge resetn) begin

  if(!resetn) begin
    fetch_valid_buffer <= 0;
    instr_fetch_buffer <= 0;
  end
  else begin

    fetch_valid_buffer <= fetch_valid_buffer_next;
    instr_fetch_buffer <= instr_fetch_buffer_next;
    decoder_stall_buffer <= decoder_stall & fetch_valid_exec;

  end
end


always_comb begin

  fetch_valid_buffer_next = fetch_valid_buffer;
  instr_fetch_buffer_next = instr_fetch_buffer;

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

    fetch_valid_buffer_next = fetch_valid_buffer;
    instr_fetch_buffer_next = instr_fetch_buffer;

  end
  else begin
    fetch_valid_buffer_next = 0;
  end

end

end

always_comb begin

  fetch_valid_exec = fetch_valid_buffer;
  instr_fetch_exec = instr_fetch_buffer;

    if(fetch_valid) begin     //instrukce z icache je valid

      if(!fetch_valid_buffer) begin

        fetch_valid_exec = fetch_valid;
        instr_fetch_exec = instr_fetch;

      end

    end

end


always_ff @ (posedge CLK, negedge resetn) begin

  if(!resetn) begin
    PC_reg <= 32'h00000FFC;
    nextPC_reg <= 32'h00001000;
  end
  else begin

    //if(!stall_pc & (nextPC <= 32'h00000008))
      //PC <= nextPC;

    PC_reg <= PC;
    nextPC_reg <= nextPC;

  end

end

  assign PC = stall_pc_delayed ? PC_reg : nextPC_reg;
  assign nextPC = stall_pc_delayed ? nextPC_reg : PCmux;

/*always_comb begin

  if(stall_pc_delayed) PC = PC_reg;
  else PC = nextPC_reg;

  if(stall_pc_delayed) nextPC = nextPC_reg;
  else nextPC = PCmux;

end*/

  //logika PC

  //stall logika

always_comb begin

  if(fetch_valid_exec) begin

    if(decoder_stall_buffer) stall_pc_delayed = 1;
    else stall_pc_delayed = 0;

  end else stall_pc_delayed = 1;

end

always_comb begin

  if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

end

always_comb begin

  if(fetch_valid_exec) begin

    if(decoder_stall) begin
      stall_pc = 1;
      stall_reg = 1;
      fetch_enable = 0;
    end
    else begin
      stall_pc = 0;
      stall_reg = 0;
      fetch_enable = 1;
    end

  end
  else begin
    stall_pc = 1;
    stall_reg = 1;
    fetch_enable = 1;
  end

end
  //stall logika




endmodule
