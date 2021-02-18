module keyboard(
  input logic CLK,
  input logic  keyboard_data, keyboard_clock, clean_key_buffer,
  output logic [7:0] pressed_key
);

  logic [7:0] buffer, CODEWORD, ascii;
  logic is_valid;

  assign pressed_key = buffer;

  always_ff @ (posedge CLK) begin

    if(is_valid) buffer <= ascii;
    else begin

      if(clean_key_buffer) buffer <= 0;
      else buffer <= buffer;

    end

  end


  ps2_interface2 ps2(
                    .CLK(CLK),
                    .PS2_CLK(keyboard_clock),
                    .PS2_DATA(keyboard_data),
                    .TRIG_ARR(is_valid),
                    .CODEWORD(CODEWORD)
                    );

  scancode_to_ascii scancode_to_ascii(
                                    .scan_code(CODEWORD),
                                    .ascii(ascii)
                                    );

endmodule
