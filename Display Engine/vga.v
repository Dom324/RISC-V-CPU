//VGA 1280x720 casovani pro nastaveni signalu h_sync a v_sync, ktere ridi kdy se tiskne obraz a kdy ne
/*
localparam horizontal = 1280;			//sirka obrazu v pixelech
localparam vertical = 720;				//vyska obrazu v pixelech
localparam h_fp = 110;					//horizontalni front porch
localparam h_sw = 40;					//horizontalni sync width
localparam h_bp = 220;					//horizontalni back porch
localparam v_fp = 5;					//vertikalni front porch
localparam v_sw = 5;					//vertikalni sync width
localparam v_bp = 20;					//vertikalni back porch
*/
//VGA 640x480 casovani pro nastaveni signalu h_sync a v_sync, ktere ridi kdy se tiskne obraz a kdy ne
/*
localparam horizontal = 640;		  //sirka obrazu v pixelech
localparam vertical = 480;				//vyska obrazu v pixelech
localparam h_fp = 16;					//horizontalni front porch
localparam h_sw = 96;					//horizontalni sync width
localparam h_bp = 48;					//horizontalni back porch
localparam v_fp = 10;					//vertikalni front porch
localparam v_sw = 2;					//vertikalni sync width
localparam v_bp = 33;					//vertikalni back porch
*/



module vga(
  input CLK_VGA, reset,						//pro 1280x720 CLK_VGA 74.25MHz, pro 640x480 CLK_VGA 25.175MHz
  input [15:0] pixel_row,
  output reg pixel, h_sync, v_sync, newData, end_of_line, end_of_frame
  //output reg [10:0] horizontal_line,
  //output reg [9:0] vertical_line
);

//VGA 640x480 casovani pro nastaveni signalu h_sync a v_sync, ktere ridi kdy se tiskne obraz a kdy ne
localparam horizontal = 800;			//sirka obrazu v pixelech
localparam vertical = 600;				//vyska obrazu v pixelech
localparam h_fp = 40;					//horizontalni front porch
localparam h_sw = 128;					//horizontalni sync width
localparam h_bp = 92;					//horizontalni back porch
localparam v_fp = 1;					//vertikalni front porch
localparam v_sw = 4;					//vertikalni sync width
localparam v_bp = 22;					//vertikalni back porch

  wire data_selected;
  reg [3:0] counter;
  reg [10:0] horizontal_line;
  reg [9:0] vertical_line;

  mux16_single_input output_select(counter, pixel_row, data_selected);


always @ (posedge CLK_VGA) begin

  if(!reset)begin
  //counter <= 15;
  vertical_line <= 0;
  horizontal_line <= 0;
  end

  //nastaveni v_sync signalu
  if( (vertical_line < vertical + v_fp) || (vertical_line >= vertical + v_fp + v_sw) )
    v_sync <= 1;
  else
    v_sync <= 0;
  //aktualizace pocitadla radku
  if(horizontal_line == horizontal + h_fp + h_sw + h_bp - 1) begin
    if(vertical_line == vertical + v_fp + v_sw + v_bp - 1) begin			//jestli jsme na konci sloupcu, pocitadlo radku = 0, jinak pocitadlo sloupcu++
      vertical_line <= 0;
      end_of_frame = 1;
    end
    else begin
      vertical_line <= vertical_line + 1;
      end_of_frame = 0;
    end
  end


  //nastaveni h_sync signalu
  if( (horizontal_line < horizontal + h_fp) || (horizontal_line >= horizontal + h_fp + h_sw) )
    h_sync <= 1;
  else
    h_sync <= 0;
  //aktualizace pocitadla sloupcu
  if(horizontal_line == horizontal + h_fp + h_sw + h_bp - 1)		//jestli jsme na konci radku, pocitadlo sloupcu = 0, jinak pocitadlo sloupcu++
    horizontal_line <= 0;
  else
    horizontal_line <= horizontal_line + 1;

  if( (horizontal_line < horizontal) && (vertical_line < vertical) ) begin		//jestli mame tisknout obraz

    pixel = data_selected;

	  if(counter == 15) begin
      newData = 1;
      counter <= 0;
    end
  	else begin
      newData = 0;
      counter <= counter + 1;
    end
  end
  else begin
    newData = 0;
	pixel = 0;
  end

  if(horizontal_line == horizontal + h_fp + h_sw + h_bp - 1)		//jestli jsme na konci radku, end_of_line == 1
    end_of_line = 1;
  else
    end_of_line = 0;


end
endmodule
