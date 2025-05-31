

module draw_dog (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] rgb_pixel,
    input  logic game_enable,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,

    output logic [12:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);
    timeunit 1ns;
    timeprecision 1ps;

//---LOCAL_VARIABLES_&_SIGNALS---//
    localparam REC_WIDTH = 55<<1;
    localparam REC_HEIGHT = 48<<1;

    logic [11:0] rgb_nxt;
    
    logic [11:0] rgb_I;
    logic [10:0] vcount_I, hcount_I;
    logic        vsync_I, vblnk_I, hsync_I, hblnk_I;

    logic [11:0] rgb_II;
    logic [10:0] vcount_II, hcount_II;
    logic        vsync_II, vblnk_II, hsync_II, hblnk_II;


    
    
    always_ff @(posedge clk) begin : bg_ff_blk_I
        if (rst) begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <= '0;
        end else begin
            {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I} <= {in.vcount, in.vsync, in.vblnk, in.hcount, in.hsync, in.hblnk, in.rgb};
        end
    end 
    
    always_ff @(posedge clk) begin : bg_ff_blk_II
        if (rst) begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <= '0;
        end else begin
            {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_II} <= {vcount_I, vsync_I, vblnk_I, hcount_I, hsync_I, hblnk_I, rgb_I};
        end
    end
    
    always_ff @(posedge clk) begin : bg_ff_blk_nxt
        if (rst) begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= '0;
        end else begin
            {out.vcount, out.vsync, out.vblnk, out.hcount, out.hsync, out.hblnk, out.rgb} <= {vcount_II, vsync_II, vblnk_II, hcount_II, hsync_II, hblnk_II, rgb_nxt};
        end
    end
    
    always_comb begin : bg_comb_blk_I
        //DRAWING
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = '0;
        end else begin
            if ((in.hcount >= xpos) && (in.hcount < (xpos + REC_WIDTH)) &&
            (in.vcount >= ypos) && (in.vcount < (ypos + REC_HEIGHT))) begin
                rgb_nxt = 12'hFFF;;
            end else begin
                rgb_nxt = rgb_II;
            end
        end
        pixel_addr = {6'((in.vcount - ypos)>>1), 6'((in.hcount - xpos)>>1)};   //---PIXEL_TO_COLOR_ADRESS---//
    end
    
endmodule

