/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Łukasz Gąsecki
 * 
 * Description:
 * LFSR-based random number generator module.
 * This module generates pseudo-random numbers using a Linear Feedback Shift Register (LFSR).
 **/
 
module lfsr_random #(
    parameter WIDTH = 16  // Szerokość rejestru, np. 16-bitowy LFSR
)(
    input  logic clk,
    input  logic rst,
    input  logic enable,
    output logic [WIDTH-1:0] random
);

    logic [WIDTH-1:0] lfsr;
    logic feedback;

    // Przykład dla LFSR 16-bitowego z tapami: 16, 14, 13, 11
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 16'hACE1; // Dowolny niezerowy seed
            feedback <= 'b0;
        end else if (enable) begin
            feedback <= lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
            lfsr <= {lfsr[14:0], feedback};
        end
    end

    assign random = lfsr;

endmodule
