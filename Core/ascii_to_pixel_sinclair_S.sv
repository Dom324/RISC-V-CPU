module ascii_to_pixel(
  input logic end_of_line,
  input logic  [7:0] ascii,
  output logic [7:0] pixel_row
);
  
  logic [3:0] row;
  
  initial row = 0;

always_ff @(posedge end_of_line) begin

  if(end_of_line) begin
    if (row == 4'b1001)
      row <= 4'b0000;
    else row <= row + 1;
  end
	
end

always_comb begin

  case(ascii)
  
    8'h41: begin			//A
	  case(row)
	    1: pixel_row = 8'h00;
		2: pixel_row = 8'h78;
		3: pixel_row = 8'h84;
		4: pixel_row = 8'h84;
		5: pixel_row = 8'hfc;
		6: pixel_row = 8'h84;
		7: pixel_row = 8'h84;
		8: pixel_row = 8'h00;
		9: pixel_row = 0;
		10: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	8'h48: begin			//H
	  case(row)
	    1: pixel_row = 8'h00;
		2: pixel_row = 8'h84;
		3: pixel_row = 8'h84;
		4: pixel_row = 8'hfc;
		5: pixel_row = 8'h84;
		6: pixel_row = 8'h84;
		7: pixel_row = 8'h84;
		8: pixel_row = 8'h00;
		9: pixel_row = 0;
		10: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	8'h4a: begin			//J
	  case(row)
	    1: pixel_row = 8'h00;
		2: pixel_row = 8'h04;
		3: pixel_row = 8'h04;
		4: pixel_row = 8'h04;
		5: pixel_row = 8'h84;
		6: pixel_row = 8'h84;
		7: pixel_row = 8'h78;
		8: pixel_row = 8'h00;
		9: pixel_row = 0;
		10: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
  
	8'h4f: begin			//O
	  case(row)
	    1: pixel_row = 8'h00;
		2: pixel_row = 8'h78;
		3: pixel_row = 8'h84;
		4: pixel_row = 8'h84;
		5: pixel_row = 8'h84;
		6: pixel_row = 8'h84;
		7: pixel_row = 8'h78;
		8: pixel_row = 8'h00;
		9: pixel_row = 0;
		10: pixel_row = 0;
		default: pixel_row = 0;
	  endcase
    end
	
	
	default: begin
	
	  pixel_row = 0;
	
	end
	
	
  endcase
  end
endmodule