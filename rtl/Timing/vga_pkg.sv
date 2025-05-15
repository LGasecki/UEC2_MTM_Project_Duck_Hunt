/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki
 *
 * Description:
 * Package with vga related constants.
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
    localparam START_AREA_WIDTH = 10 * 24; // 10 characters
    localparam AREA_HEIGHT = 48;
    localparam START_CHAR_XPOS = (HOR_PIXELS / 2) - (START_AREA_WIDTH / 2); //CENTER
    localparam START_CHAR_YPOS = 320;

endpackage
