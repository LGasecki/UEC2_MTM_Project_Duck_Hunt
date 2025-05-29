/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki
 *
 * Description:
 * Package with vga related constants.
 * This package contains parameters for VGA display timing and game constants.
 */

 package vga_pkg;

    // Parameters for VGA Display 1024x768 @ 60fps using a 65MHz MHz clock;
    localparam HOR_PIXELS = 1024;
    localparam VER_PIXELS = 768;

    // VGA Timing Parameters

    localparam START = 0;

    localparam HL_TOTAL_TIME = 1344; 
    localparam HL_BLANK_START = 1024;
    localparam HL_SYNC_START = 1048;
    localparam HL_SYNC_END = 1184;

    localparam VL_TOTAL_TIME = 806;
    localparam VL_BLANK_START = 768;
    localparam VL_SYNC_START = 771;
    localparam VL_SYNC_END = 777;

    //COLOURS
    localparam RGB_BLACK = 12'h000;
    localparam RGB_WHITE = 12'hFFF;
    localparam RGB_RED = 12'hF00;
    localparam RGB_GREEN = 12'h0F0;
    localparam RGB_BLUE = 12'h00F;
    localparam RGB_YELLOW = 12'hFF0;
    localparam RGB_CYAN = 12'h0FF;
    localparam RGB_MAGENTA = 12'hF0F;

    // GAME CONSTANTS
    // start screen parameters
    localparam START_CHAR_SIZE = 2;
    localparam START_CHAR_HEIGHT = 16 << START_CHAR_SIZE; // 16 pixels, 4x scaling
    localparam START_AREA_WIDTH = (10 * 8) << START_CHAR_SIZE; 
    localparam START_CHAR_XPOS = (HOR_PIXELS / 2) - (START_AREA_WIDTH / 2); //X_CENTER
    localparam START_CHAR_YPOS = 420;

    //duck parameters
    localparam DUCK_HEIGHT = 60;
    localparam DUCK_WIDTH = 96;
    localparam KILLED_DUCK_HEIGHT = 96;
    localparam KILLED_DUCK_WIDTH = 96;

    //score parameters
    localparam CHAR_HEIGHT = 16;
    localparam MY_SCORE_XPOS = HOR_PIXELS / 2 - 72;
    localparam MY_SCORE_YPOS = 710;
    localparam SCORE_SIZE = 2; // 2^SIZE = 4

    localparam ENEMY_SCORE_XPOS = HOR_PIXELS / 2 + 8;
    localparam ENEMY_SCORE_YPOS = 710;

endpackage
