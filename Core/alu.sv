module alu(
  input logic  [31:0] a, b,
  input logic [2:0] funct3,
  input logic [6:0] funct7,
  output logic [31:0] out
);
  
  
always_comb begin

  case(funct3)
  
    3'b000:		if(funct7[5])	out = a - b;
				else			out = a + b;
				
	3'b001:		out = a << b[4:0];
	
	
	3'b100:		out = a ^ b;
	3'b101:		if(funct7 == 7'b0000000) out = a >> b[4:0];
				else			out = a >>> b[4:0];
	3'b110:		out = a | b;
	3'b111:		out = a & b;
    default:	out = 0;
  endcase
  end
endmodule