module decoder_4to16_inv(
  input logic [3:0] select,
  input logic [15:0] a,
  output logic out);

always_comb begin

out = 0;

  case(select)    // synopsys full_case parallel_case

    4'b0000: out = a[15];
	  4'b0001: out = a[14];
	  4'b0010: out = a[13];
	  4'b0011: out = a[12];
	  4'b0100: out = a[11];
	  4'b0101: out = a[10];
	  4'b0110: out = a[9];
	  4'b0111: out = a[8];
    4'b1000: out = a[7];
    4'b1001: out = a[6];
    4'b1010: out = a[5];
    4'b1011: out = a[4];
    4'b1100: out = a[3];
    4'b1101: out = a[2];
    4'b1110: out = a[1];
    4'b1111: out = a[0];

  endcase
end
endmodule
