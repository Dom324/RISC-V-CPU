module ascii_to_pixel(
  input logic end_of_line,
  input logic  [7:0] ascii,
  output logic [15:0] pixel_row
);
  
  logic [4:0] row;
  
  initial row = 0;

always_ff @(posedge end_of_line) begin

  if(end_of_line) begin
    if (row == 5'b10011)
      row <= 5'b00000;
    else row <= row + 1;
  end
	
end

always_comb begin

  case(ascii)
  
    8'h41: begin			//A
	  case(row)
	    1: pixel_row = 0;
		2: pixel_row = 0;
		3: pixel_row = 16'h0000;
		4: pixel_row = 16'h0000;
		5: pixel_row = 16'h3FC0;
		6: pixel_row = 16'h3FC0;
		7: pixel_row = 16'hC030;
		8: pixel_row = 16'hC030;
		9: pixel_row = 16'hC030;
		10: pixel_row = 16'hC030;
		11: pixel_row = 16'hFFF0;
		12: pixel_row = 16'hFFF0;
		13: pixel_row = 16'hC030;
		14: pixel_row = 16'hC030;
		15: pixel_row = 16'hC030;
		16: pixel_row = 16'hC030;
		17: pixel_row = 16'h0000;
		18: pixel_row = 16'h0000;
		19: pixel_row = 0;
		20: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	8'h48: begin			//H
	  case(row)
	    1: pixel_row = 0;
		2: pixel_row = 0;
		3: pixel_row = 16'h0000;
		4: pixel_row = 16'h0000;
		5: pixel_row = 16'hC030;
		6: pixel_row = 16'hC030;
		7: pixel_row = 16'hC030;
		8: pixel_row = 16'hC030;
		9: pixel_row = 16'hFFF0;
		10: pixel_row = 16'hFFF0;
		11: pixel_row = 16'hC030;
		12: pixel_row = 16'hC030;
		13: pixel_row = 16'hC030;
		14: pixel_row = 16'hC030;
		15: pixel_row = 16'hC030;
		16: pixel_row = 16'hC030;
		17: pixel_row = 16'h0000;
		18: pixel_row = 16'h0000;
		19: pixel_row = 0;
		20: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	8'h4a: begin			//J
	  case(row)
	    1: pixel_row = 0;
		2: pixel_row = 0;
		3: pixel_row = 16'h0000;
		4: pixel_row = 16'h0000;
		5: pixel_row = 16'h0030;
		6: pixel_row = 16'h0030;
		7: pixel_row = 16'h0030;
		8: pixel_row = 16'h0030;
		9: pixel_row = 16'h0030;
		10: pixel_row = 16'h0030;
		11: pixel_row = 16'hC030;
		12: pixel_row = 16'hC030;
		13: pixel_row = 16'hC030;
		14: pixel_row = 16'hC030;
		15: pixel_row = 16'hC030;
		16: pixel_row = 16'hC030;
		17: pixel_row = 16'h3FC0;
		18: pixel_row = 16'h3FC0;
		19: pixel_row = 0;
		20: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
  
	8'h4f: begin			//O
	  case(row)
	    1: pixel_row = 0;
		2: pixel_row = 0;
		3: pixel_row = 16'h0000;
		4: pixel_row = 16'h0000;
		5: pixel_row = 16'h3FC0;
		6: pixel_row = 16'h3FC0;
		7: pixel_row = 16'hC030;
		8: pixel_row = 16'hC030;
		9: pixel_row = 16'hC030;
		10: pixel_row = 16'hC030;
		11: pixel_row = 16'hC030;
		12: pixel_row = 16'hC030;
		13: pixel_row = 16'hC030;
		14: pixel_row = 16'hC030;
		15: pixel_row = 16'h3FC0;
		16: pixel_row = 16'h3FC0;
		17: pixel_row = 16'h0000;
		18: pixel_row = 16'h0000;
		19: pixel_row = 0;
		20: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	
	default: begin
	
	  pixel_row = 0;
	
	end
	
	
  endcase
  end
endmodule