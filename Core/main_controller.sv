module main_controller(
  input CLK,
  input resetn,
  input controller_stall,
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

  logic fetch_valid_buffer, fetch_valid_buffer_next, controller_stall_buffer;
  logic [31:0] instr_fetch_buffer, instr_fetch_buffer_next;
  logic [31:0] PC_reg, nextPC_reg;

  logic stall_reg;

always_ff @ (posedge CLK) begin

  controller_stall_buffer <= controller_stall;

  if(!resetn) begin
    fetch_valid_buffer <= 0;
    instr_fetch_buffer <= 0;
  end
  else begin

    fetch_valid_buffer <= fetch_valid_buffer_next;
    instr_fetch_buffer <= instr_fetch_buffer_next;

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

fetch_valid_exec = fetch_valid_buffer;
instr_fetch_exec = instr_fetch_buffer;

  if(fetch_valid) begin     //instrukce z icache je valid

    if(!fetch_valid_buffer) begin

      fetch_valid_exec = fetch_valid;
      instr_fetch_exec = instr_fetch;

    end

  end

end


always_ff @ (posedge CLK) begin

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

    if(controller_stall_buffer) stall_pc = 1;
    else stall_pc = 0;

  end else stall_pc = 1;


  if(fetch_valid_exec) begin

    if(controller_stall) begin
      stall_reg = 1;
      fetch_enable = 0;
    end
    else begin
      stall_reg = 0;
      fetch_enable = 1;
    end

  end
  else begin
    stall_reg = 1;
    fetch_enable = 1;
  end

  if(stall_reg == 1) we_reg = 0;
	else we_reg = we_reg_controller;

end
  //stall logika




endmodule
