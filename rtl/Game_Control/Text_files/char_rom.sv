/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description: Character ROM module for storing and retrieving ASCII codes based on input coordinates
# 
*/
module char_rom 
    #(parameter string TEXT = 
    {"START GAME"},
    parameter TEXT_SIZE = 10 // rozmiar tekstu
) 
(
    input  logic       clk,
    input  logic [7:0] char_xy,
    output logic [6:0] char_code    // 7-bit ASCII output
);

    logic [6:0] char_code_nxt;

    logic [7:0] rom [0:TEXT_SIZE - 1];

    initial begin : init_rom
        for (int i = 0; i < TEXT_SIZE; i++) begin
                rom[i] = TEXT[i];  // zamiana znaku na kod ASCII

        end
    end

    always_ff @(posedge clk) begin
        char_code <= char_code_nxt;
    end

    always_comb begin
        char_code_nxt = rom[char_xy][6:0];
    end
    
endmodule
