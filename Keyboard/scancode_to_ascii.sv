module scancode_to_ascii(
  input logic [7:0] scan_code,
  output logic [7:0] ascii,
  output logic is_valid
);

always_comb begin

ascii = 0;
is_valid = 1;

  case(scan_code)

  8'h1c: ascii = 8'h41;                   //A
  8'h32: ascii = 8'h42;                   //B
  8'h21: ascii = 8'h43;                   //C
  8'h23: ascii = 8'h44;                   //D
  8'h24: ascii = 8'h45;                   //E
  8'h2b: ascii = 8'h46;                   //F
  8'h34: ascii = 8'h47;                   //G
  8'h33: ascii = 8'h48;                   //H
  8'h43: ascii = 8'h49;                   //I
  8'h3b: ascii = 8'h4a;                   //J
  8'h42: ascii = 8'h4b;                   //K
  8'h4b: ascii = 8'h4c;                   //L
  8'h3a: ascii = 8'h4d;                   //M
  8'h31: ascii = 8'h4e;                   //N
  8'h44: ascii = 8'h4f;                   //O
  8'h4d: ascii = 8'h50;                   //P
  8'h15: ascii = 8'h51;                   //Q
  8'h2d: ascii = 8'h52;                   //R
  8'h1b: ascii = 8'h53;                   //S
  8'h2c: ascii = 8'h54;                   //T
  8'h3c: ascii = 8'h55;                   //U
  8'h2a: ascii = 8'h56;                   //V
  8'h1d: ascii = 8'h57;                   //W
  8'h22: ascii = 8'h58;                   //X
  8'h35: ascii = 8'h59;                   //Y
  8'h1a: ascii = 8'h5a;                   //Z
  //8'hff: ascii = 8'h00;			//debug
  8'h29: ascii = 8'h20;                   //SPACE
  8'h5a: ascii = 8'h03;                   //ENTER
  8'h66: ascii = 8'h08;                   //BACKSPACE

  8'h70: ascii = 8'h30;                   //0
  8'h69: ascii = 8'h31;                   //1
  8'h72: ascii = 8'h32;                   //2
  8'h7a: ascii = 8'h33;                   //3
  8'h6b: ascii = 8'h34;                   //4
  8'h73: ascii = 8'h35;                   //5
  8'h74: ascii = 8'h36;                   //6
  8'h6c: ascii = 8'h37;                   //6
  8'h75: ascii = 8'h38;                   //8
  8'h7d: ascii = 8'h39;                   //9

  8'h54: ascii = 8'h28;                   //(
  8'h55: ascii = 8'h3d;                   //=
  8'h5b: ascii = 8'h29;                   //)

  8'h41: ascii = 8'h2c;                   //,
  8'h4a: ascii = 8'h2f;                   // /
  8'h71: ascii = 8'h2e;                   //.
  8'h7c: ascii = 8'h2a;                   //*
  8'h7b: ascii = 8'h2d;                   //-
  8'h79: ascii = 8'h2b;                   //+


  8'hf0: ascii = 8'hf0;                   //key break
	default: begin
    ascii = 0;
    is_valid = 0;
  end


  endcase
end
endmodule
