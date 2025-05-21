/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Łukasz Gąsecki
 * coautor: Oliwia Szewczyk
 * Description:
 * This module draws duck image.
 **/


 module draw_duck
    #(parameter 
        DUCK_WIDTH = 96,
        DUCK_HEIGHT = 60
    )
    (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    input  logic [11:0] rgb_pixel,
    input  logic game_enable,
    input  logic duck_direction,
    output logic [12:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);
    timeunit 1ns;
    timeprecision 1ps;

//---LOCAL_VARIABLES_&_SIGNALS---//
    //localparam int REC_COLOR = 'hFFFFFF; 

    logic [11:0] rgb_nxt;
    logic [11:0] rgb1, rgb2;
    logic [10:0] hcount1, hcount2;
    logic [11:0] xpos1, xpos2;
    logic hblnk1, hblnk2;
    logic [10:0] vcount1, vcount2;
    logic [11:0] ypos1, ypos2;
    logic vblnk1, vblnk2;
    logic hsync1, vsync1;
    logic hsync2, vsync2;
    
    
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount1 <= '0;
            ypos1  <= '0;
            vblnk1  <= '0;
            hcount1 <= '0;
            xpos1  <= '0;
            hblnk1  <= '0;
            rgb1    <= '0;
            pixel_addr <= '0;
            hsync1  <= '0;
            vsync1  <= '0;
        end else begin
            vcount1 <= in.vcount;
            ypos1  <= ypos;
            vblnk1  <= in.vblnk;
            hcount1 <= in.hcount;
            xpos1  <= xpos;
            hblnk1  <= in.hblnk;
            rgb1    <= in.rgb;
            hsync1  <= in.hsync;
            vsync1  <= in.vsync;
            pixel_addr <= (in.vcount - ypos) * DUCK_WIDTH +  (duck_direction ? (DUCK_WIDTH - 1 - (in.hcount - xpos)) : (in.hcount - xpos));
        end
    end



    always_ff @(posedge clk) begin
        if (rst) begin
            vcount2 <= '0;
            ypos2 <= '0;
            vblnk2  <= '0;
            hcount2 <= '0;
            xpos2  <= '0;
            hblnk2  <= '0;
            rgb2    <= '0;
            hsync2  <= '0;
            vsync2  <= '0;
        end else begin
            vcount2 <= vcount1;
            ypos2 <= ypos1;
            vblnk2  <= vblnk1;
            hcount2 <= hcount1;
            xpos2  <= xpos1;
            hblnk2  <= hblnk1;
            rgb2    <= rgb1;
            hsync2  <= hsync1;
            vsync2  <= vsync1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb    <= '0;
        end else begin
            out.vcount <= vcount2;
            out.vblnk  <= vblnk2;
            out.hcount <= hcount2;
            out.hblnk  <= hblnk2;
            out.rgb    <= rgb_nxt;
            out.hsync  <= hsync2;
            out.vsync  <= vsync2;
        end
    end
    

    always_comb begin : bg_comb_blk 
            if ((hcount2 >= xpos2) && (hcount2 < (xpos2 + DUCK_WIDTH)) &&
                (vcount2 >= ypos2) && (vcount2 < (ypos2 + DUCK_HEIGHT) && game_enable && !hblnk2 && !vblnk2)) begin
                if (rgb_pixel == 12'hFFF) begin
                    rgb_nxt = rgb2; // Jeśli piksel jest biały, użyj tła
                end else begin
                    rgb_nxt = rgb_pixel; // Jeśli piksel nie jest biały, rysuj go
                end
            end else begin
                rgb_nxt = rgb2;
            end
        end
endmodule

