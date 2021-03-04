module branch_unit(
  input logic  [31:0] rd1, rd2,
  input logic [2:0] funct3,
  output logic branch_taken
);


always_comb begin

  case(funct3)

    3'b000:	begin       //BEQ

      if(rd1 == rd2)	branch_taken = 1;
		  else branch_taken = 0;

    end

	  3'b001:	begin      //BNE

      if(rd1 == rd2) branch_taken = 0;
		  else branch_taken = 1;

    end

	  3'b100: begin      //BLT

      if(rd1 < rd2) branch_taken = 1;
		  else branch_taken = 0;

    end

    3'b101: begin      //BGE

      if(rd1 >= rd2) branch_taken = 1;
		  else branch_taken = 0;

    end

	  3'b110: begin      //BLTU

      if($signed(rd1) < $signed(rd2)) branch_taken = 1;
		  else branch_taken = 0;

    end

	  3'b111: begin      //BGEU

      if($signed(rd1) >= $signed(rd2)) branch_taken = 1;
		  else branch_taken = 0;

    end

    default: branch_taken = 0;

  endcase

end
endmodule
