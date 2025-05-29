/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the finite state machine (FSM) for game control.
# The FSM manages the game states: start screen, game running, and game over.
*/
module game_control_fsm 
    (
    input logic clk,
    input logic rst,
    input logic left_mouse,
    input logic [11:0] mouse_xpos,
    input logic [11:0] mouse_ypos,
    input logic game_finished,


    output logic start_screen_enable,
    output logic game_enable,
    output logic game_end_enable

);

import vga_pkg::*;

enum logic [1:0] {
    START_SCREEN = 2'b00,
    GAME_RUNNING = 2'b01,
    GAME_OVER    = 2'b10
} state;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : seq_blk
    if(rst)begin : seq_rst_blk
        state <= START_SCREEN;
        start_screen_enable <= 1'b1;
        game_enable <= 1'b0;
        game_end_enable <= 1'b0;
    end
    else begin : seq_run_blk
        case(state)
            START_SCREEN: begin
                start_screen_enable <= 1'b1;
                game_enable <= 1'b0;
                game_end_enable <= 1'b0;
                if(left_mouse && (mouse_xpos >= START_CHAR_XPOS) && (mouse_xpos < START_CHAR_XPOS + START_AREA_WIDTH) &&
                   (mouse_ypos >= START_CHAR_YPOS) && (mouse_ypos < START_CHAR_YPOS + AREA_HEIGHT)) begin
                    state <= GAME_RUNNING;
                end
            end
 
            GAME_RUNNING: begin
                start_screen_enable <= 1'b0;
                game_enable <= 1'b1;
                game_end_enable <= 1'b0;
                if(game_finished) begin
                    state <= GAME_OVER;
                end
            end

            GAME_OVER: begin
                start_screen_enable <= 1'b0;
                game_enable <= 1'b0;
                game_end_enable <= 1'b1;
                if(left_mouse)
                    state <= START_SCREEN;
            end

            default: begin
                state <= START_SCREEN; // Default state
            end
        endcase
    end
end


endmodule