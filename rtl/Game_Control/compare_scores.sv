/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: compare_scores module to determine the winner based on player and enemy scores
*/

module compare_scores (
    input  logic [6:0] my_score,       
    input  logic [6:0] enemy_score,   
    output logic [1:0] winner_status  // 00: remis, 01: wygrana, 10: przegrana
);

    always_comb begin
    
        if (my_score > enemy_score) begin
            winner_status = 2'b01; // Wygrana
        end else if (my_score < enemy_score) begin
            winner_status = 2'b10; // Przegrana
        end else begin
            winner_status = 2'b00; // Remis
        end
    end

endmodule