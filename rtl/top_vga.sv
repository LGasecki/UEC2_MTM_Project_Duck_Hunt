/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk,
 * Łukasz Gąsecki
 * Oliwia Szewczyk
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk65,
        input  logic rst,
        input  logic clk100,

        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        inout ps2_clk,
        inout ps2_data

    );

    timeunit 1ns;
    timeprecision 1ps;

     /**
     * Interface declarations
      */


    timing_if timing_if();
    vga_if background_if();
    vga_if draw_mouse();


    /**
     * Local variables and signals
     */

    import vga_pkg::*;

    logic [11:0]xpos;
    logic [11:0]ypos;
    logic [11:0]xpos_bf1;
    logic [11:0]ypos_bf1;
    logic [11:0]xpos_bf2;
    logic [11:0]ypos_bf2;
    
    /**
     * Signals assignments
     */
    
    assign vs = background_if.vsync;
    assign hs = background_if.hsync;
    assign {r,g,b} = background_if.rgb;
    
    
    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(clk65),
        .rst,

        .out(timing_if)
    );

    Game_Background u_game_background (
        .clk(clk100),
        .rst(rst),

        .in(timing_if),
        .out(background_if)
    );

    MouseCtl u_MouseCtl (
        .ps2_clk (ps2_clk),
        .ps2_data (ps2_data),
        .xpos (xpos),
        .ypos (ypos),
        .clk (clk100),
        .rst (rst),
        .value(12'b0),
        .setx('b0),
        .sety('b0),
        .setmax_x('b0),
        .setmax_y('b0),
        .new_event(),
        .zpos(),
        .left(),
        .middle(),
        .right()
    );

    buffor1 u_buffor1(
        .clk(clk65),
        .rst(rst),
        .xpos(xpos),
        .ypos(ypos),
        .xpos_bf1(xpos_bf1),
        .ypos_bf1(ypos_bf1)
    );

    buffor2 u_buffor2(
        .clk(clk65),
        .rst(rst),
        .xpos_bf1(xpos_bf1),
        .ypos_bf1(ypos_bf1),
        .xpos_bf2(xpos_bf2),
        .ypos_bf2(ypos_bf2)
    );

    draw_mouse u_draw_mouse(
        .rst,   
        .clk(clk65),
        .xpos(xpos_bf2),
        .ypos(ypos_bf2),
        
        .in(background_if),
        .out(draw_mouse)
        
        );

 
endmodule
