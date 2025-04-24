/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki & Oliwia Szewczyk
 *
 * Description:
 * Vga timing controller.
 */

 module vga_timing (
    input  logic clk,
    input  logic rst,

    timing_if.out_vga_timing out
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [10:0]vcount_nxt, hcount_nxt;
logic vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;


//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin 
    if (rst) begin 
        out.vcount <= START;
        out.hcount <= START;
        out.vsync <= START;
        out.vblnk <= START;
        out.hsync <= START;
        out.hblnk <= START;
    end else begin
        out.vcount <= vcount_nxt; 
        out.hcount <= hcount_nxt;
        out.vsync <= vsync_nxt;
        out.vblnk <= vblnk_nxt;
        out.hsync <= hsync_nxt;
        out.hblnk <= hblnk_nxt;
    end
 end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
 always_comb begin
    if(out.hcount == HL_TOTAL_TIME - 1) begin
        if(out.vcount == VL_TOTAL_TIME - 1) begin
            vcount_nxt = '0;
            vblnk_nxt = '0;
        end else begin
            vcount_nxt = out.vcount + 1;
            vblnk_nxt = out.vblnk;
        end
        hcount_nxt = '0;
        vblnk_nxt = ((out.vcount >= VL_BLANK_START - 1) && (out.vcount < VL_TOTAL_TIME - 1));
        vsync_nxt = ((out.vcount >= VL_SYNC_START - 1) && (out.vcount < VL_SYNC_END - 1));
    end else begin
        hcount_nxt = out.hcount + 1;
        vcount_nxt = out.vcount;
        vblnk_nxt = out.vblnk;
        vsync_nxt = out.vsync;
    end
    
    hblnk_nxt = ((out.hcount >= HL_BLANK_START - 1) && (out.hcount < HL_TOTAL_TIME - 1)); 
    hsync_nxt = ((out.hcount >= HL_SYNC_START - 1) && (out.hcount < HL_SYNC_END - 1)); 


end 
endmodule
 