`timescale 1ns / 1ps

module duck_game_logic_tb;

    logic clk = 0;
    logic rst = 1;
    logic game_enable = 0;
    logic left_mouse = 0;
    logic right_mouse = 0;
    logic [15:0] lfsr_number = 16'hAB12;
    logic [11:0] mouse_xpos = 0;
    logic [11:0] mouse_ypos = 0;

    logic [11:0] target_xpos;
    logic [11:0] target_ypos;
    logic [3:0] bullets_count;
    logic reload_enable;
    logic [6:0] score;

    // Instantiate DUT
    duck_game_logic dut (
        .clk(clk),
        .rst(rst),
        .game_enable(game_enable),
        .left_mouse(left_mouse),
        .right_mouse(right_mouse),
        .lfsr_number(lfsr_number),
        .mouse_xpos(mouse_xpos),
        .mouse_ypos(mouse_ypos),
        .target_xpos(target_xpos),
        .target_ypos(target_ypos),
        .bullets_count(bullets_count),
        .reload_enable(reload_enable),
        .score(score)
    );

    // Clock generation (65MHz -> ~15.38ns period)
    always #8 clk = ~clk;

    // Task to print outputs
    task print_state;
        $display("State: %s | Time: %t |delay_ms: %d| Score: %0d | Bullets: %0d | Reload: %b | Target: (%0d, %0d)", 
                  dut.state, $time, dut.delay_ms_nxt, score, bullets_count, reload_enable, target_xpos, target_ypos);
    endtask

    initial begin
        $display("Starting test...");
        #20;
        rst = 0;
        print_state();
        // Start game
        game_enable = 1;
        #1000; // let it settle in DELAY state
        print_state();
        #20;
        #20;
        #20;
        // Simulate miss (click outside duck)
        left_mouse = 1;
        mouse_xpos = 0;
        mouse_ypos = 0;
        #20;
        left_mouse = 0;
        print_state();

        repeat (1000000) @(posedge clk);
        print_state();

        // Simulate hit
        mouse_xpos = target_xpos + 1;
        mouse_ypos = target_ypos + 1;
        left_mouse = 1;
        #20;
        left_mouse = 0;
        print_state();

        repeat (10000) @(posedge clk);
        left_mouse = 0;
        print_state();
        repeat (10000) @(posedge clk);
        print_state();
        repeat (10000) @(posedge clk);
        left_mouse = 0;
        print_state();
        repeat (10000) @(posedge clk);
        print_state();
        repeat (10000) @(posedge clk);
        left_mouse = 0;
        print_state();
        repeat (10000) @(posedge clk);
        print_state();
        repeat (10000) @(posedge clk);
        // Simulate bullets empty and reload
        dut.bullets_count = 0;
        left_mouse = 1;
        #20;
        left_mouse = 0;
        print_state();

        // Try reloading
        right_mouse = 1;
        #20;
        right_mouse = 0;
        print_state();

        #500;
        $display("Test finished.");
        $stop;
    end

endmodule
