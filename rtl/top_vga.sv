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
 *
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
        output logic [3:0] b

    );

    timeunit 1ns;
    timeprecision 1ps;

     /**
     * Interface declarations
      */


    timing_if timing_if();


    /**
     * Local variables and signals
     */

    import vga_pkg::*;

    
    
    /**
     * Signals assignments
     */
    
    assign vs = timing_if.vsync;
    assign hs = timing_if.hsync;
    assign {r,g,b} = timing_if.rgb;
    
    
    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(clk65),
        .rst,

        .out(timing_if)
    );


 
endmodule
