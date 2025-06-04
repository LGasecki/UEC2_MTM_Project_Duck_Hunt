/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for top_vga.
 * Thanks to the tiff_writer module, an expected image
 * produced by the project is exported to a tif file.
 * Since the vs signal is connected to the go input of
 * the tiff_writer, the first (top-left) pixel of the tif
 * will not correspond to the vga project (0,0) pixel.
 * The active image (not blanked space) in the tif file
 * will be shifted down by the number of lines equal to
 * the difference between VER_SYNC_START and VER_TOTAL_TIME.
 */

module top_vga_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD_65MHz = 15.3846; // 65 MHz


    /**
     * Local variables and signals
     */

    logic clk65, rst;
    wire vs, hs;
    wire [3:0] r, g, b;
    wire ps2data, ps2clk;


    /**
     * Clock generation
     */

    initial begin
        clk65 = 1'b0;
        forever #(CLK_PERIOD_65MHz/2) clk65 = ~clk65;
    end

    /**
     * Submodules instances
     */

    top_vga dut (
        .clk65(clk65),
        .rst(rst),
        .vs(vs),
        .hs(hs),
        .r(r),
        .g(g),
        .b(b),
        .ps2_clk(ps2clk),
        .ps2_data(ps2data)
    );

    tiff_writer #(
        .XDIM(16'd1344),
        .YDIM(16'd806),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk65),
        .r({r,r}), // fabricate an 8-bit value
        .g({g,g}), // fabricate an 8-bit value
        .b({b,b}), // fabricate an 8-bit value
        .go(vs)
    );


    /**
     * Main test
     */

    initial begin
        rst = 1'b0;
        # 30 rst = 1'b1;
        # 30 rst = 1'b0;

        //ustawianie etapu gry
        force dut.u_top_game.start_screen_enable = 1'b1;
        force dut.u_top_game.start_pressed = 1'b0;
        force dut.u_top_game.game_enable = 1'b0;
        force dut.u_top_game.game_enable_posedge = 1'b0;
        force dut.u_top_game.game_finished = 1'b0;
        force dut.u_top_game.game_end_enable = 1'b0;

        force dut.u_top_game.enemy_start_game = 1'b0;
        force dut.u_top_game.enemy_ended_game = 1'b0;
        //zmienne do testu
        force dut.u_top_game.my_score = 7'd15;
        force dut.xpos = 12'd100;
        force dut.ypos = 12'd200;
        force dut.u_top_game.u_duck_ctl.ypos = 12'd500;
        force dut.u_top_game.u_draw_my_score.bin_number = 7'd30;
        force dut.u_top_game.u_draw_bullets.bullets_in_magazine = 3'd3;
        force dut.u_top_game.u_draw_duck.xpos = 200;
        force dut.u_top_game.u_draw_duck.ypos = 300;
        force dut.u_top_game.target_killed = 1;
        force dut.u_top_game.u_duck_rom.duck_killed = 1;
        force dut.u_top_game.u_draw_dog.xpos = 12'd700;
        force dut.u_top_game.u_draw_dog.ypos = 12'd500;
        force dut.u_top_game.u_dog_rom.dog_select = 4'd8;
        force dut.u_top_game.dog_bird_xpos = 12'd500;
        force dut.u_top_game.dog_bird_ypos = 12'd475;

        $display("If simulation ends before the testbench");
        $display("completes, use the menu option to run all.");
        $display("Prepare to wait a long time...");

        wait (vs == 1'b0);
        @(negedge vs) $display("Info: negedge VS at %t",$time);
        @(negedge vs) $display("Info: negedge VS at %t",$time);

        // End the simulation.
        $display("Simulation is over, check the waveforms.");
        $finish;
    end

endmodule
