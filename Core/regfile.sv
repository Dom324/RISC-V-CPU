module regfile(
  input logic clk, we,
  input logic  [31:0] wd,
  input logic [4:0] wa, ra1, ra2,
  output logic [31:0] rd1, rd2,
  input logic new_instr,
  //output logic [31:0] reg_rd1, reg_rd2,
  output logic rd1_rdy, rd2_rdy
);

  //logic [31:0] registers [31:0];			//32x32 bits wide registers

  logic [31:0] reg_rd1, reg_rd2;

always_comb begin

  if(ra1 == 5'b00000) rd1_rdy = 1;
  else begin

    if(new_instr) rd1_rdy = 0;
    else rd1_rdy = 1;

  end

  if(ra2 == 5'b00000) rd2_rdy = 1;
  else begin

    if(new_instr) rd2_rdy = 0;
    else rd2_rdy = 1;

  end

end

  /*assign rd1 = registers[ra1];
  assign rd2 = registers[ra2];

always_ff @ (posedge clk) begin

  if(we)
    if(wa != 0)
	    registers[wa] <= wd;
	  else
	    registers[0] <= 0;

end*/

always_comb begin

  if(ra1 == 5'b00000) rd1 = 0;
  else rd1 = reg_rd1;

  if(ra2 == 5'b00000) rd2 = 0;
  else rd2 = reg_rd2;

end

RAM256x32 regfile1(.RCLK_c(clk),
                      .RCLKE_c(1'b1),
                      .RE_c(1'b1),
                      .WCLK_c(clk),
                      .WCLKE_c(1'b1),
                      .WE_c(we),
                      .RADDR_c({3'b000, ra1}),
                      .WADDR_c({3'b000, wa}),
                      .MASK_IN(0),
                      .WDATA_IN(wd),
                      .RDATA_OUT(reg_rd1)
                      );

RAM256x32 regfile2(.RCLK_c(clk),
                      .RCLKE_c(1'b1),
                      .RE_c(1'b1),
                      .WCLK_c(clk),
                      .WCLKE_c(1'b1),
                      .WE_c(we),
                      .RADDR_c({3'b000, ra2}),
                      .WADDR_c({3'b000, wa}),
                      .MASK_IN(0),
                      .WDATA_IN(wd),
                      .RDATA_OUT(reg_rd2)
                      );


endmodule
