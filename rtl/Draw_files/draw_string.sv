/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the start screen for the game.
*/
import vga_pkg::*;

module draw_string
    #(parameter
    CHAR_XPOS = START_CHAR_XPOS, // X position
    CHAR_YPOS = START_CHAR_YPOS, // Y position
    WIDTH = 10, // number of characters in the horizontal direction
    SIZE = 2, // 2^POWER_OF_2 = 4
    TEXT = "START GAME", // text to be displayed
    COLOUR = RGB_BLACK // RGB color for the character

)(
    input logic clk,
    input logic rst,
    input logic enable,
    
    vga_if.in in,
    vga_if.out out
);
    


//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [7:0] char_xy;
logic [6:0] char_code;
logic [3:0] char_line;
logic [7:0] char_line_pixels;


draw_rect_char 
#( 
    .WIDTH(WIDTH),         // ilość znaków w poziomie
    .CHAR_XPOS(CHAR_XPOS), // X pozycja znaku
    .CHAR_YPOS(CHAR_YPOS), // Y pozycja znaku
    .COLOUR(COLOUR), // RGB color for the character
    .SCALE_POWER_OF_2(SIZE) // 2^POWER_OF_2 = 4
    
)u_draw_rect_char_start_screen (
    .clk(clk),
    .rst,

    .enable(enable),
    .char_line_pixels(char_line_pixels), 
    .char_xy(char_xy),
    .char_line(char_line),

    .in(in),
    .out(out)
);

char_rom 
#(
    .TEXT(TEXT),
    .TEXT_SIZE(WIDTH)
)
u_char_rom_start_screen (
    .clk(clk),
    .char_xy(char_xy),  
    .char_code(char_code)
);

font_rom u_font_rom (
    .clk(clk),
    .char_line_pixels(char_line_pixels),
    .addr({char_code, char_line}) // char_code[6:0] + char_line[3:0]
);


endmodule