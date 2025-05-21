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

 module duck_rom (
    input  logic clk,
    input  logic [12:0] address,  //
    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

reg [12:0] rom [0:5759]; // 96x60 = 5760 pixels


/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/Game_Control/draw_files/duck_96x60.data", rom);


/**
 * Internal logic
 */

always_ff @(posedge clk)
    rgb <= 12'(rom[address]);

endmodule