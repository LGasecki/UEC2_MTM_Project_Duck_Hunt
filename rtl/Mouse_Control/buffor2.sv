/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module solve zjawisko metastabilności.

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
*/
module buffor2(
    input logic clk,
    input logic rst,
    input logic [11:0] xpos_bf1,
    input logic [11:0] ypos_bf1,
    
    output logic [11:0] xpos_bf2,
    output logic [11:0] ypos_bf2
);

    // Synchronizator dwustopniowy
    logic [11:0] xpos_sync1, xpos_sync2;
    logic [11:0] ypos_sync1, ypos_sync2;

    always_ff @(posedge clk) begin
        if (rst) begin
            xpos_sync1 <= '0;
            xpos_sync2 <= '0;
            ypos_sync1 <= '0;
            ypos_sync2 <= '0;
        end else begin
            xpos_sync1 <= xpos_bf1;       // Pierwszy etap synchronizacji
            xpos_sync2 <= xpos_sync1;     // Drugi etap synchronizacji
            ypos_sync1 <= ypos_bf1;
            ypos_sync2 <= ypos_sync1;
        end
    end

    // Wyjścia synchronizatora
    assign xpos_bf2 = xpos_sync2;
    assign ypos_bf2 = ypos_sync2;

endmodule