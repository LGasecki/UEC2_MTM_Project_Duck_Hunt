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
    input logic enemy_start,
    input logic enemy_ended,

    output logic start_screen_enable,
    output logic start_pressed,
    output logic game_enable_posedge,
    output logic game_enable,
    output logic game_ended,
    output logic game_end_enable,
    output logic rst_ctl

);

import vga_pkg::*;

enum logic [2:0] {
    START_SCREEN                    = 3'b00,
    WAITING_FOR_2ND_PLAYER_TO_START = 3'b001,
    GAME_RUNNING                    = 3'b010,
    WAITING_FOR_2ND_PLAYER_TO_END   = 3'b011,
    GAME_OVER                       = 3'b100
} state, state_prev;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

logic game_enable_prev;
logic left_mouse_prev, left_mouse_posedge;
//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : seq_blk
    if(rst)begin : seq_rst_blk
        state <= START_SCREEN;
        start_screen_enable <= 1'b1;
        game_enable <= 1'b0;
        game_end_enable <= 1'b0;
        game_enable_prev <= 1'b0;
        game_enable_posedge <= 1'b0;
        start_pressed <= 1'b0;
        game_ended <= 1'b0;
        rst_ctl <= 1'b0;
        state_prev <= START_SCREEN;
        left_mouse_prev <= 1'b0;
        left_mouse_posedge <= 1'b0;
    end
    else begin : seq_run_blk
        game_enable_prev <= game_enable;
        game_enable_posedge <= game_enable && !game_enable_prev;
        state_prev <= state;
        rst_ctl <= (state_prev == GAME_OVER && state == START_SCREEN) ? 1'b1 : 1'b0;
        left_mouse_prev <= left_mouse;
        left_mouse_posedge <= left_mouse && !left_mouse_prev;
        case(state)
            START_SCREEN: begin
                start_screen_enable <= 1'b1;
                start_pressed       <= 1'b0;
                game_enable         <= 1'b0;
                game_ended          <= 1'b0;
                game_end_enable     <= 1'b0;
                if(left_mouse_posedge && (mouse_xpos >= START_CHAR_XPOS) && (mouse_xpos < START_CHAR_XPOS + START_AREA_WIDTH) &&
                   (mouse_ypos >= START_CHAR_YPOS) && (mouse_ypos < START_CHAR_YPOS + START_CHAR_HEIGHT)) begin
                    state <= WAITING_FOR_2ND_PLAYER_TO_START;
                end
            end

            WAITING_FOR_2ND_PLAYER_TO_START: begin
                start_screen_enable <= 1'b0;
                start_pressed       <= 1'b1; 
                game_enable         <= 1'b0;
                game_ended          <= 1'b0;
                game_end_enable     <= 1'b0;
                if(enemy_start || enemy_start == 'z) begin
                    state <= GAME_RUNNING;
                end
            end
 
            GAME_RUNNING: begin
                start_screen_enable <= 1'b0;
                start_pressed       <= 1'b1;
                game_enable         <= 1'b1;
                game_ended          <= 1'b0;
                game_end_enable     <= 1'b0;
                state <= game_finished ? WAITING_FOR_2ND_PLAYER_TO_END : GAME_RUNNING;
            end

            WAITING_FOR_2ND_PLAYER_TO_END: begin
                start_screen_enable <= 1'b0;
                start_pressed       <= 1'b0;
                game_enable         <= 1'b0;
                game_ended          <= 1'b1;
                game_end_enable     <= 1'b0;
                if(enemy_ended) begin
                    state <= GAME_OVER;
                end
            end

            GAME_OVER: begin
                start_screen_enable <= 1'b0;
                start_pressed       <= 1'b0;
                game_enable         <= 1'b0;
                game_ended          <= 1'b1;
                game_end_enable     <= 1'b1;
                if(left_mouse_posedge && (mouse_xpos >= RESTART_CHAR_XPOS) && (mouse_xpos < RESTART_CHAR_XPOS + RESTART_AREA_WIDTH) &&
                   (mouse_ypos >= RESTART_CHAR_YPOS) && (mouse_ypos < RESTART_CHAR_YPOS + RESTART_CHAR_HEIGHT)) begin
                    state <= START_SCREEN;
                end
            end

            default: begin
                state <= START_SCREEN; // Default state
            end
        endcase
    end
end


endmodule