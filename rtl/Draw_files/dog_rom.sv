/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Łukasz Gasecki
 *
 * Description:
 * This is the ROM for the '' image.
 * The image size is 
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

 module dog_rom (
    input  logic clk,
    input  logic [12:0] address,  //
    input  logic [3:0] dog_select,

    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

logic [11:0] dog0_rom [0:2587]; // 55x48 = 2688 pixels
logic [11:0] dog1_rom [0:2587];
logic [11:0] dog2_rom [0:2587];
logic [11:0] dog3_rom [0:2587];
logic [11:0] dog4_rom [0:2587];
logic [11:0] dog5_rom [0:2587];
logic [11:0] dog6_rom [0:2587];
logic [11:0] dog7_rom [0:2587];
logic [11:0] dog8_rom [0:2587];




/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/Draw_files/dog0.data", dog0_rom);
initial $readmemh("../../rtl/Draw_files/dog1.data", dog1_rom);
initial $readmemh("../../rtl/Draw_files/dog2.data", dog2_rom);
initial $readmemh("../../rtl/Draw_files/dog3.data", dog3_rom);
initial $readmemh("../../rtl/Draw_files/dog4.data", dog4_rom);
initial $readmemh("../../rtl/Draw_files/dog5.data", dog5_rom);
initial $readmemh("../../rtl/Draw_files/dog6.data", dog6_rom);
initial $readmemh("../../rtl/Draw_files/dog7.data", dog7_rom);
initial $readmemh("../../rtl/Draw_files/dog8.data", dog8_rom);

/**
 * Internal logic
 */

always_ff @(posedge clk)
case (dog_select)
    4'd0: rgb <= dog0_rom[address];
    4'd1: rgb <= dog1_rom[address];
    4'd2: rgb <= dog2_rom[address];
    4'd3: rgb <= dog3_rom[address];
    4'd4: rgb <= dog4_rom[address];
    4'd5: rgb <= dog5_rom[address];
    4'd6: rgb <= dog6_rom[address];
    4'd7: rgb <= dog7_rom[address];
    4'd8: rgb <= dog8_rom[address];
    default: rgb <= 12'h000;
endcase
endmodule