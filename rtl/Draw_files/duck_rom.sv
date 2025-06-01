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
    input  logic duck_killed,

    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

logic [11:0] duck_rom [0:5759]; // 96x60 = 5760 pixels
logic [11:0] dead_duck_rom [0:5759];


/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/Data_files/duck_96x60.data", duck_rom);
initial $readmemh("../../rtl/Data_files/dead_duck_96x60.data", dead_duck_rom);

/**
 * Internal logic
 */

always_ff @(posedge clk)
    if(duck_killed)
        rgb <= dead_duck_rom[address];
    else
        rgb <= duck_rom[address];

endmodule