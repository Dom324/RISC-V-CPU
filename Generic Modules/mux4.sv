module mux4
 #(parameter width = 1)
  (input logic[1:0] select,
  input logic  [width-1:0] a, b, c, d,
  output logic [width-1:0] out);

always_comb begin

out = 0;

    case(select)      // synopsys full_case parallel_case

      2'b00: out = a;
	    2'b01: out = b;
	    2'b10: out = c;
	    2'b11: out = d;

    endcase
  end
endmodule
