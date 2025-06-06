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
        input  logic rx,

        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        output logic tx,

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
    vga_if draw_mouse_if();
    vga_if mouse_shape_if();
    vga_if game_if();


    /**
     * Local variables and signals
     */

    import vga_pkg::*;

    logic [11:0]xpos;
    logic [11:0]ypos;
    logic left_mouse, right_mouse;
    logic [7:0] uart_data_send, uart_data_recieved;

    
    /**
     * Signals assignments
     */
    
    assign vs = mouse_shape_if.vsync;
    assign hs = mouse_shape_if.hsync;
    assign {r,g,b} = mouse_shape_if.rgb;
    
    
    /**
     * Submodules instances
     */
    
    MouseCtl u_MouseCtl (
        .ps2_clk (ps2_clk),
        .ps2_data (ps2_data),
        .xpos (xpos),
        .ypos (ypos),
        .clk (clk65),
        .rst (rst),
        .value(12'b0),
        .setx('b0),
        .sety('b0),
        .setmax_x('b0),
        .setmax_y('b0),
        .new_event(),
        .zpos(),
        .left(left_mouse),
        .middle(),
        .right(right_mouse)
    );

    vga_timing u_vga_timing (
        .clk(clk65),
        .rst,

        .out(timing_if)
    );

    Game_Background u_game_background (
        .clk(clk65),
        .rst(rst),

        .in(timing_if),
        .out(background_if)
    );

    mouse_shape u_mouse_shape (
        .clk(clk65),
        .rst,
        .xpos (xpos),
        .ypos (ypos),
        .in(game_if),
        .out(mouse_shape_if)

    );

    top_game u_top_game (
        .clk(clk65),
        .rst,
        .mouse_xpos(xpos),
        .mouse_ypos(ypos),
        .left_mouse(left_mouse),
        .right_mouse(right_mouse),
        .uart_data_in(uart_data_recieved),

        .in(background_if),
        .out(game_if),

        .uart_data_out(uart_data_send)
    );

    /**
     * Uart module instantiation
     */

     top_uart u_top_uart (
        .clk(clk65),
        .rst(rst),
        .rx, 
        .uart_data_send(uart_data_send),
        .uart_data_recieved(uart_data_recieved),
        .tx
     );

endmodule
