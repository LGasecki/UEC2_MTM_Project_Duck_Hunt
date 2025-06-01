/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 * Modified: Oliwia Szewczyk
 *
 * Description:
 * This is the ROM for the '' image.
 * The image size is 
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

 module grass_rom (
    input  logic clk,
    input  logic [15:0] address,  //

    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

 logic [11:0] image_mem [0:17919];
 
 
 
 /**
  * Memory initialization from a file
  */
 
 initial $readmemh("../../rtl/Data_files/grass_128x35.data", image_mem);

/**
 * Internal logic
 */

always_ff @(posedge clk)
    rgb <= image_mem[address];
endmodule