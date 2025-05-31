`timescale 1ns / 1ps

module draw_dog_ctl_tb;

    // Deklaracje sygnałów
    logic clk;
    logic rst;
    logic game_enable;

    logic [11:0] dog_xpos;
    logic [11:0] dog_ypos;
    logic [3:0] photo_index;
    logic behind_grass;

    // Instancja modułu testowanego
    draw_dog_ctl dut (
        .clk(clk),
        .rst(rst),
        .game_enable(game_enable),
        .dog_xpos(dog_xpos),
        .dog_ypos(dog_ypos),
        .photo_index(photo_index),
        .behind_grass(behind_grass)
    );

    // Generacja zegara 65 MHz (15.384 ns okres => ~7.692 ns półokres)
    initial clk = 0;
    always #7.692 clk = ~clk;

    // Plik CSV
    integer f;
    initial f = $fopen("../../results/dog_position.csv", "w");

    // Test główny
    initial begin
        // Nagłówki
        $fwrite(f, "time_ns,dog_xpos,dog_ypos,photo_index,behind_grass\n");

        // Reset początkowy
        rst = 1;
        game_enable = 0;
        repeat (5) @(posedge clk);
        rst = 0;

        // Start gry
        @(posedge clk);
        game_enable = 1;

        // Symulacja przez około 2 ms (130000 cykli przy 65 MHz)
        repeat (130000) begin
            @(posedge clk);
            $fwrite(f, "%0t,%0d,%0d,%0d,%0d\n", $time, dog_xpos, dog_ypos, photo_index, behind_grass);
        end

        // Koniec
        $fclose(f);
        $finish;
    end

endmodule
