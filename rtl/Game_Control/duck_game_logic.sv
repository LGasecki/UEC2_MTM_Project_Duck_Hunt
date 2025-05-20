/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the mechanics of the duck shooting game.
*/
module duck_game_logic
(
    input  wire  clk,  
    input  wire  rst,  

    input  wire         game_enable,
    input  wire         left_mouse,
    input  wire         right_mouse,
    input  wire  [15:0] lfsr_number, 
    input  wire  [11:0] mouse_xpos,
    input  wire  [11:0] mouse_ypos,

    output logic [11:0] target_xpos,
    output logic [11:0] target_ypos,
    output logic [3:0]  bullets_count,
    output logic        reload_enable,
    output logic [6:0]  score

);

timeunit 1ns;
timeprecision 1ps;


//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam DUCK_HEIGHT = 32;
localparam DUCK_WIDTH = 96;
localparam [35:0] DUCK_WIDTH_q12_24 = DUCK_WIDTH << 24; // width of the duck in q12.24 format
localparam [35:0] DUCK_HEIGHT_q12_24 = DUCK_HEIGHT << 24; // height of the duck in q12.24 format

localparam SPEED_q12_24 = 258;

localparam [11:0] LOWEST_POINT = 668; // maximum Y position
localparam [35:0] LOWEST_POINT_q12_24 = LOWEST_POINT << 24; //maximum Y position in q12.24 format
localparam STATE_BITS   = 3; // number of bits used for state register
// localparam COUNTDOWN    = 4000 * 65_000; // countdown value at start of the game T - 4000ms
// localparam DEATH_TIME   = 2000 * 65_000; // time for duck fall after death T - 2000ms
// localparam RELOAD_TIME  = 100 * 65_000; // time for reloading T - 100ms

//FOR TESTS
localparam COUNTDOWN    = 40; 
localparam DEATH_TIME   = 20; 
localparam RELOAD_TIME  = 1; 

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic      [31:0] delay_ms, delay_ms_nxt;
logic      [35:0] xpos_nxt_q12_24, ypos_nxt_q12_24;
logic      [35:0] xpos_q12_24, ypos_q12_24;
logic      [6:0]  score_nxt;
logic      [3:0]  bullets_count_nxt;
logic      reload_enable_nxt;

logic left_mouse_prev, left_mouse_posedge , right_mouse_posedge, right_mouse_prev;

enum logic [STATE_BITS-1 :0] {
    WAIT_FOR_START = 3'b000,
    DELAY          = 3'b001,
    HUNTING        = 3'b010,
    RELOADING      = 3'b011
} state, state_nxt;

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : state_seq_blk
    if(rst)begin : state_seq_rst_blk
        state <= WAIT_FOR_START;
    end
    else begin : state_seq_run_blk
        state <= state_nxt;
    end
end
//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin : state_comb_blk
    case(state)
        WAIT_FOR_START: state_nxt = (game_enable) ? DELAY : WAIT_FOR_START;
        DELAY:          state_nxt = (delay_ms == 0) ? HUNTING : DELAY;
        HUNTING:        state_nxt = (left_mouse_posedge || right_mouse_posedge) ? RELOADING : HUNTING;
        RELOADING:      state_nxt = DELAY;
        default:        state_nxt = WAIT_FOR_START;
    endcase
end
//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if(rst) begin : out_reg_rst_blk
        {target_xpos, target_ypos, score,bullets_count, reload_enable} <= 0;
        delay_ms <= COUNTDOWN;
        {xpos_q12_24, ypos_q12_24} <= 0;
        left_mouse_prev <= 0;
        right_mouse_prev <= 0;
    end
    else begin : out_reg_run_blk
        target_xpos <= xpos_nxt_q12_24[35:24];
        target_ypos <= ypos_nxt_q12_24[35:24];
        score       <= score_nxt;
        delay_ms    <= delay_ms_nxt;
        bullets_count <= bullets_count_nxt;
        reload_enable <= reload_enable_nxt;
        {xpos_q12_24, ypos_q12_24} <= {xpos_nxt_q12_24, ypos_nxt_q12_24};
        left_mouse_prev <= left_mouse;
        right_mouse_prev <= right_mouse;
    end
end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    left_mouse_posedge = (left_mouse == 1 && left_mouse_prev == 0);
    right_mouse_posedge = (right_mouse == 1 && right_mouse_prev == 0);
    case(state_nxt)
        WAIT_FOR_START: begin
            xpos_nxt_q12_24 = {2'd0,lfsr_number[9:0], 24'd0};
            ypos_nxt_q12_24 = LOWEST_POINT_q12_24;
            score_nxt       = 0;
            delay_ms_nxt    = COUNTDOWN;
            bullets_count_nxt = 8;
            reload_enable_nxt   = 0;
        end
        DELAY: begin
            xpos_nxt_q12_24 = xpos_q12_24;
            ypos_nxt_q12_24 = ypos_q12_24;
            score_nxt       = score;
            delay_ms_nxt    = delay_ms - 1;
            bullets_count_nxt = bullets_count;
            reload_enable_nxt   = reload_enable;
        end
        RELOADING: begin
            xpos_nxt_q12_24 = xpos_q12_24;
            ypos_nxt_q12_24 = ypos_q12_24;
            bullets_count_nxt = bullets_count;
            if (left_mouse_posedge) begin
                if (bullets_count == 0) begin : no_bullets
                    reload_enable_nxt = 1;
                    delay_ms_nxt = RELOAD_TIME;
                    bullets_count_nxt = bullets_count;
                end else if (mouse_xpos >= target_xpos && mouse_xpos <= target_xpos + DUCK_WIDTH && 
                             mouse_ypos >= target_ypos && mouse_ypos <= target_ypos + DUCK_HEIGHT) begin : hit_target_with_bullets
                    bullets_count_nxt = bullets_count - 1;
                    score_nxt = score + 1;
                    xpos_nxt_q12_24 = {2'd0,lfsr_number[9:0], 24'd0};
                    ypos_nxt_q12_24 = LOWEST_POINT_q12_24;
                    delay_ms_nxt = DEATH_TIME;
                    reload_enable_nxt = 0;
                end else begin : miss_target
                    reload_enable_nxt = 0;
                    delay_ms_nxt = RELOAD_TIME;
                    bullets_count_nxt = bullets_count - 1;
                    score_nxt = score;
                end
            end
            
            else if (right_mouse_posedge) begin : reload
                reload_enable_nxt = 0;
                delay_ms_nxt = RELOAD_TIME;
                bullets_count_nxt = 8;
            end
            else begin : no_action
                reload_enable_nxt = reload_enable;
                delay_ms_nxt = RELOAD_TIME;
                bullets_count_nxt = bullets_count;
            end
        end

        HUNTING: begin
            //SOON
        end
    endcase
end

endmodule
