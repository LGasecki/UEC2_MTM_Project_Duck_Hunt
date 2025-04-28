/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module draw mouse on the screen
*/

module draw_mouse(
    input logic rst,
    input logic clk,
    input logic [11:0]xpos,
    input logic [11:0]ypos,
    
    vga_if.in in,
    vga_if.out out
    
);

timeunit 1ns;
timeprecision 1ps;

always_ff @(posedge clk) begin
    if (rst) begin
        out.vcount <= '0;
        out.vsync  <= '0;
        out.vblnk  <= '0;
        out.hcount <= '0;
        out.hsync  <= '0;
        out.hblnk  <= '0;
    end else begin    
    out.hblnk <= in.hblnk;
    out.vblnk <= in.vblnk;
    out.vsync <= in.vsync;
    out.hsync <= in.hsync;
    out.hcount <= in.hcount;
    out.vcount <= in.vcount;
    end
end

MouseDisplay u_mouse_display(
    .pixel_clk(clk),
    .xpos(xpos),
    .ypos(ypos),
    .hcount(in.hcount),
    .vcount(in.vcount),
    .blank(in.vblnk|in.hblnk),
    .rgb_in(in.rgb),
    .enable_mouse_display_out(),
    .rgb_out(out.rgb)

);

endmodule