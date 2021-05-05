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

      if(funct7[5])	out = $signed(a) - $signed(b);
      else out = $signed(a) + $signed(b);

    end

	  3'b001:	begin

      out = $signed(a) <<  $signed(b[4:0]);
      /*case(b[4:0])
        5'b00000: out = a;
        5'b00001: out = a << 1;
        5'b00010: out = a << 2;
        5'b00011: out = a << 3;
        5'b00100: out = a << 4;
        5'b00101: out = a << 5;
        5'b00110: out = a << 6;
        5'b00111: out = a << 7;
        5'b01000: out = a << 8;
        5'b01001: out = a << 9;
        5'b01010: out = a << 10;
        5'b01011: out = a << 11;
        5'b01100: out = a << 12;
        5'b01101: out = a << 13;
        5'b01110: out = a << 14;
        5'b01111: out = a << 15;
        5'b10000: out = a << 16;
        5'b10001: out = a << 17;
        5'b10010: out = a << 18;
        5'b10011: out = a << 19;
        5'b10100: out = a << 20;
        5'b10101: out = a << 21;
        5'b10110: out = a << 22;
        5'b10111: out = a << 23;
        5'b11000: out = a << 24;
        5'b11001: out = a << 25;
        5'b11010: out = a << 26;
        5'b11011: out = a << 27;
        5'b11100: out = a << 28;
        5'b11101: out = a << 29;
        5'b11110: out = a << 30;
        5'b11111: out = a << 31;
      endcase*/
    end


    3'b010:	begin       //SLTI a SLT

      if( $signed(a) < $signed(b)) out = 32'd1;
		  else out = 32'd0;

    end

    3'b011:	begin       //SLTIU a SLTU

      if(a < b) out = 32'd1;
  		 else out = 32'd0;

    end

	  3'b100:	out = a ^ b;

	  3'b101:	begin

      if(funct7 == 7'b0000000) out = $signed(a) >> $signed(b[4:0]);
      else out = $signed(a) >>> $signed(b[4:0]);

    end

	  3'b110: out = a | b;

	  3'b111:	out = a & b;

    default: out = 0;

  endcase

end
endmodule
