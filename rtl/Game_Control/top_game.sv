
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
localparam logic [5:0] LFSR_WIDTH = 16; // Width of the LFSR



//--------------------------------//
// LOCAL VARIABLES
logic [LFSR_WIDTH-1:0] random_number;
logic start_screen_enable, game_enable, game_end_enable;

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
    .out(out)
);

duck_game_logic u_duck_game_logic (
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable),
    .left_mouse(left_mouse),
    .right_mouse(right_mouse),
    .lfsr_number(random_number),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),

    .target_xpos(),
    .target_ypos(),
    .bullets_count(),
    .reload_enable(),
    .score()
);
//---------------------------------//
endmodule
