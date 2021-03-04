module dff(
  input logic  clk, data, resetn,
  output logic q
);


always_ff @ (posedge clk) begin

  if(resetn)
    q <= data;
  else
    q <= 0;

end

endmodule
