/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module draw right shape of a mouse on the screen
*/
module mouse_shape (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */
    logic [11:0] rgb_nxt;

    // Wymiary plusa
    localparam PLUS_SIZE = 16;       // Rozmiar plusa (15x15 pikseli)
    localparam LINE_WIDTH = 5;      // Szerokość linii plusa
    localparam RECT_COLOR = 12'hF00; // Kolor plusa (czerwony)

    /**
     * Internal logic
     */

    // Sequential logic for output signals
    always_ff @(posedge clk) begin : bg_rec_blk
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

    // Combinational logic for drawing the plus
    always_comb begin : rect_comb_blk
        // Sprawdzenie, czy piksel znajduje się w poziomej lub pionowej linii plusa
        if (
            // Pozioma linia plusa
            ((in.hcount >= (xpos - 7) + (PLUS_SIZE / 2 - LINE_WIDTH / 2)) &&
             (in.hcount < (xpos - 7) + (PLUS_SIZE / 2 + LINE_WIDTH / 2)) &&
             (in.vcount >= (ypos - 7)) &&
             (in.vcount < (ypos - 7) + PLUS_SIZE) ||

            // Pionowa linia plusa
            ((in.vcount >= (ypos - 7) + (PLUS_SIZE / 2 - LINE_WIDTH / 2)) &&
             (in.vcount < (ypos - 7) + (PLUS_SIZE / 2 + LINE_WIDTH / 2)) &&
             (in.hcount >= (xpos - 7)) &&
             (in.hcount < (xpos - 7) + PLUS_SIZE))))
         begin
            rgb_nxt = RECT_COLOR; // Piksel należy do plusa
        end else begin
            rgb_nxt = in.rgb; // Piksel należy do tła
        end
    end

endmodule