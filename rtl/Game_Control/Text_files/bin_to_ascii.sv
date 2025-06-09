/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Description:
# This module converts a binary number (0-99) to its ASCII representation.
# 
*/
module bin_to_ascii (
    input  logic [7:0] bin_in,          // binarna liczba 0–99
    output logic [6:0] ascii_tens,      // ASCII znak dziesiątek
    output logic [6:0] ascii_ones       // ASCII znak jedności
);

    logic [3:0] tens, ones;

    always_comb begin
        tens  = bin_in / 10;
        ones  = bin_in % 10;

        ascii_tens = 7'h30 + tens;      // '0' + dziesiątki
        ascii_ones = 7'h30 + ones;      // '0' + jedności
    end

endmodule
    