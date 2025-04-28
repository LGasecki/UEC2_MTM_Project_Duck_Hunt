/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module solve zjawisko metastabilności.
*/
module buffor2(
    input logic clk,
    input logic rst,
    input logic [11:0]xpos_bf1,
    input logic [11:0]ypos_bf1,
    
    output logic [11:0]xpos_bf2,
    output logic [11:0]ypos_bf2
);
    always_ff @(posedge clk) begin
        if (rst) begin
            xpos_bf2 <= '0;
            ypos_bf2 <= '0;
        end else begin
            xpos_bf2 <= xpos_bf1;
            ypos_bf2 <= ypos_bf1;
        end
    end

endmodule