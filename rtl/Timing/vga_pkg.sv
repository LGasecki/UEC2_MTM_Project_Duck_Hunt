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

    // GAME CONSTANTS
    // start screen parameters
    localparam START_AREA_WIDTH = 10 * 8 * 4; // 10 characters, 8 pixels per character, 4x scaling
    localparam AREA_HEIGHT = 16 * 4; // 16 pixels, 4x scaling
    localparam START_CHAR_XPOS = (HOR_PIXELS / 2) - (START_AREA_WIDTH / 2); //X_CENTER
    localparam START_CHAR_YPOS = 420;

    //duck parameters
    localparam DUCK_HEIGHT = 60;
    localparam DUCK_WIDTH = 96;
    localparam KILLED_DUCK_HEIGHT = 96;
    localparam KILLED_DUCK_WIDTH = 96;

    //bullet parameters
    localparam BULLET_HEIGHT = 16;
    localparam BULLET_WIDTH = 48;

    //score parameters
    localparam SCORE_XPOS = 20;
    localparam SCORE_YPOS = 700;

endpackage
