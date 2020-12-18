module dff(
  input logic  clk, data, reset,
  output logic q
);


always_ff @ (posedge clk) begin

  if(!reset)
    q <= data;
  else
    q <= 0;

end

endmodule
