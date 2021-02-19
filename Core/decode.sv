module decode(
  input logic  [31:0] instr,
  output logic [2:0] funct3, aluOp,
  output logic [6:0] funct7,
  output logic [6:0] op,
  output logic [4:0] rd, rs1, rs2,
  output logic [31:0] imm,
  output logic [2:0] instrType,
  output logic stall,
  input logic mem_write_ready, mem_read_data_valid
);

  assign op = instr[6:0];
  logic unknown_instr;

always_comb begin

  if(op == 7'b0000011) begin	//Load instruction

      if(mem_read_data_valid) stall = 0;
      else stall = 1;

  end
  else if(instrType == 3'b101) begin			//S-type instruction

    if(mem_write_ready) stall = 0;
    else stall = 1;

  end
  else if(unknown_instr == 1) stall = 1;
  else stall = 0;

end

always_comb begin

  case(instr[6:0])

    7'b0110111, 7'b0010111, 7'b1101111, 7'b1100011, 7'b1100111, 7'b0000011,
    7'b0010011, 7'b0001111, 7'b1110011, 7'b0100011, 7'b0110011: unknown_instr = 0;

    default: unknown_instr = 1;

  endcase
  
end

always_comb begin

//defaultni hodnoty
rs1 = 0;
rs2 = 0;
rd = 0;
funct3 = 0;
funct7 = 0;
imm = 0;
instrType = 3'b000;
aluOp = funct3;
//defaultni hodnoty

  case(instr[6:0])

    7'b0110111, 7'b0010111: begin			//U-type instruction

	    rd = instr[11:7];
      imm = {instr[31:12], 12'h000};
      instrType = 3'b001;

      rs1 = 5'b00000;
      rs2 = 5'b00000;
      funct3 = 3'b000;
	    funct7 = 7'b0000000;
    end

    7'b1101111: begin						//J-type instruction

      rd = instr[11:7];
      imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	    instrType = 3'b010;

      rs1 = 5'b00000;
      rs2 = 5'b00000;
      funct3 = 3'b000;
	    funct7 = 7'b0000000;
    end

    7'b1100011: begin						//B-type instruction

      rs1 = instr[19:15];
      rs2 = instr[24:20];
      funct3 = instr[14:12];
      imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
	    instrType = 3'b011;

      rd = 5'b00000;
	    funct7 = 7'b0000000;
    end

    7'b1100111, 7'b0000011, 7'b0010011, 7'b0001111, 7'b1110011: begin		//I-type instruction

	    rd = instr[11:7];
      rs1 = instr[19:15];
      funct3 = instr[14:12];
      imm = { {21{instr[31]}}, instr[30:20] };
	    instrType = 3'b100;

      rs2 = 5'b00000;
	    funct7 = 7'b0000000;
    end

    7'b0100011: begin						//S-type instruction

      rs1 = instr[19:15];
      rs2 = instr[24:20];
      funct3 = instr[14:12];
      imm = { {21{instr[31]}}, instr[30:25], instr[11:7] };
	    instrType = 3'b101;
      aluOp = 3'b000;

      rd = 5'b00000;
	    funct7 = 7'b0000000;
    end

    7'b0110011: begin			//R-type instruction

      rs1 = instr[19:15];
      rs2 = instr[24:20];
	    rd = instr[11:7];
      funct3 = instr[14:12];
	    funct7 = instr[31:25];
	    instrType = 3'b110;

      imm = 0;
    end

    default: begin

      rs1 = 0;
      rs2 = 0;
      rd = 0;
      funct3 = 0;
      funct7 = 0;
      imm = 0;
      instrType = 3'b000;
      aluOp = funct3;

    end

  endcase
end
endmodule
