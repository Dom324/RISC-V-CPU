module ascii_to_pixel(
  input reset, end_of_line, end_of_frame,
  input [7:0] ascii,
  output reg [15:0] pixel_row
);

  reg [4:0] row;


always @(posedge end_of_line) begin

if(!end_of_frame) begin
    if (row == 5'b10011)
      row = 5'b00000;
    else row = row + 1;
end
else row = 0;

end

always #1 begin

  case(ascii)

  8'h41: begin                   //A
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hFFF0;
    9: pixel_row = 16'hFFF0;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end


  8'h42: begin                   //B
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFC0;
    3: pixel_row = 16'hFFC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hFFC0;
    7: pixel_row = 16'hFFC0;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'hFFC0;
    13: pixel_row = 16'hFFC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h43: begin                   //C
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC000;
    7: pixel_row = 16'hC000;
    8: pixel_row = 16'hC000;
    9: pixel_row = 16'hC000;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h44: begin                   //D
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFF00;
    3: pixel_row = 16'hFF00;
    4: pixel_row = 16'hC0C0;
    5: pixel_row = 16'hC0C0;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC0C0;
    11: pixel_row = 16'hC0C0;
    12: pixel_row = 16'hFF00;
    13: pixel_row = 16'hFF00;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h45: begin                   //E
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFF0;
    3: pixel_row = 16'hFFF0;
    4: pixel_row = 16'hC000;
    5: pixel_row = 16'hC000;
    6: pixel_row = 16'hFFC0;
    7: pixel_row = 16'hFFC0;
    8: pixel_row = 16'hC000;
    9: pixel_row = 16'hC000;
    10: pixel_row = 16'hC000;
    11: pixel_row = 16'hC000;
    12: pixel_row = 16'hFFF0;
    13: pixel_row = 16'hFFF0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h46: begin                   //F
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFF0;
    3: pixel_row = 16'hFFF0;
    4: pixel_row = 16'hC000;
    5: pixel_row = 16'hC000;
    6: pixel_row = 16'hFFC0;
    7: pixel_row = 16'hFFC0;
    8: pixel_row = 16'hC000;
    9: pixel_row = 16'hC000;
    10: pixel_row = 16'hC000;
    11: pixel_row = 16'hC000;
    12: pixel_row = 16'hC000;
    13: pixel_row = 16'hC000;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h47: begin                   //G
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC000;
    7: pixel_row = 16'hC000;
    8: pixel_row = 16'hC3F0;
    9: pixel_row = 16'hC3F0;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h48: begin                   //H
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hFFF0;
    7: pixel_row = 16'hFFF0;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h49: begin                   //I
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FF0;
    3: pixel_row = 16'h3FF0;
    4: pixel_row = 16'h0300;
    5: pixel_row = 16'h0300;
    6: pixel_row = 16'h0300;
    7: pixel_row = 16'h0300;
    8: pixel_row = 16'h0300;
    9: pixel_row = 16'h0300;
    10: pixel_row = 16'h0300;
    11: pixel_row = 16'h0300;
    12: pixel_row = 16'h3FF0;
    13: pixel_row = 16'h3FF0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4a: begin                   //J
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h0030;
    3: pixel_row = 16'h0030;
    4: pixel_row = 16'h0030;
    5: pixel_row = 16'h0030;
    6: pixel_row = 16'h0030;
    7: pixel_row = 16'h0030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4b: begin                   //K
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC0C0;
    3: pixel_row = 16'hC0C0;
    4: pixel_row = 16'hC300;
    5: pixel_row = 16'hC300;
    6: pixel_row = 16'hFC00;
    7: pixel_row = 16'hFC00;
    8: pixel_row = 16'hC300;
    9: pixel_row = 16'hC300;
    10: pixel_row = 16'hC0C0;
    11: pixel_row = 16'hC0C0;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4c: begin                   //L
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC000;
    3: pixel_row = 16'hC000;
    4: pixel_row = 16'hC000;
    5: pixel_row = 16'hC000;
    6: pixel_row = 16'hC000;
    7: pixel_row = 16'hC000;
    8: pixel_row = 16'hC000;
    9: pixel_row = 16'hC000;
    10: pixel_row = 16'hC000;
    11: pixel_row = 16'hC000;
    12: pixel_row = 16'hFFF0;
    13: pixel_row = 16'hFFF0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4d: begin                   //M
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hF0F0;
    5: pixel_row = 16'hF0F0;
    6: pixel_row = 16'hCF30;
    7: pixel_row = 16'hCF30;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4e: begin                   //N
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hF030;
    5: pixel_row = 16'hF030;
    6: pixel_row = 16'hCC30;
    7: pixel_row = 16'hCC30;
    8: pixel_row = 16'hC330;
    9: pixel_row = 16'hC330;
    10: pixel_row = 16'hC0F0;
    11: pixel_row = 16'hC0F0;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h4f: begin                   //O
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h50: begin                   //P
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFC0;
    3: pixel_row = 16'hFFC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hFFC0;
    9: pixel_row = 16'hFFC0;
    10: pixel_row = 16'hC000;
    11: pixel_row = 16'hC000;
    12: pixel_row = 16'hC000;
    13: pixel_row = 16'hC000;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h51: begin                   //Q
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hCC30;
    9: pixel_row = 16'hCC30;
    10: pixel_row = 16'hC330;
    11: pixel_row = 16'hC330;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h52: begin                   //R
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFC0;
    3: pixel_row = 16'hFFC0;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hFFC0;
    9: pixel_row = 16'hFFC0;
    10: pixel_row = 16'hC0C0;
    11: pixel_row = 16'hC0C0;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h53: begin                   //S
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'h3FC0;
    3: pixel_row = 16'h3FC0;
    4: pixel_row = 16'hC000;
    5: pixel_row = 16'hC000;
    6: pixel_row = 16'h3FC0;
    7: pixel_row = 16'h3FC0;
    8: pixel_row = 16'h0030;
    9: pixel_row = 16'h0030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h54: begin                   //T
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFFC;
    3: pixel_row = 16'hFFFC;
    4: pixel_row = 16'h0300;
    5: pixel_row = 16'h0300;
    6: pixel_row = 16'h0300;
    7: pixel_row = 16'h0300;
    8: pixel_row = 16'h0300;
    9: pixel_row = 16'h0300;
    10: pixel_row = 16'h0300;
    11: pixel_row = 16'h0300;
    12: pixel_row = 16'h0300;
    13: pixel_row = 16'h0300;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h55: begin                   //U
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hC030;
    11: pixel_row = 16'hC030;
    12: pixel_row = 16'h3FC0;
    13: pixel_row = 16'h3FC0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h56: begin                   //V
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'h30C0;
    11: pixel_row = 16'h30C0;
    12: pixel_row = 16'h0F00;
    13: pixel_row = 16'h0F00;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h57: begin                   //W
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'hC030;
    5: pixel_row = 16'hC030;
    6: pixel_row = 16'hC030;
    7: pixel_row = 16'hC030;
    8: pixel_row = 16'hC030;
    9: pixel_row = 16'hC030;
    10: pixel_row = 16'hCF30;
    11: pixel_row = 16'hCF30;
    12: pixel_row = 16'h30C0;
    13: pixel_row = 16'h30C0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h58: begin                   //X
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC030;
    3: pixel_row = 16'hC030;
    4: pixel_row = 16'h30C0;
    5: pixel_row = 16'h30C0;
    6: pixel_row = 16'h0F00;
    7: pixel_row = 16'h0F00;
    8: pixel_row = 16'h0F00;
    9: pixel_row = 16'h0F00;
    10: pixel_row = 16'h30C0;
    11: pixel_row = 16'h30C0;
    12: pixel_row = 16'hC030;
    13: pixel_row = 16'hC030;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h59: begin                   //Y
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hC00C;
    3: pixel_row = 16'hC00C;
    4: pixel_row = 16'h3030;
    5: pixel_row = 16'h3030;
    6: pixel_row = 16'h0CC0;
    7: pixel_row = 16'h0CC0;
    8: pixel_row = 16'h0300;
    9: pixel_row = 16'h0300;
    10: pixel_row = 16'h0300;
    11: pixel_row = 16'h0300;
    12: pixel_row = 16'h0300;
    13: pixel_row = 16'h0300;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end

  8'h5a: begin                   //Z
  case(row)
    0: pixel_row = 16'h0000;
    1: pixel_row = 16'h0000;
    2: pixel_row = 16'hFFF0;
    3: pixel_row = 16'hFFF0;
    4: pixel_row = 16'h00C0;
    5: pixel_row = 16'h00C0;
    6: pixel_row = 16'h0300;
    7: pixel_row = 16'h0300;
    8: pixel_row = 16'h0C00;
    9: pixel_row = 16'h0C00;
    10: pixel_row = 16'h3000;
    11: pixel_row = 16'h3000;
    12: pixel_row = 16'hFFF0;
    13: pixel_row = 16'hFFF0;
    14: pixel_row = 16'h0000;
    15: pixel_row = 16'h0000;
    16: pixel_row = 16'h0000;
    17: pixel_row = 16'h0000;
    18: pixel_row = 16'h0000;
    19: pixel_row = 16'h0000;
  default: pixel_row = 0;
  endcase
  end


8'hff: begin			//debug
  case(row)
  0: pixel_row = 16'hffff;
  1: pixel_row = 16'haaab;
  2: pixel_row = 16'hd555;
  3: pixel_row = 16'haaab;
  4: pixel_row = 16'hd555;
  5: pixel_row = 16'haaab;
  6: pixel_row = 16'hd555;
  7: pixel_row = 16'haaab;
  8: pixel_row = 16'hd555;
  9: pixel_row = 16'haaab;
  10: pixel_row = 16'hd555;
  11: pixel_row = 16'haaab;
  12: pixel_row = 16'hd555;
  13: pixel_row = 16'haaab;
  14: pixel_row = 16'hd555;
  15: pixel_row = 16'haaab;
  16: pixel_row = 16'hd555;
  17: pixel_row = 16'haaab;
  18: pixel_row = 16'hd555;
  19: pixel_row = 16'hffff;
default: pixel_row = 0;
endcase
end

8'h30: begin                   //0
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC0F0;
  5: pixel_row = 16'hC0F0;
  6: pixel_row = 16'hC330;
  7: pixel_row = 16'hC330;
  8: pixel_row = 16'hCC30;
  9: pixel_row = 16'hCC30;
  10: pixel_row = 16'hF030;
  11: pixel_row = 16'hF030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h31: begin                   //1
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3C00;
  3: pixel_row = 16'h3C00;
  4: pixel_row = 16'hCC00;
  5: pixel_row = 16'hCC00;
  6: pixel_row = 16'h0C00;
  7: pixel_row = 16'h0C00;
  8: pixel_row = 16'h0C00;
  9: pixel_row = 16'h0C00;
  10: pixel_row = 16'h0C00;
  11: pixel_row = 16'h0C00;
  12: pixel_row = 16'hFFC0;
  13: pixel_row = 16'hFFC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h32: begin                   //2
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC030;
  5: pixel_row = 16'hC030;
  6: pixel_row = 16'h0030;
  7: pixel_row = 16'h0030;
  8: pixel_row = 16'h3FC0;
  9: pixel_row = 16'h3FC0;
  10: pixel_row = 16'hC000;
  11: pixel_row = 16'hC000;
  12: pixel_row = 16'hFFF0;
  13: pixel_row = 16'hFFF0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h33: begin                   //3
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC030;
  5: pixel_row = 16'hC030;
  6: pixel_row = 16'h03C0;
  7: pixel_row = 16'h03C0;
  8: pixel_row = 16'h0030;
  9: pixel_row = 16'h0030;
  10: pixel_row = 16'hC030;
  11: pixel_row = 16'hC030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h34: begin                   //4
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h0300;
  3: pixel_row = 16'h0300;
  4: pixel_row = 16'h0F00;
  5: pixel_row = 16'h0F00;
  6: pixel_row = 16'h3300;
  7: pixel_row = 16'h3300;
  8: pixel_row = 16'hC300;
  9: pixel_row = 16'hC300;
  10: pixel_row = 16'hFFF0;
  11: pixel_row = 16'hFFF0;
  12: pixel_row = 16'h0300;
  13: pixel_row = 16'h0300;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h35: begin                   //5
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'hFFF0;
  3: pixel_row = 16'hFFF0;
  4: pixel_row = 16'hC000;
  5: pixel_row = 16'hC000;
  6: pixel_row = 16'hFFC0;
  7: pixel_row = 16'hFFC0;
  8: pixel_row = 16'h0030;
  9: pixel_row = 16'h0030;
  10: pixel_row = 16'hC030;
  11: pixel_row = 16'hC030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h36: begin                   //6
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC000;
  5: pixel_row = 16'hC000;
  6: pixel_row = 16'hFFC0;
  7: pixel_row = 16'hFFC0;
  8: pixel_row = 16'hC030;
  9: pixel_row = 16'hC030;
  10: pixel_row = 16'hC030;
  11: pixel_row = 16'hC030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h37: begin                   //7
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'hFFF0;
  3: pixel_row = 16'hFFF0;
  4: pixel_row = 16'h0030;
  5: pixel_row = 16'h0030;
  6: pixel_row = 16'h00C0;
  7: pixel_row = 16'h00C0;
  8: pixel_row = 16'h0300;
  9: pixel_row = 16'h0300;
  10: pixel_row = 16'h0C00;
  11: pixel_row = 16'h0C00;
  12: pixel_row = 16'h0C00;
  13: pixel_row = 16'h0C00;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h38: begin                   //8
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC030;
  5: pixel_row = 16'hC030;
  6: pixel_row = 16'h3FC0;
  7: pixel_row = 16'h3FC0;
  8: pixel_row = 16'hC030;
  9: pixel_row = 16'hC030;
  10: pixel_row = 16'hC030;
  11: pixel_row = 16'hC030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

8'h39: begin                   //9
case(row)
  0: pixel_row = 16'h0000;
  1: pixel_row = 16'h0000;
  2: pixel_row = 16'h3FC0;
  3: pixel_row = 16'h3FC0;
  4: pixel_row = 16'hC030;
  5: pixel_row = 16'hC030;
  6: pixel_row = 16'hC030;
  7: pixel_row = 16'hC030;
  8: pixel_row = 16'h3FF0;
  9: pixel_row = 16'h3FF0;
  10: pixel_row = 16'h0030;
  11: pixel_row = 16'h0030;
  12: pixel_row = 16'h3FC0;
  13: pixel_row = 16'h3FC0;
  14: pixel_row = 16'h0000;
  15: pixel_row = 16'h0000;
  16: pixel_row = 16'h0000;
  17: pixel_row = 16'h0000;
  18: pixel_row = 16'h0000;
  19: pixel_row = 16'h0000;
default: pixel_row = 0;
endcase
end

	default: begin

	  pixel_row = 0;

	end


  endcase
  end
endmodule
