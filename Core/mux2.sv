module mux2
 #(parameter width = 1)
  (input logic select,
  input logic  [width-1:0] a, b,
  output logic [width-1:0] out);
  
always_comb begin

  if(select)
    out = b;
  else
    out = a;

end
endmodule