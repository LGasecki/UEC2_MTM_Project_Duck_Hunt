/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module implements the start screen for the game.
# It displays the "START GAME" text on the screen.
*/
module draw_rect_char
    #(parameter 
        WIDTH = 32,         // ilość znaków w poziomie
        CHAR_XPOS = 450,    
        CHAR_YPOS = 370
    )
    (
        input logic clk,
        input logic rst,
        input logic [7:0] char_line_pixels,
        input logic enable,

        output logic [7:0] char_xy,
        output logic [3:0] char_line,
    
        vga_if.in in,
        vga_if.out out
    );

    import vga_pkg::*;

    // VGA pipeline signals
    logic [11:0] rgb_I, rgb_II, rgb_III, rgb_nxt;
    logic [10:0] vcount_I, vcount_II, vcount_III;
    logic [10:0] hcount_I, hcount_II, hcount_III;
    logic vsync_I, vsync_II, vsync_III;
    logic vblnk_I, vblnk_II, vblnk_III;
    logic hsync_I, hsync_II, hsync_III;
    logic hblnk_I, hblnk_II, hblnk_III;
    
    logic [7:0] char_xy_nxt;
    logic [3:0] char_line_nxt;
    logic [7:0] pixel_index;
    logic [2:0] bit_index;
    
    // 3x skalowanie: zmieniamy indeks znaków na podstawie podziału na 3×16px i 3×8px
    assign char_xy_nxt = {3'd0, (in.hcount - CHAR_XPOS) / 24};
    assign char_line_nxt = (vcount_I - CHAR_YPOS) / 3; // skalujemy 3× pionowo 
    
    always_ff @(posedge clk) begin
        if (rst) begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <= '0;
            char_xy <= '0;
            char_line <= '0;
        end else begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <=
                {in.vcount, in.vsync, in.vblnk, in.hcount, in.hsync, in.hblnk, in.rgb};
            char_xy <= char_xy_nxt;
            char_line <= char_line_nxt;
        end
    end
    
    
    always_ff @(posedge clk) begin
        if (rst) begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <= '0;
        end else begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <=
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I};
        end
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            {vcount_III, vsync_III, vblnk_III, hcount_III, hsync_III, hblnk_III, rgb_III} <= '0;
        end else begin
            {vcount_III, vsync_III, vblnk_III, hcount_III, hsync_III, hblnk_III, rgb_III} <=
                {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II};
        end
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= '0;
        end else begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <=
                {vcount_III, vsync_III, vblnk_III, hcount_III, hsync_III, hblnk_III, rgb_nxt};
        end
    end
    
    // Skala 3x: zmieniamy granice i sposób indeksowania
    always_comb begin
        if (hcount_III >= CHAR_XPOS && hcount_III < (CHAR_XPOS + WIDTH * 8 * 3) &&
            vcount_III >= CHAR_YPOS && vcount_III < (CHAR_YPOS + 16 * 3) && enable) begin
    
            pixel_index = (hcount_III - CHAR_XPOS) / 3; 
            bit_index = 7 - (pixel_index % 8);          
            if (char_line_pixels[bit_index]) begin
                rgb_nxt = 12'hAAA; // biały
            end else begin
                rgb_nxt = rgb_III;
            end
        end else begin
            rgb_nxt = rgb_III;
        end
    end
    
    endmodule
    