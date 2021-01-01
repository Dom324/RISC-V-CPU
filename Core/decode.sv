module decode(
  input logic  [31:0] instr,
  output logic [2:0] funct3,
  output logic [6:0] funct7,
  output logic [6:0] op,
  output logic [4:0] rd, rs1, rs2,
  output logic [31:0] imm,
  output logic [2:0] instrType
);

  assign op = instr[6:0];

always_comb begin

//defaultni hodnoty
rs1 = 0;
rs2 = 0;
rd = 0;
funct3 = 0;
funct7 = 0;
imm = 0;
instrType = 3'b000;
//defaultni hodnoty

  case(instr[6:0])            // synopsys parallel_case

    7'b0110111: begin			//U-type instruction

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

  endcase
end
endmodule
