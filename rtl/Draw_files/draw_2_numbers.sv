/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the drawing of two numbers on the screen.
*/
module draw_2_numbers(
    input logic clk,
    input logic rst,
    input logic [6:0] my_score, // 7-bitowy kod BIN
    input logic game_enable,
    
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
logic [6:0] my_score_str_1, my_score_str_0;


draw_rect_char 
#( 
    .WIDTH(2),         // ilość znaków w poziomie
    .CHAR_XPOS(SCORE_XPOS),    
    .CHAR_YPOS(SCORE_YPOS)
    
)u_draw_rect_char_2_numbers (
    .clk(clk),
    .rst,

    .enable(game_enable),
    .char_line_pixels(char_line_pixels), 
    .char_xy(char_xy),
    .char_line(char_line),

    .in(in),
    .out(out)
);

bin_to_ascii u_bin_to_ascii (
    .bin_in({1'b0,my_score}), // 7-bitowy kod BIN
    .ascii_tens(my_score_str_1),     // ASCII kod cyfry dziesiątek
    .ascii_ones(my_score_str_0)      // ASCII kod cyfry jedności
);


char_ram u_char_ram (
    .clk(clk),
    .load_text(game_enable), // sygnał załadunku dwóch znaków
    .text_in({my_score_str_1, my_score_str_0}), // dwa znaki ASCII: [15:8] i [7:0]
    .char_xy(char_xy),          // indeks znaku: 0 lub 1
    .char_code(char_code)       // wyjście: 7-bitowy kod ASCII
);

font_rom u_font_rom (
    .clk(clk),
    .char_line_pixels(char_line_pixels),
    .addr({char_code, char_line}) // char_code[6:0] + char_line[3:0]
);


endmodule