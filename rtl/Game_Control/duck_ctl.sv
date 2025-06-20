/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Duck controller for game logic, controlling duck movement and state transitions
# 
*/
module duck_ctl
    #(parameter
    GROUND = 620 // maximum Y position
    

)
(
    input  wire  clk,  
    input  wire  rst, 
    input  wire  game_enable,
    input  wire  target_killed, 
    input  wire  [9:0] lfsr_number,
    
    output logic [11:0] xpos,
    output logic [11:0] ypos,
    output logic duck_direction
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 3; // number of bits used for state register
localparam X_MAX = 1024;

localparam DUCK_HEIGHT = 32;
localparam DUCK_WIDTH = 96;

localparam [35:0] GROUND_Q12_24 = GROUND << 24; //maximum Y position in q12.24 format

localparam X_SPEED = 120; // x speed in q12.24 format
localparam Y_SPEED = 120; // y speed in q12.24 format
localparam DEAD_SPEED = 100; // y speed for dead duck in q12.24 format

// localparam X_SPEED = 1 << 24; //for testbench
// localparam Y_SPEED = 1 << 24; 

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [35:0] xpos_q12_24, ypos_q12_24, xpos_nxt_q12_24, ypos_nxt_q12_24;
logic [9:0] saved_number, saved_number_nxt;


enum logic [STATE_BITS-1 :0] {
    IDLE = 3'd0,
    SIDE = 3'b1,
    UP_RIGHT = 3'd2,
    UP_LEFT = 3'd3,
    DOWN_RIGHT = 3'd4,
    DOWN_LEFT = 3'd5,
    KILLED = 3'd6

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
    state_nxt = state;  // domyślna wartość
    case(state)
        IDLE:    state_nxt = game_enable ?  SIDE : IDLE;
        SIDE:    state_nxt = (xpos_q12_24[35:24] >= X_MAX>>2) ? UP_LEFT : UP_RIGHT;
        UP_RIGHT: 
            if(xpos_q12_24[35:24] >= X_MAX - DUCK_WIDTH) 
                state_nxt = UP_LEFT;
            else if(ypos_q12_24[35:24] <= 0)
                state_nxt = DOWN_RIGHT;
            else if(target_killed)
                state_nxt = KILLED;
        UP_LEFT:
            if(xpos_q12_24[35:24] <= 0) 
                state_nxt = UP_RIGHT;
            else if(ypos_q12_24[35:24] <= 0)
                state_nxt = DOWN_LEFT;
            else if(target_killed)
                state_nxt = KILLED;
        DOWN_RIGHT:
            if(xpos_q12_24[35:24] >= X_MAX - DUCK_WIDTH) 
                state_nxt = DOWN_LEFT;
            else if(ypos_q12_24[35:24] >= GROUND - DUCK_HEIGHT)
                state_nxt = UP_RIGHT;
            else if(target_killed)
                state_nxt = KILLED;
        DOWN_LEFT:
            if(xpos_q12_24[35:24] <= 0) 
                state_nxt = DOWN_RIGHT;
            else if(ypos_q12_24[35:24] >= GROUND - DUCK_HEIGHT)
                state_nxt = UP_LEFT;
            else if(target_killed)
                state_nxt = KILLED;

        KILLED: 
            if(target_killed) 
                state_nxt = KILLED;
            else if(ypos_q12_24[35:24] >= GROUND - DUCK_HEIGHT) 
                state_nxt = IDLE;

    endcase
end
//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if(rst) begin : out_reg_rst_blk
        {xpos, ypos} <= 0;
        xpos_q12_24 <= 512 << 24;
        ypos_q12_24 <= 0;
        duck_direction <= 0;
        saved_number <= 0;
    end
    else begin : out_reg_run_blk
        {xpos, ypos} <= {xpos_nxt_q12_24[35:24], ypos_nxt_q12_24[35:24]};
        {xpos_q12_24, ypos_q12_24} <= {xpos_nxt_q12_24, ypos_nxt_q12_24};
        duck_direction <= (state == UP_LEFT || state == DOWN_LEFT) ? 1 : 0;
        saved_number <= saved_number_nxt;
    end
end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    xpos_nxt_q12_24 = xpos_q12_24;
    ypos_nxt_q12_24 = ypos_q12_24;
    saved_number_nxt = (state != state_nxt && state_nxt != (IDLE || SIDE) && state != (IDLE || SIDE)) ? lfsr_number[9:0] : saved_number; 
    // default values
    case(state_nxt)
        IDLE: begin
            saved_number_nxt = 10'b1111111111; 
            if(lfsr_number[9:0] >= X_MAX - DUCK_WIDTH)
                xpos_nxt_q12_24 = {2'b0,(lfsr_number[9:0] - DUCK_WIDTH), 24'b0};
            else
                xpos_nxt_q12_24 = {2'b0,lfsr_number[9:0], 24'b0};
            ypos_nxt_q12_24 = GROUND_Q12_24;
        end
        UP_RIGHT: begin
            xpos_nxt_q12_24 = xpos_q12_24 + X_SPEED + saved_number[9:3];
            ypos_nxt_q12_24 = ypos_q12_24 - Y_SPEED - saved_number[6:0];
            
        end
        UP_LEFT: begin
            xpos_nxt_q12_24 = xpos_q12_24 - X_SPEED - saved_number[9:3];
            ypos_nxt_q12_24 = ypos_q12_24 - Y_SPEED - saved_number[6:0];
        end
        DOWN_RIGHT: begin
            xpos_nxt_q12_24 = xpos_q12_24 + X_SPEED + saved_number[9:3];
            ypos_nxt_q12_24 = ypos_q12_24 + Y_SPEED + saved_number[6:0];
        end
        DOWN_LEFT: begin
            xpos_nxt_q12_24 = xpos_q12_24 - X_SPEED - saved_number[9:3];
            ypos_nxt_q12_24 = ypos_q12_24 + Y_SPEED + saved_number[6:0];
        end
        SIDE: begin
            if(lfsr_number[9:0] >= X_MAX - DUCK_WIDTH)
                xpos_nxt_q12_24 = {2'b0,(lfsr_number[9:0] - DUCK_WIDTH), 24'b0};
            else
                xpos_nxt_q12_24 = {2'b0,lfsr_number[9:0], 24'b0};
            ypos_nxt_q12_24 = GROUND_Q12_24 - (DUCK_HEIGHT << 24);
            saved_number_nxt = 10'b1111111111;
        end
        KILLED: begin
            if(ypos_q12_24[35:24] >= GROUND - DUCK_HEIGHT) begin
                xpos_nxt_q12_24 = xpos_q12_24;
                ypos_nxt_q12_24 = GROUND_Q12_24;;
            end
            else begin
                xpos_nxt_q12_24 = xpos_q12_24;
                ypos_nxt_q12_24 = ypos_q12_24 + DEAD_SPEED;
            end
        end

    endcase
end

endmodule
