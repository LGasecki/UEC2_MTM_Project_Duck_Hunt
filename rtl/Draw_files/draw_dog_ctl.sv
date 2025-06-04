/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Dog movement and animation state machine controller for game logic
# 
*/
 module draw_dog_ctl
    (
        input  wire  clk,  
        input  wire  rst,  
        input  wire  game_enable,

        output logic [11:0] dog_xpos,
        output logic [11:0] dog_ypos,
        output logic [3:0] photo_index
    );
    
    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam STATE_BITS = 3; // number of bits used for state register

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [35:0] dog_xpos_q12_24_nxt, dog_ypos_q12_24_nxt, dog_xpos_q12_24, dog_ypos_q12_24;
    logic [3:0] photo_index_nxt;
    logic [3:0] photo_index_ctr;
    logic [23:0] frame_divider, frame_divider_nxt; // dzieli 65MHz do np. ~15fps

    
    enum logic [STATE_BITS-1 :0] {
        IDLE = 3'b000,
        LEFT_MOVE      = 3'b001,
        SPOT_DUCK      = 3'b010,
        JUMP          = 3'b011,
        JUMP_FALL     = 3'b100
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
            IDLE: state_nxt = (game_enable) ? LEFT_MOVE : IDLE;
            LEFT_MOVE: state_nxt = (dog_xpos_q12_24[35:24] >= 12'd650) ? LEFT_MOVE : SPOT_DUCK;
            SPOT_DUCK: state_nxt = (dog_xpos_q12_24[35:24] < 12'd653) ? SPOT_DUCK : JUMP;
            JUMP: state_nxt = (dog_ypos_q12_24[35:24] > 12'd390) ? JUMP : JUMP_FALL;
            JUMP_FALL: state_nxt = (dog_ypos_q12_24[35:24] < 12'd600) ? JUMP_FALL : IDLE;
            default: state_nxt = IDLE; // Default case to handle unexpected states
        endcase
    end
    //------------------------------------------------------------------------------
    // output register
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : out_reg_blk
        if(rst) begin : out_reg_rst_blk
            {dog_xpos_q12_24, dog_ypos_q12_24} <= {36'd1024<<24, 36'd515<<24};
            {dog_xpos, dog_ypos} <= {12'd1024, 12'd515}; // Initial position of the dog
            photo_index <= 4'd0; // Initial photo index
            frame_divider <= 24'd0;
        end
        else begin : out_reg_run_blk
            {dog_xpos_q12_24, dog_ypos_q12_24} <= {dog_xpos_q12_24_nxt, dog_ypos_q12_24_nxt};
            {dog_xpos, dog_ypos} <= {dog_xpos_q12_24_nxt[35:24], dog_ypos_q12_24_nxt[35:24]};
            photo_index <= photo_index_nxt;
            frame_divider <= frame_divider_nxt;
        end
    end
    //------------------------------------------------------------------------------
    // output logic
    //------------------------------------------------------------------------------
    always_comb begin : out_comb_blk
        dog_xpos_q12_24_nxt = dog_xpos_q12_24;
        dog_ypos_q12_24_nxt = dog_ypos_q12_24;
        photo_index_nxt = photo_index;
        frame_divider_nxt = frame_divider;
        photo_index_ctr = photo_index;
        case(state_nxt)
            IDLE: begin
                dog_xpos_q12_24_nxt = 36'd1024 << 24; // Initial position of the dog
                dog_ypos_q12_24_nxt = 36'd515 << 24; // Initial position of the dog
                photo_index_nxt = 4'd0; // Initial photo index

            end

            LEFT_MOVE: begin
                dog_xpos_q12_24_nxt = dog_xpos_q12_24 - 26;
                dog_ypos_q12_24_nxt = dog_ypos_q12_24;
                frame_divider_nxt = frame_divider_nxt + 1;
                if (frame_divider >= (8_388_608)) begin 
                    frame_divider_nxt = 0;
                    photo_index_ctr = (photo_index_ctr == 5) ? 0 : photo_index_ctr + 1;
                end 
                photo_index_nxt = photo_index_ctr;

            end

            SPOT_DUCK: begin
                dog_xpos_q12_24_nxt = dog_xpos_q12_24 + 1;
                dog_ypos_q12_24_nxt = dog_ypos_q12_24;
                photo_index_nxt = 4'd6; 

            end

            JUMP: begin
                dog_xpos_q12_24_nxt = dog_xpos_q12_24 - 20;
                dog_ypos_q12_24_nxt = dog_ypos_q12_24 - 70;
                photo_index_nxt = 4'd7; // Index for the jumping photo
            end

            JUMP_FALL: begin
                dog_xpos_q12_24_nxt = dog_xpos_q12_24 - 20;
                dog_ypos_q12_24_nxt = dog_ypos_q12_24 + 50;
                photo_index_nxt = 4'd8; // Index for the falling photo
            end

            default: begin
                dog_xpos_q12_24_nxt = dog_xpos_q12_24;
                dog_ypos_q12_24_nxt = dog_ypos_q12_24;
                photo_index_nxt = photo_index; // Maintain current photo index
            end
        endcase

    end
    
    endmodule

