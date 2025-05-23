
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
logic [5:0] bullets_left;
logic [6:0] my_score;
logic hunt_start;
logic show_reload_char;
logic target_killed;

vga_if start_screen_if();
vga_if duck_if();
vga_if grass_if();
//------------------------------------------------------------------------------
// MODULES
//------------------------------------------------------------------------------
lfsr_random #(
    .WIDTH(LFSR_WIDTH)
) lfsr (
    .clk(clk),
    .rst(rst),
    .enable(game_enable || start_screen_enable),
    .random(random_number)
);

// CONTROL
game_control_fsm u_game_control_fsm (
    .clk(clk),
    .rst(rst),
    .left_mouse(left_mouse),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),
    .game_finished(1'b0), // Placeholder for game finished signal
    
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
    .TEXT("START GAME") // text to be displayed
)u_start_screen (
    .clk(clk),
    .rst(rst),
    .enable(start_screen_enable),

    .in(in),
    .out(start_screen_if)
);


//GAME
//control
duck_ctl u_duck_ctl (
    .game_enable(hunt_start),
    .clk(clk),
    .rst(rst),
    .lfsr_number(random_number),
    .target_killed(target_killed),

    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .duck_direction(duck_direction)
);

duck_game_logic u_duck_game_logic (
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

//drawing
draw_duck #(
    .DUCK_WIDTH(DUCK_WIDTH),
    .DUCK_HEIGHT(DUCK_HEIGHT)
) u_draw_duck (
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

draw_2_numbers 
#(
    .NUMB_XPOS(SCORE_XPOS), // X position 
    .NUMB_YPOS(SCORE_YPOS) // Y position 
)
u_draw_score (
    .clk(clk),
    .rst(rst),

    .game_enable(start_screen_enable || game_enable),
    .bin_number(my_score),
    .in(grass_if),
    .out(out)
);
//---------------------------------//
endmodule
