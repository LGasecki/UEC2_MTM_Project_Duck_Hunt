/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki,Oliwia Szewczyk
 * Description:
 * Draw background.
 */
 
 module grass_draw (
    input  logic game_enable,
    input  logic clk,
    input  logic rst,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    //128 x 35 = 4480
    logic [11:0] image_mem [0:4479];
    initial $readmemh("../../rtl/Draw_files/grass_128x35.data", image_mem);

    logic [11:0] rgb_nxt;
    logic [13:0] pixel_index;
    logic [6:0] small_x;  
    logic [6:0] small_y;  

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
    if (!in.vblnk && !in.hblnk && game_enable &&
        in.vcount >= 488 && in.vcount < 768) begin
        small_x = in.hcount >> 3;  // dzielenie przez 8
        small_y = (in.vcount - 488) >> 3; // przesunięcie względem dolnej granicy
        pixel_index = small_y * 128 + small_x;

        if(image_mem[pixel_index] == 12'h2BE )begin
            rgb_nxt = in.rgb; 
        end else begin
            rgb_nxt = image_mem[pixel_index];
        end 
    end else begin
            rgb_nxt = in.rgb; // domyślnie przepuszczamy dalej obraz
        end
    end
endmodule
