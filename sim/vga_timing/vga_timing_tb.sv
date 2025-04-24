/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_FREQ = 65;     


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;

    timing_if tif();


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(1_000_000_000 / (CLK_FREQ << 2)) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #50 rst = 1'b1;
        rst = 1'b1;
        #100 rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .out(tif)
    );

    /**
     * Tasks and functions
     */
    assign vcount = tif.vcount;
    assign hcount = tif.hcount;
    assign vsync  = tif.vsync;
    assign vblnk  = tif.vblnk;
    assign hsync  = tif.hsync;
    assign hblnk  = tif.hblnk;

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */

    property clk_toggles;
        @(posedge clk) 1'b1;
    endproperty
    
    assert property (clk_toggles)
        else $error ("Error: Clock is not toggling as expected.");

    assert property (@(posedge clk) disable iff(rst) ##1((hcount >=0)&&(hcount<=HL_TOTAL_TIME - 1)) )
        else $error ("hcount over range: %d", hcount);
    
    assert property (@(posedge clk) disable iff(rst) ##1 ((vcount >=0)&&(vcount<=VL_TOTAL_TIME - 1)) )
        else $error ("vcount over range: %d", vcount);
    
    assert property (@(posedge hblnk) ((hcount == HL_BLANK_START - 1)))
        else $error ("Horizontal blank start not in time on hcount = %d", hcount);

    assert property (@(negedge hblnk) disable iff(rst) ((hcount == HL_TOTAL_TIME - 1)))
        else $error ("Horizontal blank ends not in time on hcount = %d", hcount);
    
    assert property (@(posedge vblnk) ((vcount == VL_BLANK_START - 1)) )
        else $error ("Vertical blank starts not in time on vcount =  %d", vcount);
        
    assert property (@(negedge vblnk) disable iff(rst) ((vcount == VL_TOTAL_TIME - 1)) )
        else $error ("Vertical blank starts not in time on vcount = %d", vcount);
    
    assert property (@(posedge vsync) ((vcount == VL_SYNC_START - 1)) )
        else $error ("vsync starts not in time on vcount = %d", vcount);
    
    assert property (@(negedge vsync) disable iff(rst) ((vcount == VL_SYNC_END - 1)) )
        else $error ("vsync ends not in time on vcount = %d", vcount);
    
    assert property (@(posedge hsync) ((hcount == HL_SYNC_START - 1)) )
        else $error ("hsync starts not in time on hcount = %d", hcount);

    assert property (@(negedge hsync) disable iff(rst) ((hcount == HL_SYNC_END - 1)) )
        else $error ("hsync ends not in time on hcount = %d", hcount);


    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule
