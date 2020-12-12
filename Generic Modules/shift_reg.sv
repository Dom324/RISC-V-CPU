module shift_reg
 #(parameter width = 32)
  (input logic CLK, EN,
  input logic in,
  output logic [width-1:0] out
);

  logic shift_reg[width-1:0];

  assign out = shift_reg;

always_ff @ (posedge CLK) begin

  if(EN) begin

    shift_reg <= shift_reg << 1;
    shift_reg[0] <= in;

  end
  else shift_reg <= shift_reg;

end
endmodule
