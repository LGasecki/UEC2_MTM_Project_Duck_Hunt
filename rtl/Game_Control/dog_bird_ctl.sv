/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Dog and bird controller for game logic# 
# This module controls the vertical movement of a dog or bird character in a game.
# It uses a simple state machine to move the character up, wait, and then move down,
# synchronizing the horizontal position with the duck's x position.
# 
*/
 module dog_bird_ctl
    (
        input  wire  clk,  
        input  wire  rst,  
        input  wire  enable,
        input  wire  [11:0] duck_xpos,
        output logic [11:0] xpos,
        output logic [11:0] ypos
    );
    
    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam STATE_BITS = 2; // number of bits used for state register
    
    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [35:0] ypos_q12_24_nxt, ypos_q12_24;
    
    enum logic [STATE_BITS-1 :0] {
        IDLE = 2'b00,
        UP   = 2'b01,
        WAIT = 2'b10,
        DOWN = 2'b11
    } state, state_nxt;
    
    //------------------------------------------------------------------------------
    // state sequential with synchronous reset
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : state_seq_blk
        if(rst)begin : state_seq_rst_blk
            state <= IDLE;
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
            IDLE: state_nxt = enable ? UP : IDLE;
            UP:  state_nxt = (ypos_q12_24[35:24] >= 12'd480) ? UP : WAIT;
            WAIT: state_nxt = (ypos_q12_24[35:24] >= 12'd475) ? WAIT : DOWN;
            DOWN: state_nxt = (ypos_q12_24[35:24] < 12'd680) ? DOWN : IDLE;
            default: state_nxt = IDLE;
        endcase
    end
    //------------------------------------------------------------------------------
    // output register
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : out_reg_blk
        if(rst) begin : out_reg_rst_blk
            ypos_q12_24 <= 36'd700<<24;
            {xpos, ypos} <= {12'd200, 12'd700};
        end
        else begin : out_reg_run_blk
            ypos_q12_24 <=  ypos_q12_24_nxt;
            {xpos, ypos} <= {duck_xpos, ypos_q12_24[35:24]};
        end
    end
    //------------------------------------------------------------------------------
    // output logic
    //------------------------------------------------------------------------------
    always_comb begin : out_comb_blk
        ypos_q12_24_nxt = ypos_q12_24;
        // Default values
        case(state_nxt)
            IDLE: begin
                ypos_q12_24_nxt = 36'd700<<24;
            end
            UP: begin
                ypos_q12_24_nxt = ypos_q12_24 - 90; // Move up
            end
            WAIT: begin
                ypos_q12_24_nxt = ypos_q12_24 - 1;
            end
            DOWN: begin
                ypos_q12_24_nxt = ypos_q12_24 + 90; // Move down
            end
        endcase
    end
    
    endmodule
    