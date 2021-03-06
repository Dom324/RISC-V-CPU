module keyboard(
  input logic CLK,
  input logic  keyboard_data, keyboard_clock, clean_key_buffer,
  output logic [7:0] pressed_key,
  output logic keyboard_valid,
  output logic [31:0] keyboard_scancode
);

  logic [7:0] buffer, scancode, ascii;
  logic is_valid, is_valid_reg, is_new, is_valid_transl;

  logic [31:0] scancode_reg;


  assign keyboard_valid = is_valid_reg;
  assign pressed_key = buffer;
  assign keyboard_scancode = scancode_reg;

always_ff @ (posedge CLK) begin

  if(is_new) scancode_reg <= {scancode_reg[23:0], scancode};
  else scancode_reg <= scancode_reg;

end

always_ff @ (posedge CLK) begin

  if(is_new) buffer <= ascii;
  else buffer <= buffer;

end

always_ff @ (posedge CLK) begin

  if(is_valid & is_new) is_valid_reg <= 1;
  else begin

    if(clean_key_buffer) is_valid_reg <= 0;
    else is_valid_reg <= is_valid_reg;

  end

end

always_comb begin

  if(scancode == 8'hf0) is_valid = 0;           //break kod
  else if(buffer == 8'hf0) is_valid = 0;        //break klavesa
  else is_valid = is_valid_transl;

end

  /*ps2_interface2 ps2(
                    .CLK(CLK),
                    .PS2_CLK(keyboard_clock),
                    .PS2_DATA(keyboard_data),
                    .TRIG_ARR(is_new),
                    .CODEWORD(CODEWORD)
                    );*/

  ps2_interface ps2(
                    .clk_cpu(CLK),
                    .clk_keyboard(keyboard_clock),
                    .data(keyboard_data),
                    .is_valid_out(is_new),
                    .scancode(scancode)
                    );

  scancode_to_ascii scancode_to_ascii(
                                    .scan_code(scancode),
                                    .ascii(ascii),
                                    .is_valid(is_valid_transl)
                                    );

endmodule
