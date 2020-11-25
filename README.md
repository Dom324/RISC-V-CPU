# RISC-V-CPU

Struktura:

                                                           |----> ps2_interface2.sv
                                    |----> keyboard.sv ----|
                                    |                      |----> scancode_to_ascii.sv
                                    |				
                                    |	    
                                    |	    	                 |----> vga.sv
                                    |	                         |
                                    |----> display_engine.sv ----|----> ascii_to_pixel.sv
                                    |	    	                 |
                                    |	                         |----> RAM1536x8.sv
    TinyFPGA_BX.sv ----> CPU.sv ----|
                                    |
                                    |
                                    |		       |----> decode.sv
                                    |		       |
                                    |		       |----> controller.sv
                                    |----> core.sv ----|
                                    |		       |----> regfile.sv
                                    |		       |
                                    |		       |----> alu.sv
                                    |
                                    |
                                    |
                                    |				   |----> dcache.sv										
                                    |----> memory_subsystem.sv ----|
				       				   |----> icache.sv
																
