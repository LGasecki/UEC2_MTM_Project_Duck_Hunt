/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the start screen for the game.
*/
module start_screen(
    input logic clk,
    input logic rst,
    input logic start_screen_enable,
    
    vga_if.in in,
    vga_if.out out
);
    
import vga_pkg::*;


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
    .WIDTH(10),         // ilość znaków w poziomie
    .CHAR_XPOS(START_CHAR_XPOS),    
    .CHAR_YPOS(START_CHAR_YPOS)
    
)u_draw_rect_char_start_screen (
    .clk(clk),
    .rst,

    .enable(start_screen_enable),
    .char_line_pixels(char_line_pixels), 
    .char_xy(char_xy),
    .char_line(char_line),

    .in(in),
    .out(out)
);

char_rom 
#(
    .TEXT({"START GAME"})
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