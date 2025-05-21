
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
logic [11:0] duck_xpos, duck_ypos;
logic [12:0] pixel_addr;
logic [11:0] rgb;
//logic [11:0] rgb_pixel;

vga_if start_screen_if();
vga_if duck_if();
//------------------------------------------------------------------------------
// MODULES
//------------------------------------------------------------------------------
lfsr_random #(
    .WIDTH(LFSR_WIDTH)
) lfsr (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),
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
start_screen u_start_screen (
    .clk(clk),
    .rst(rst),
    .start_screen_enable(start_screen_enable),

    .in(in),
    .out(start_screen_if)
);

//GAME

duck_ctl u_duck_ctl (
    .game_enable(game_enable),
    .clk(clk),
    .rst(rst),
    .lfsr_number(random_number),

    .xpos(duck_xpos),
    .ypos(duck_ypos)
);

draw_duck #(
    .DUCK_WIDTH(DUCK_WIDTH),
    .DUCK_HEIGHT(DUCK_HEIGHT)
) u_draw_duck (
    .game_enable(game_enable || start_screen_enable),
    .clk(clk),
    .rst(rst),
    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .rgb_pixel(rgb),
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
    .out(out)
);
//---------------------------------//
endmodule
