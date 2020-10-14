module controller(
  input logic  [6:0] op,
  input logic  [2:0] instrType, funct3,
  output logic we_reg,			//we_reg - 1 pokud se bude zapisovat do registru
			   pcControl,		//pcControl ovlada obsah registru PC pri skocich a vetvich
			   memory_en,		//memory_en detekuje zda instrukce pracuje s pameti
			   aluBSel,			//aluBSel prepina vstup 2 pro alu (pokud je aluBSel 0, vstup je obsah registru rs2, pokud je 1, vstup je imm (konstanta))
  output logic [1:0] wdSelect,	//co za data se bude zapisovat do registru - "00" vysledek z ALU, "01" data z pameti, "10" PCplus4 (pouziva se pro ukladani navratovych adres), "11" imm (konstanta)
			   store_size		//kolik Bytu se bude zapisovat do pameti - "00" jeden Byte, "01" dva Byty, "10" ctyri Byty, "11" instrukce nezapisuje data ale cte je (LOAD instrukce)
);
  
always_comb begin

  case(instrType)
  
    3'b001: begin			//U-type instruction
      
	  we_reg = 1;
	  pcControl = 0;
	  wdSelect = 2'b11;
	  aluBSel = 1'b0;
	  memory_en = 1'b0;
	  store_size = 2'b11;

    end
  
    3'b010: begin			//J-type instruction
      
	  we_reg = 1;
	  pcControl = 1;
	  wdSelect = 2'b11;
	  aluBSel = 1'b0;
	  memory_en = 1'b0;
	  store_size = 2'b11;

    end
  
    3'b011: begin			//B-type instruction
      
	  we_reg = 0;
	  pcControl = 1;
	  wdSelect = 2'b10;
	  aluBSel = 1'b0;
	  memory_en = 1'b0;
	  store_size = 2'b11;

    end
	
    3'b100: begin			//I-type instruction
      
	  we_reg = 1;
	  aluBSel = 1'b1;
	  store_size = 2'b11;
	  
	  if(op == 7'b1100111) begin	//JALR instruction
	  
	    pcControl = 1;
		wdSelect = 2'b11;
		memory_en = 1'b0;
		
	  end
	  else begin
	    pcControl = 0;
		
		if(op == 7'b1100111) begin	//Load instruction
		
		  wdSelect = 2'b01;
		  memory_en = 1'b1;
		end
		else begin					//ADDI, XORI.... instructions
		
		  wdSelect = 2'b00;
		  memory_en = 1'b0;
		end
	  end
	
    end
	
    3'b101: begin			//S-type instruction
      
	  we_reg = 0;
	  pcControl = 0;
	  wdSelect = 2'bxx;
	  aluBSel = 1'b1;
	  memory_en = 1'b1;
	  
	  case(funct3)
	    3'b000: store_size = 2'b00;
		3'b001: store_size = 2'b01;
		3'b010: store_size = 2'b10;
		default: store_size = 2'b11;
	  endcase

    end
	
    3'b110: begin			//R-type instruction
      
	  pcControl = 0;
	  wdSelect = 2'b00;
	  aluBSel = 1'b0;
	  memory_en = 1'b0;
	  store_size = 2'b11;
	  
	  if((op == 7'b1110011) || (op == 7'b0001111))
		we_reg = 0;
	  else
	    we_reg = 0;
		
    end
	
	default: begin
	
	  we_reg = 0;
	  pcControl = 0;
	  wdSelect = 2'bxx;
	  aluBSel = 1'b0;
	  memory_en = 1'b0;
	  store_size = 2'b11;
	
	end
  endcase
  end
endmodule