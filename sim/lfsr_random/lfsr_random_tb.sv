`timescale 1ns/1ps
/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Łukasz Gąsecki
 * 
 * Description:
 * Testbench for lfsr_random module.
**/
module lfsr_random_tb;

    // Parametry i sygnały
    parameter WIDTH = 16;
    logic clk;
    logic rst;
    logic enable;
    logic [WIDTH-1:0] random;

    // Instancja testowanego modułu
    lfsr_random #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .random(random)
    );

    // Generowanie zegara: 10ns okres
    always #5 clk = ~clk;

    // Monitorowanie zmian wartości pseudolosowej
    always_ff @(posedge clk) begin
        if (enable && !rst)
            $display("Time: %1t | Random = %0h      |  Random_dec = %0d", $time, random, random);
    end

    initial begin
        // Inicjalizacja
        clk = 0;
        rst = 1;
        enable = 0;

        // Reset przez kilka cykli
        #12;
        rst = 0;
        enable = 1;

        // Czas działania testu
        #1000;

        // Wyłączenie i zakończenie
        enable = 0;
        #10;
        $finish;
    end

endmodule
