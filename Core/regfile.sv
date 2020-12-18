module regfile(
  input logic clk, we,
  input logic  [31:0] wd,
  input logic [4:0] wa, ra1, ra2,
  output logic [31:0] rd1, rd2
);

  logic [31:0] registers [31:0];			//32x32 bits wide registers

  assign rd1 = registers[ra1];
  assign rd2 = registers[ra2];

always_ff @ (posedge clk) begin

  if(we)
    if(wa != 0)
	    registers[wa] <= wd;
	  else
	    registers[0] <= 0;

end
endmodule
