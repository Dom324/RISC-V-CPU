module shift_reg
 #(parameter width = 32)
 (input logic CLK, EN,
  input logic in,
  output logic [width-1:0] out
);

  logic [width-1:0] shift_register;

  assign out = shift_register;

always_ff @ (posedge CLK) begin

  if(EN) begin

    shift_register <= shift_register << 1;
    shift_register[0] <= in;

  end

end
endmodule
