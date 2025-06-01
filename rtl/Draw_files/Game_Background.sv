/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki,Oliwia Szewczyk
 * Description:
 * Draw background.
 */
 
 module Game_Background (
    input  logic clk,
    input  logic rst,

    timing_if.in_vga_timing in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    // 4_352 pixels = 64x17
    logic [11:0] cloud_mem [0:1_087];
    initial $readmemh("../../rtl/Data_files/cloud_64x17.data", cloud_mem);

    logic [11:0] rgb_nxt;
    logic [11:0] pixel_index;
    logic [5:0] small_x;  // 0..63
    logic [4:0] small_y;  // 0..16

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb    <= '0;
        end else begin
            out.vcount <= in.vcount;
            out.vsync  <= in.vsync;
            out.vblnk  <= in.vblnk;
            out.hcount <= in.hcount;
            out.hsync  <= in.hsync;
            out.hblnk  <= in.hblnk;
            out.rgb    <= rgb_nxt; 
        end
    end

    always_comb begin : bg_comb_bg_photo_blk
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = 12'h000;
        end else begin
            // if (in.vcount == 0)                     // - top edge:
            //     rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            // else if (in.vcount == VER_PIXELS - 1)   // - bottom edge:
            //     rgb_nxt = 12'hf_0_0;                // - - make a red line.
            // else if (in.hcount == 0)                // - left edge:
            //     rgb_nxt = 12'h0_f_0;                // - - make a green line.
            // else if (in.hcount == HOR_PIXELS - 1)   // - right edge:
            //     rgb_nxt = 12'h0_0_f;                // - - make a blue line.
            if(in.hcount >= 406 && in.vcount >=64 && in.hcount < 918 && in.vcount < 200) begin
                small_x = (in.hcount + 100) >> 3;  
                small_y = (in.vcount - 64) >> 3;  
                pixel_index = small_y * 64 + small_x;
                rgb_nxt = cloud_mem[pixel_index];

                end
            else begin
                rgb_nxt = 12'h2_b_e; // light blue
            end
        end
    end
 endmodule


    
