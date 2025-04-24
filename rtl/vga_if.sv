/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Łukasz Gąsecki & Oliwia Szewczyk
 * 
 *
 * Description:
 * This file contains the interface definitions for the VGA controller.
 */

interface vga_if();

    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
    logic [11:0] rgb;
    
    
modport in (input vcount, vsync, vblnk, hcount, hsync, hblnk, rgb);

modport out(output vcount, vsync, vblnk, hcount, hsync, hblnk, rgb);


endinterface

interface timing_if();
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
    
modport in_vga_timing (input vcount, vsync, vblnk, hcount, hsync, hblnk);

modport out_vga_timing (output vcount, vsync, vblnk, hcount, hsync, hblnk);
        

endinterface
    