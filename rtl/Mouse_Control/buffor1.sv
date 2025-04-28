/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Oliwia Szewczyk
# Description: 
# this module solve zjawisko metastabilności.

module buffor1(
    input logic clk,
    input logic rst,
    input logic [11:0]xpos,
    input logic [11:0]ypos,
    
    output logic [11:0]xpos_bf1,
    output logic [11:0]ypos_bf1
);

    logic [11:0]xpos_nxt;
    logic [11:0]ypos_nxt;


    always_ff @(posedge clk) begin
        if (rst) begin
            xpos_nxt <= '0;
            ypos_nxt <= '0;
        end else begin
            xpos_nxt <= xpos;
            ypos_nxt <= ypos;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            xpos_bf1 <= '0;
            ypos_bf1 <= '0;
        end else begin
            xpos_bf1 <= xpos_nxt;
            ypos_bf1 <= ypos_nxt;
        end
    end

endmodule

*/

module buffor1(
    input logic clk,
    input logic rst,
    input logic [11:0] xpos,
    input logic [11:0] ypos,
    
    output logic [11:0] xpos_bf1,
    output logic [11:0] ypos_bf1
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
            xpos_sync1 <= xpos;       // Pierwszy etap synchronizacji
            xpos_sync2 <= xpos_sync1; // Drugi etap synchronizacji
            ypos_sync1 <= ypos;
            ypos_sync2 <= ypos_sync1;
        end
    end

    // Wyjścia synchronizatora
    assign xpos_bf1 = xpos_sync2;
    assign ypos_bf1 = ypos_sync2;

endmodule