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

localparam LOWEST_POINT = 668; // maximum Y position
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
logic      [31:0] delay_ms = COUNTDOWN, delay_ms_nxt = COUNTDOWN;
logic      [11:0] target_xpos_nxt, target_ypos_nxt;
logic      [6:0]  score_nxt;
logic      [3:0]  bullets_count_nxt;
logic      reload_enable_nxt;

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
        HUNTING:        state_nxt = (left_mouse || right_mouse) ? RELOADING : HUNTING;
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
    end
    else begin : out_reg_run_blk
        target_xpos <= target_xpos_nxt;
        target_ypos <= target_ypos_nxt;
        score       <= score_nxt;
        delay_ms    <= delay_ms_nxt;
        bullets_count <= bullets_count_nxt;
        reload_enable <= reload_enable_nxt;
    end
end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    case(state_nxt)
        WAIT_FOR_START: begin
            target_xpos_nxt = {2'd0,lfsr_number[9:0]};
            target_ypos_nxt = LOWEST_POINT;
            score_nxt       = 0;
            delay_ms_nxt    = COUNTDOWN;
            bullets_count_nxt = 8;
            reload_enable_nxt   = 0;
        end
        DELAY: begin
            target_xpos_nxt = target_xpos;
            target_ypos_nxt = target_ypos;
            score_nxt       = score;
            delay_ms_nxt    = delay_ms - 1;
            bullets_count_nxt = bullets_count;
            reload_enable_nxt   = reload_enable;
        end
        RELOADING: begin
            target_xpos_nxt = target_xpos;
            target_ypos_nxt = target_ypos;
            score_nxt       = score;
            delay_ms_nxt    = delay_ms;
            bullets_count_nxt = bullets_count;
            reload_enable_nxt   = 0;

        // Działanie magazynka, jeśli nie ma amunicji to wyświetla aby przeładwoać
            if(bullets_count > 0) begin
                bullets_count_nxt = bullets_count - 1;
                reload_enable_nxt = 0;
            end else begin
                if(right_mouse) begin
                    bullets_count_nxt = 8;
                    reload_enable_nxt = 0;
                end else begin
                    bullets_count_nxt = bullets_count;
                    reload_enable_nxt = 1;
                end
            end

        // Sprawdzenie czy myszka trafiła w kaczke
        // Jeżeli tak to zwiększa wynik i zmienia pozycje kaczki
            if((mouse_xpos >= target_xpos && mouse_xpos <= target_xpos + DUCK_WIDTH && 
                    mouse_ypos >= target_ypos && mouse_ypos <= target_ypos + DUCK_HEIGHT && left_mouse)) begin
                score_nxt       = score + 1;
                delay_ms_nxt    = DEATH_TIME;
                target_xpos_nxt = {2'd0,lfsr_number[9:0]};
                target_ypos_nxt = LOWEST_POINT;
            end else begin
                score_nxt       = score;
                delay_ms_nxt    = RELOAD_TIME;
                target_xpos_nxt = target_xpos;
                target_ypos_nxt = target_ypos;
            end
        end
        HUNTING: begin
            //SOON
        end
    endcase
end

endmodule
