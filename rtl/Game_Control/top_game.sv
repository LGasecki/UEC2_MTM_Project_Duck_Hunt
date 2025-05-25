
/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Coauthor: Oliwia Szewczyk
# Description: 
# This module is the top-level module for the game control system.
*/

module top_game(
    input logic clk,
    input logic rst,
    input logic [11:0] mouse_xpos,
    input logic [11:0] mouse_ypos,
    input logic left_mouse,
    input logic right_mouse,

    vga_if.in in,
    vga_if.out out

    );

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

// LOCAL PARAMETERS
localparam logic [3:0] LFSR_WIDTH = 10; // Width of the LFSR



//--------------------------------//
// LOCAL VARIABLES
logic [LFSR_WIDTH-1:0] random_number;
logic start_screen_enable, game_enable, game_end_enable;
logic duck_direction;
logic [11:0] duck_xpos, duck_ypos;
logic [12:0] pixel_addr;
logic [11:0] rgb;
logic [2:0] bullets_in_magazine;
logic [6:0] bullets_left;
logic [6:0] my_score;
logic hunt_start;
logic show_reload_char;
logic target_killed;

vga_if start_screen_if();
vga_if duck_if();
vga_if grass_if();
vga_if bullets_if();
vga_if reload_if();
vga_if slash_if();
vga_if bullets_left_if();
vga_if your_points_if();
vga_if enemy_points_if();
vga_if my_score_if();
//------------------------------------------------------------------------------
// MODULES
//------------------------------------------------------------------------------
lfsr_random  // generator liczb pseudolosowych
#(
    .WIDTH(LFSR_WIDTH)
)
 lfsr (
    .clk(clk),
    .rst(rst),
    .enable(game_enable || start_screen_enable),
    .random(random_number)
);

// CONTROL
game_control_fsm u_game_control_fsm (  //Sterowanie etapami gry: Ekran startowy -> Gra -> Ekran końcowy
    .clk(clk),
    .rst(rst),
    .left_mouse(left_mouse),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),
    .game_finished(!bullets_left),
    
    .start_screen_enable(start_screen_enable),
    .game_enable(game_enable),
    .game_end_enable(game_end_enable)

);

//START SCREEN
draw_string 
#(
    .CHAR_XPOS(START_CHAR_XPOS), // X position 
    .CHAR_YPOS(START_CHAR_YPOS), // Y position 
    .WIDTH(10), // number of characters in the horizontal direction
    .SIZE(START_CHAR_SIZE), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_BLACK), // RGB color for the character
    .TEXT("START GAME") // text to be displayed
)
u_start_screen (
    .clk(clk),
    .rst(rst),
    .enable(start_screen_enable),

    .in(in),
    .out(start_screen_if)
);


//GAME
//control
duck_ctl u_duck_ctl (   // Odpowiedzialne za poruszanie celu
    .game_enable(hunt_start),
    .clk(clk),
    .rst(rst),
    .lfsr_number(random_number),
    .target_killed(target_killed),

    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .duck_direction(duck_direction)
);

duck_game_logic u_duck_game_logic (     // Odpowiedzialne za logikę gry oraz dane
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable),
    .left_mouse(left_mouse),
    .right_mouse(right_mouse),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),
    .duck_xpos(duck_xpos),
    .duck_ypos(duck_ypos),

    .my_score(my_score),
    .bullets_in_magazine(bullets_in_magazine),
    .bullets_left(bullets_left),
    .show_reload_char(show_reload_char),
    .hunt_start(hunt_start),
    .duck_killed(target_killed)
);

//drawing on screen
draw_duck 
#(
    .DUCK_WIDTH(DUCK_WIDTH),
    .DUCK_HEIGHT(DUCK_HEIGHT)
) 
u_draw_duck (
    .game_enable(hunt_start || target_killed),
    .clk(clk),
    .rst(rst),
    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .rgb_pixel(rgb),
    .duck_direction(duck_direction), 

    .pixel_addr(pixel_addr),
    .in(start_screen_if),
    .out(duck_if)
);

duck_rom u_duck_rom(
    .clk,
    .address(pixel_addr),
    .rgb(rgb)
);

grass_draw u_grass_draw (
    .game_enable(start_screen_enable || game_enable),
    .clk(clk),
    .rst(rst),
    .in(duck_if),
    .out(grass_if)
);

draw_bullets u_draw_bullets (
    .game_enable(game_enable),
    .clk(clk),
    .rst(rst),
    .bullets_in_magazine(bullets_in_magazine),

    .in(grass_if),
    .out(bullets_if)
);

draw_string 
#(
    .CHAR_XPOS(MY_SCORE_XPOS - 24), 
    .CHAR_YPOS(MY_SCORE_YPOS - 70), 
    .WIDTH(6), 
    .SIZE(2), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_WHITE), 
    .TEXT("RELOAD")
)
u_draw_reload (
    .clk(clk),
    .rst(rst),
    .enable(show_reload_char && game_enable && left_mouse),

    .in(bullets_if),
    .out(reload_if)
);
draw_string 
#(
    .CHAR_XPOS(168), 
    .CHAR_YPOS(MY_SCORE_YPOS - 6), 
    .WIDTH(2), 
    .SIZE(2), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_BLACK), 
    .TEXT("/ ")
)
u_draw_slash (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(reload_if),
    .out(slash_if)
); 

draw_2_numbers 
#(
    .NUMB_XPOS(200), 
    .NUMB_YPOS(MY_SCORE_YPOS), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_bullets_left (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(bullets_left),
    .in(slash_if),
    .out(bullets_left_if)
);
    

draw_string 
#(
    .CHAR_XPOS(MY_SCORE_XPOS + 8), 
    .CHAR_YPOS(MY_SCORE_YPOS - 20), 
    .WIDTH(3), 
    .SIZE(1), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_GREEN), 
    .TEXT("YOU")
)
u_draw_score_your_points (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(bullets_left_if),
    .out(your_points_if)
);

draw_string 
#(
    .CHAR_XPOS(ENEMY_SCORE_XPOS - 8), 
    .CHAR_YPOS(ENEMY_SCORE_YPOS - 20), 
    .WIDTH(5), 
    .SIZE(1), 
    .COLOUR(RGB_RED), 
    .TEXT("ENEMY") 
)
u_draw_score_enemy_points (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(your_points_if),
    .out(enemy_points_if)
);
draw_2_numbers 
#(
    .NUMB_XPOS(MY_SCORE_XPOS), 
    .NUMB_YPOS(MY_SCORE_YPOS), 
    .COLOUR(RGB_BLUE), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_my_score (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(my_score),
    .in(enemy_points_if),
    .out(my_score_if)
);

draw_2_numbers 
#(
    .NUMB_XPOS(ENEMY_SCORE_XPOS), 
    .NUMB_YPOS(ENEMY_SCORE_YPOS), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_enemy_score (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(7'd11),
    .in(my_score_if),
    .out(out)
);

//GAME_END

//---------------------------------//
endmodule
