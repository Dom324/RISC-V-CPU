module alu(
  input logic  [31:0] a, b,
  input logic [2:0] aluOp,
  input logic [6:0] funct7,
  output logic [31:0] out
);


always_comb begin

//defaultni hodnoty
  out = 0;

  case(aluOp)

    3'b000:	begin

      if(funct7[5])	out = a - b;
		  else			out = a + b;

    end

	  3'b001:	out = a << b[4:0];

	  3'b100:	out = a ^ b;

	  /*3'b101:	begin
      if(funct7 == 7'b0000000) out = a >> b[4:0];
		  else			out = a >>> b[4:0];
    end*/

	  3'b110:		out = a | b;

	  3'b111:		out = a & b;

    default: out = 0;

  endcase

end
endmodule
