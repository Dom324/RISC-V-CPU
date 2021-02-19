module bin_to_hex_ascii(
  input logic [3:0] in,
  output logic [7:0] out);

always_comb begin

out = 0;

case(in)
  0: out = 8'h30;
  1: out = 8'h31;
  2: out = 8'h32;
  3: out = 8'h33;
  4: out = 8'h34;
  5: out = 8'h35;
  6: out = 8'h36;
  7: out = 8'h37;
  8: out = 8'h38;
  9: out = 8'h39;
  10: out = 8'h41;
  11: out = 8'h42;
  12: out = 8'h43;
  13: out = 8'h44;
  14: out = 8'h45;
  15: out = 8'h46;
  default: out = 0;
endcase
  end
endmodule
