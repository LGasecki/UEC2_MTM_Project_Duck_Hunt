/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified by: Łukasz Gąsecki
 * Description:
 * Draw background.
 */
// i am here 
 
 module Game_Background (
    input  logic clk,
    input  logic rst,

    timing_if.in_vga_timing in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    // 128x96 = 12-288 pixels
    logic [11:0] image_mem [0:12_287];
    initial $readmemh("../../rtl/Background/duck_hunt_background_128x96.data", image_mem);

    logic [11:0] rgb_nxt;
    logic [13:0] pixel_index;
    logic [6:0] small_x;  // 0..127
    logic [6:0] small_y;  // 0..96

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
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = 12'h000;
        end else begin
            if (in.vcount == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            else if (in.vcount == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (in.hcount == 0)                // - left edge:
            rgb_nxt = 12'h0_f_0;                // - - make a green line.
            else if (in.hcount == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;                // - - make a blue line.
            else begin
                small_x = in.hcount >> 3;  
                small_y = in.vcount >> 3;  
                pixel_index = small_y * 128 + small_x;
                rgb_nxt = image_mem[pixel_index];
            end
        end
    end
 endmodule


    

    // /**
    //  * Local variables and signals
    //  */
    //     // Add your code here.
    // localparam int CENTER_X_L = 320; // Center of "Ł"
    // localparam int CENTER_X_G = 480; // Center of "G"
    // localparam int CENTER_Y   = 300; // Vertical center
    // localparam int WIDTH      = 100; // Letter width
    // localparam int HEIGHT     = 200; // Letter height
    // localparam int LINE_THICK = 18;  // Line thickness

    // logic [11:0] rgb_nxt;


    // /**
    //  * Internal logic
    //  */

    // always_ff @(posedge clk) begin : bg_ff_blk
    //     if (rst) begin
    //         out.vcount <= '0;
    //         out.vsync  <= '0;
    //         out.vblnk  <= '0;
    //         out.hcount <= '0;
    //         out.hsync  <= '0;
    //         out.hblnk  <= '0;
    //         out.rgb    <= '0;
    //     end else begin
    //         out.vcount <= in.vcount;
    //         out.vsync  <= in.vsync;
    //         out.vblnk  <= in.vblnk;
    //         out.hcount <= in.hcount;
    //         out.hsync  <= in.hsync;
    //         out.hblnk  <= in.hblnk;
    //         out.rgb    <= rgb_nxt; 
    //     end
    // end

    // always_comb begin : bg_comb_blk
    //     if (in.vblnk || in.hblnk) begin             // Blanking region:
    //         rgb_nxt = 12'h0_0_0;                    // - make it black.
    //     end else begin                              // Active region:
    //         if (in.vcount == 0)                     // - top edge:
    //         rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
    //         else if (in.vcount == VER_PIXELS - 1)   // - bottom edge:
    //         rgb_nxt = 12'hf_0_0;                // - - make a red line.
    //         else if (in.hcount == 0)                // - left edge:
    //         rgb_nxt = 12'h0_f_0;                // - - make a green line.
    //         else if (in.hcount == HOR_PIXELS - 1)   // - right edge:
    //         rgb_nxt = 12'h0_0_f;                // - - make a blue line.

    //         else if (
    //         // "Ł" 'diagonal with copilot assistance'
    //         (in.hcount >= CENTER_X_L - WIDTH/2 && in.hcount <= CENTER_X_L - WIDTH/2 + LINE_THICK && in.vcount >= CENTER_Y - HEIGHT/2 && in.vcount <= CENTER_Y + HEIGHT/2) || // Vertical
    //         (in.hcount >= CENTER_X_L - WIDTH/2 && in.hcount <= CENTER_X_L + WIDTH/2 && in.vcount >= CENTER_Y + HEIGHT/2 - LINE_THICK && in.vcount <= CENTER_Y + HEIGHT/2) || // Bottom
    //         (in.hcount + in.vcount >= 2 * CENTER_X_L - 3 * LINE_THICK) && (in.hcount <= CENTER_X_L - (LINE_THICK / 2)) && // Diagonal
    //         (in.hcount + in.vcount <= 2 * CENTER_X_L - 2 * LINE_THICK) && (in.hcount >= CENTER_X_L - WIDTH + (LINE_THICK)) || // Diagonal
    //         // "G"
    //         (in.hcount >= CENTER_X_G - WIDTH/2 && in.hcount <= CENTER_X_G - WIDTH/2 + LINE_THICK && in.vcount >= CENTER_Y - HEIGHT/2 && in.vcount <= CENTER_Y + HEIGHT/2) || // Left vertical
    //         (in.hcount >= CENTER_X_G - WIDTH/2 && in.hcount <= CENTER_X_G + WIDTH/2 && in.vcount >= CENTER_Y - HEIGHT/2 && in.vcount <= CENTER_Y - HEIGHT/2 + LINE_THICK) || // Top
    //         (in.hcount >= CENTER_X_G - WIDTH/2 && in.hcount <= CENTER_X_G + WIDTH/2 && in.vcount >= CENTER_Y + HEIGHT/2 - LINE_THICK && in.vcount <= CENTER_Y + HEIGHT/2) || // Bottom
    //         (in.hcount >= CENTER_X_G + WIDTH/2 - LINE_THICK && in.hcount <= CENTER_X_G + WIDTH/2 && in.vcount >= CENTER_Y && in.vcount <= CENTER_Y + HEIGHT/2) || // Right vertical
    //         (in.hcount >= CENTER_X_G && in.hcount <= CENTER_X_G + WIDTH - LINE_THICK && in.vcount >= CENTER_Y && in.vcount <= CENTER_Y + LINE_THICK) // Middle
    //         )
    //         rgb_nxt = 12'hf_0_0; 

    //         else                                   
    //         rgb_nxt = 12'h8_8_8;              
    //         end
    //     end
