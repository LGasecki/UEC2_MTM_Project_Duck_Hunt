/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Duck game logic controller for a shooting game 
# 
*/
 module duck_game_logic

    (
        input  wire  clk,  // posedge active clock
        input  wire  rst,  // high-level active synchronous reset
        
        input  wire  [11:0] mouse_xpos, 
        input  wire  [11:0] mouse_ypos,
        input  wire  left_mouse,
        input  wire  right_mouse,
        input  wire  game_enable,

        input  wire  [11:0] duck_xpos,
        input  wire  [11:0] duck_ypos,

        output logic [2:0] bullets_in_magazine,
        output logic [6:0] bullets_left,
        output logic [6:0] my_score,
        output logic hunt_start,
        output logic show_reload_char,
        output logic duck_killed,
        output logic dog_bird_enable
    );
    
    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam DUCK_HEIGHT = 60;
    localparam DUCK_WIDTH = 96;
    localparam STATE_BITS = 2; // number of bits used for state register

    localparam COUNTDOWN    = 7500 * 65_000; // countdown value at start of the game T - 8000ms
    localparam DEATH_TIME   = 4500 * 65_000; // time for duck fall after death T - 6000ms
    //FOR TESTS
    // localparam COUNTDOWN    = 40; 
    // localparam DEATH_TIME   = 20; 
    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [2:0] bullets_in_magazine_nxt;
    logic [6:0] bullets_left_nxt;
    logic left_mouse_prev, left_mouse_posedge, right_mouse_posedge, right_mouse_prev;
    logic [31:0] delay_ms, delay_ms_nxt;
    logic [6:0] my_score_nxt;
    logic hunt_start_nxt, duck_killed_nxt;
    
    enum logic [STATE_BITS-1 :0] {
        WAIT_FOR_START = 2'b00,
        HUNTING        = 2'b01,
        RELOADING      = 2'b10,
        DELAY          = 2'b11
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
            
            DELAY:      if (right_mouse_posedge)
                            state_nxt = RELOADING;
                        else if (delay_ms == 0)
                            state_nxt = HUNTING;
                        else
                            state_nxt = DELAY;
            
            HUNTING:    if (right_mouse_posedge) 
                            state_nxt = RELOADING;
                        else if(duck_killed)
                            state_nxt = DELAY;
                        // else if (!bullets_in_magazine && !bullets_left && left_mouse_posedge && ENEMYPOITS = 0)
                        //     state_nxt = WAIT_FOR_START;
                        else 
                            state_nxt = HUNTING;

            RELOADING:      state_nxt = DELAY;
        endcase
    end
    //------------------------------------------------------------------------------
    // output register
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : out_reg_blk
        if(rst) begin : out_reg_rst_blk
            bullets_in_magazine <= 3;
            bullets_left <= 15;
            delay_ms <= COUNTDOWN;
            left_mouse_prev <= 0;
            right_mouse_prev <= 0;
            my_score <= 0;
            hunt_start <= 0;
            show_reload_char <= 0;
            duck_killed <= 0;
            dog_bird_enable <= 0;
        end
        else begin : out_reg_run_blk
            bullets_in_magazine <= bullets_in_magazine_nxt;
            bullets_left <= bullets_left_nxt;
            delay_ms <= delay_ms_nxt;
            left_mouse_prev <= left_mouse;
            right_mouse_prev <= right_mouse;
            my_score <= my_score_nxt;
            hunt_start <= hunt_start_nxt;
            show_reload_char <= !bullets_in_magazine_nxt;
            duck_killed <= duck_killed_nxt;
            dog_bird_enable <= (duck_killed_nxt == 1 && delay_ms_nxt == 2500* 65_000) ? 1 : 0;
        end
    end
    //------------------------------------------------------------------------------
    // output logic
    //------------------------------------------------------------------------------
    always_comb begin : out_comb_blk
        // Domyślne przypisania — zapobiegają latchom!
        bullets_in_magazine_nxt = bullets_in_magazine;
        bullets_left_nxt         = bullets_left;
        delay_ms_nxt             = delay_ms;
        hunt_start_nxt           = hunt_start;
        my_score_nxt             = my_score;
        left_mouse_posedge = (left_mouse == 1 && left_mouse_prev == 0);
        right_mouse_posedge = (right_mouse == 1 && right_mouse_prev == 0);
        duck_killed_nxt = 0;

        case(state_nxt)
            WAIT_FOR_START: begin
                hunt_start_nxt = 0;
                delay_ms_nxt = COUNTDOWN;
                bullets_in_magazine_nxt = 3;
                bullets_left_nxt = 15;
                my_score_nxt = 0;
                duck_killed_nxt = 0;
            end
            DELAY: begin
                hunt_start_nxt = 0;
                bullets_in_magazine_nxt = bullets_in_magazine;
                bullets_left_nxt = bullets_left;
                my_score_nxt = my_score;
                duck_killed_nxt = duck_killed;
                if (delay_ms == 0)
                    delay_ms_nxt = 0;
                else 
                    delay_ms_nxt = delay_ms - 1;
            end
            HUNTING: begin
                hunt_start_nxt = 1;
                delay_ms_nxt = 0;
                bullets_in_magazine_nxt = bullets_in_magazine;
                bullets_left_nxt = bullets_left;
                my_score_nxt = my_score;
                duck_killed_nxt = 0;

                if (left_mouse_posedge && game_enable) begin
                    if (bullets_in_magazine > 0) begin
                        bullets_in_magazine_nxt = bullets_in_magazine - 1;
                        bullets_left_nxt = bullets_left;
                        if (mouse_xpos >= duck_xpos && mouse_xpos <= duck_xpos + DUCK_WIDTH &&
                            mouse_ypos >= duck_ypos && mouse_ypos <= duck_ypos + DUCK_HEIGHT) begin
                            my_score_nxt = my_score + 1;
                            delay_ms_nxt = DEATH_TIME;
                            duck_killed_nxt = 1;
                        end
                    end
                end
            end

            RELOADING: begin
                hunt_start_nxt = 1;
                delay_ms_nxt = delay_ms;
                // bullets_left_nxt = bullets_left + bullets_in_magazine - 3;
                bullets_left_nxt = (bullets_left + bullets_in_magazine <= 3) ? 0 : bullets_left + bullets_in_magazine - 3;
                bullets_in_magazine_nxt = (bullets_left + bullets_in_magazine < 3) ? bullets_left[2:0] + bullets_in_magazine  : 3;
                my_score_nxt = my_score;
                duck_killed_nxt = duck_killed;
            end
        endcase
    end
    
    endmodule
    