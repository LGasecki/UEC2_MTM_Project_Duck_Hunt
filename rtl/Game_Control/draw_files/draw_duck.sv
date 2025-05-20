
module draw_duck
    #(parameter 
        DUCK_WIDTH = 96,
        DUCK_HEIGHT = 32
    )
    (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    input  logic game_enable,

    vga_if.in in,
    vga_if.out out
);
    timeunit 1ns;
    timeprecision 1ps;

//---LOCAL_VARIABLES_&_SIGNALS---//
    localparam int REC_COLOR = 'hFFFFFF; 

    logic [11:0] rgb_nxt;
    

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

    always_comb begin : bg_comb_blk 
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = '0;
        end else begin
            if ((in.hcount >= xpos) && (in.hcount < (xpos + DUCK_WIDTH)) &&
                (in.vcount >= ypos) && (in.vcount < (ypos + DUCK_HEIGHT) && game_enable)) begin
                rgb_nxt = REC_COLOR[11:0];
            end else begin
                rgb_nxt = in.rgb;
            end
        end
    end
endmodule

