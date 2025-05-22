`timescale 1ns / 1ps

module duck_game_logic_tb;

    logic clk = 0;
    logic rst = 1;
    logic game_enable = 0;
    logic left_mouse = 0;
    logic right_mouse = 0;
    logic [11:0] mouse_xpos = 0;
    logic [11:0] mouse_ypos = 0;
    logic [11:0] duck_xpos = 100;
    logic [11:0] duck_ypos = 100;

    logic [2:0] bullets_in_magazine;
    logic [5:0] bullets_left;
    logic [6:0] my_score;
    logic hunt_start;
    logic show_reload_char;

    // Instantiate DUT
    duck_game_logic dut (
        .clk(clk),
        .rst(rst),
        .game_enable(game_enable),
        .left_mouse(left_mouse),
        .right_mouse(right_mouse),
        .mouse_xpos(mouse_xpos),
        .mouse_ypos(mouse_ypos),
        .duck_xpos(duck_xpos),
        .duck_ypos(duck_ypos),
        .bullets_in_magazine(bullets_in_magazine),
        .bullets_left(bullets_left),
        .my_score(my_score),
        .hunt_start(hunt_start),
        .show_reload_char(show_reload_char)
    );

    // Clock generation
    always #8 clk = ~clk;

    task print_state;
        $display("Time: %10t | Score: %0d | Mag: %0d | Left: %0d | Reload: %b | Hunt: %b", 
                  $time, my_score, bullets_in_magazine, bullets_left, show_reload_char, hunt_start);
    endtask

    initial begin
        $display("=== Starting Duck Game Logic Testbench ===");
        #20;
        rst = 0;
        #20;
        print_state();

        // Start game
        game_enable = 1;
        #20;
        print_state();
        repeat (300_000) @(posedge clk); // wait ~4ms
        #40
        print_state();

        // Simulate miss (click outside duck)
        $display(">>> Simulating miss...");
        left_mouse = 1;
        mouse_xpos = 1200;
        mouse_ypos = 800;
        #20;
        left_mouse = 0;
        repeat (10) @(posedge clk);
        #40
        print_state();

        // Simulate hit (click on duck)
        $display(">>> Simulating hit...");
        mouse_xpos = duck_xpos + 2;
        mouse_ypos = duck_ypos + 2;
        #100;
        left_mouse = 1;
        #20;
        left_mouse = 0;
        repeat (10) @(posedge clk);
        #40
        print_state();

        // Deplete magazine
        $display(">>> Depleting magazine...");
        repeat (3) begin
            mouse_xpos = duck_xpos + 1;
            mouse_ypos = duck_ypos + 1;
            #100;
            left_mouse = 1;
            #20;
            left_mouse = 0;
            repeat (10) @(posedge clk);
            #40
            print_state();
        end

        // Try to shoot with empty mag
        $display(">>> Try shooting with empty mag...");
        left_mouse = 1;
        #20;
        left_mouse = 0;
        #40
        print_state();

        // Reload
        $display(">>> Reloading...");
        right_mouse = 1;
        #20;
        right_mouse = 0;
        repeat (300_000) @(posedge clk); // wait for RELOAD_TIME
        #40
        print_state();

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule
