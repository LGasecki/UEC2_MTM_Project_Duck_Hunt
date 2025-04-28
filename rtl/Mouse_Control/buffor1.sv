/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module solve zjawisko metastabilności.
*/
module buffor1(
    input logic clk,
    input logic rst,
    input logic [11:0]xpos,
    input logic [11:0]ypos,
    
    output logic [11:0]xpos_bf1,
    output logic [11:0]ypos_bf1
);
    always_ff @(posedge clk) begin
        if (rst) begin
            xpos_bf1 <= '0;
            ypos_bf1 <= '0;
        end else begin
            xpos_bf1 <= xpos;
            ypos_bf1 <= ypos;
        end
    end

endmodule