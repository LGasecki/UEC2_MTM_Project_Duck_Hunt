/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Draws a moving rectangle on the VGA display, mapping its pixels from a memory array using provided coordinates and scaling.
# 
*/

module draw_moving_rect 
    #(parameter 
        WIDTH = 64, 
        HEIGHT = 48,
        SIZE = 1,
        PIXEL_ADDR_WIDTH = 12,
        INVERTED = 1 // 1 - inverted, 0 - normal
    )
    (  
    input  logic clk,
    input  logic rst,
    input  logic [11:0] rgb_pixel,
    input  logic game_enable,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,

    output logic [PIXEL_ADDR_WIDTH - 1:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);
    timeunit 1ns;
    timeprecision 1ps;

//---LOCAL_VARIABLES_&_SIGNALS---//

    logic [11:0] rgb_nxt;
    
    logic [11:0] rgb_I;
    logic [10:0] vcount_I, hcount_I;
    logic        vsync_I, vblnk_I, hsync_I, hblnk_I;

    logic [11:0] rgb_II;
    logic [10:0] vcount_II, hcount_II;
    logic        vsync_II, vblnk_II, hsync_II, hblnk_II;

    logic [PIXEL_ADDR_WIDTH - 1:0] pixel_x, pixel_y;

    
    always_ff @(posedge clk) begin : bg_ff_blk_I
        if (rst) begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <= '0;
        end else begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <= {in.vcount, in.vsync, in.vblnk, in.hcount, in.hsync, in.hblnk, in.rgb};
        end
    end 
    
    always_ff @(posedge clk) begin : bg_ff_blk_II
        if (rst) begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <= '0;
        end else begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <= {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I};
        end
    end
    
    always_ff @(posedge clk) begin : bg_ff_blk_nxt
        if (rst) begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= '0;
        end else begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_nxt};
        end
    end

    always_comb begin
        pixel_addr = 0;
        rgb_nxt = rgb_II;
    
        if (vblnk_II || hblnk_II) begin
            rgb_nxt = '0;
        end else begin
            if ((hcount_II >= xpos) && (hcount_II < (xpos + (WIDTH<<SIZE))) &&
                (vcount_II >= ypos) && (vcount_II < (ypos + (HEIGHT<<SIZE))) && game_enable) begin
                
                // tylko tutaj liczymy pixel_x/y
                if (INVERTED)
                    pixel_x = WIDTH - 1 - ((hcount_II - xpos) >> SIZE);
                else
                    pixel_x = ((hcount_II - xpos) >> SIZE);
                pixel_y = ((vcount_II - ypos) >> SIZE) * WIDTH;
                pixel_addr = pixel_y + pixel_x;
    
                if (pixel_addr < (WIDTH * HEIGHT)) begin
                    if (rgb_pixel == 12'hf08 | rgb_pixel == 12'h2be)
                        rgb_nxt = rgb_II;
                    else
                        rgb_nxt = rgb_pixel;
                end else begin
                    rgb_nxt = rgb_II;
                end
            end
        end
    end
    
endmodule

