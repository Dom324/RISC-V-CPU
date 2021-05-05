`define NOTHING 2'b00
`define READING 2'b01
`define WRITING 2'b10
`define DONE 2'b11

module load_store_unit(
  input logic CLK, resetn,
  input logic new_instr,
  input logic memory_en, mem_read_data_valid, mem_write_ready, mem_adress_valid,
  input logic [1:0] store_size,
  input logic [2:0] funct3,
  input logic [31:0] mem_read_data, rd2,

  output logic [31:0] mem_write_data, agu_read_data,
  output logic memory_en_out,
  output logic load_store_unit_rdy,
  output logic load_store_rdata_valid,
  output logic [1:0] ld_state
);

  logic [1:0] state, nextState, newState;
  logic [31:0] agu_read_data_reg;

  assign ld_state = state;

always_ff @ (posedge CLK) begin

  if(!resetn) begin
    state <= 0;
  end
  else state <= nextState;

end

always_comb begin

  case(state)

    `NOTHING: begin
      if(memory_en) load_store_unit_rdy = 0;
      else load_store_unit_rdy = 1;
    end

    `READING: begin

      if(mem_read_data_valid) load_store_unit_rdy = 1;
      else load_store_unit_rdy = 0;

    end

    `WRITING: load_store_unit_rdy = 0;

    `DONE: begin

      if(new_instr) begin
        if(memory_en) load_store_unit_rdy = 0;
        else load_store_unit_rdy = 1;
      end
      else load_store_unit_rdy = 1;

    end

    default: load_store_unit_rdy = 1;
  endcase

end




always_comb begin

  if(new_instr & memory_en) begin

    if(store_size == 2'b11) newState = `READING;
    else newState = `WRITING;

  end
  else newState = `NOTHING;

  case(state)
    `NOTHING: nextState = newState;

    `READING: begin
      if(mem_read_data_valid) nextState = `DONE;
      else nextState = `READING;
    end

    `WRITING: begin
      if(mem_write_ready) nextState = `DONE;
      else nextState = `WRITING;
    end

    `DONE: begin

      if(new_instr) begin
        if(memory_en) begin
          if(store_size == 2'b11) nextState = `READING;
          else nextState = `WRITING;
        end
          else nextState = `NOTHING;
      end
      else nextState = `DONE;

    end

    default: nextState = `NOTHING;
  endcase

end

always_comb begin

  case(state)
    `NOTHING: memory_en_out = 0;
    //DONE: memory_en_out = 0;
    `READING: begin

      /*if(mem_read_data_valid) memory_en_out = 0;
      else memory_en_out = mem_adress_valid;*/
      memory_en_out = mem_adress_valid;

    end
    `WRITING: memory_en_out = mem_adress_valid;
    `DONE: memory_en_out = 0;
    default: memory_en_out = 0;
  endcase

end

always_comb begin

  case(funct3)
    3'b000: mem_write_data = {{24{1'b0}}, rd2[7:0]};				//instrukce SB, do pameti se uklada jeden Byte
    3'b001: mem_write_data = {{16{1'b0}}, rd2[15:0]};				//instrukce SH, do pameti se ukladaji dva Byty
    3'b010: mem_write_data = rd2;									          //instrukce SW, do pameti se ukladaji ctyri Byty
    default: mem_write_data = 0;
  endcase

end

always_ff @ (posedge CLK) begin

  agu_read_data_reg <= agu_read_data;

  if(state == `READING) begin

    if(mem_read_data_valid) load_store_rdata_valid <= 1;

  end
  else load_store_rdata_valid <= 0;

end

always_comb begin

  agu_read_data = agu_read_data_reg;

  if(mem_read_data_valid && (state == `READING) ) begin

    case(funct3)
      3'b000: agu_read_data = {{24{mem_read_data[7]}}, mem_read_data[7:0]};				//instrukce LB, z pameti se nacita jeden Byte, dela se sign extension
      3'b001: agu_read_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]};			//instrukce LH, z pameti se nacitaji dva Byty, dela se sign extension
      3'b010: agu_read_data = mem_read_data;											                //instrukce LW, z pameti se nacita ctyri Byty
      3'b100: agu_read_data = {{24{1'b0}}, mem_read_data[7:0]};						     	  //instrukce LBU, z pameti se nacita jeden Byte, nedela se sign extension
      3'b101: agu_read_data = {{16{1'b0}}, mem_read_data[15:0]};						      //instrukce LHU, z pameti se nacitaji dva Byty, nedela se sign extension
      default: agu_read_data = 0;
    endcase

  end
  else agu_read_data = agu_read_data_reg;

end

endmodule
