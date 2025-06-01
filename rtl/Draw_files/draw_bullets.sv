/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: 
# This module draws the bullets on the screen.
*/
module draw_bullets (
    input  logic game_enable,
    input  logic clk,
    input  logic rst,
    input  logic [2:0] bullets_in_magazine,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    localparam BULLET_WIDTH      = 56; // 28 * 2
    localparam BULLET_HEIGHT     = 56; // 28 * 2
    localparam BULLET_ORIG_SIZE  = 28;
    localparam BASE_X            = 12;
    localparam BASE_Y            = 709;
    localparam GAP               = 6;

    logic [11:0] bullet_mem [0:783];
    initial $readmemh("../../rtl/Data_files/bullet_28x28.data", bullet_mem);

    logic [11:0] rgb_nxt;
    logic [9:0] pixel_index;
    logic [1:0] i;
    logic [9:0] x0, y0;
    logic [5:0] local_x, local_y;

    always_ff @(posedge clk) begin
        if (rst) begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= '0;
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

    always_comb begin
        rgb_nxt = in.rgb;

        if (!in.vblnk && !in.hblnk && game_enable) begin
            for (i = 0; i < 3; i++) begin
                if (i < bullets_in_magazine) begin
                    x0 = BASE_X + i * (BULLET_WIDTH - GAP);
                    y0 = BASE_Y;

                    if (in.hcount >= x0 && in.hcount < x0 + BULLET_WIDTH &&
                        in.vcount >= y0 && in.vcount < y0 + BULLET_HEIGHT) begin

                        local_x = (in.hcount - x0) >> 1;
                        local_y = (in.vcount - y0) >> 1;
                        pixel_index = local_y * BULLET_ORIG_SIZE + local_x;

                        if (pixel_index < 784) begin
                            if (bullet_mem[pixel_index] != 12'hF00)
                                rgb_nxt = bullet_mem[pixel_index];
                            // else leave rgb_nxt = in.rgb;
                        end
                    end
                end
            end
        end
    end

endmodule
