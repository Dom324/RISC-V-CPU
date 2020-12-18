module decoder_3to8(
  input logic [2:0] select,
  input logic [7:0] a,
  output logic out);

always_comb begin

out = 0;

  case(select)      // synopsys full_case parallel_case

    3'b000: out = a[0];
	  3'b001: out = a[1];
	  3'b010: out = a[2];
	  3'b011: out = a[3];
	  3'b100: out = a[4];
	  3'b101: out = a[5];
	  3'b110: out = a[6];
	  3'b111: out = a[7];

  endcase
end
endmodule
