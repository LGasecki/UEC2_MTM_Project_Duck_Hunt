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
        $display("State: %15s | Time: %10d |delay_ms: %4d| Score: %0d | Bullets: %0d | Reload: %b | Target: (%0d, %0d)", 
                  dut.state, $time, dut.delay_ms, score, bullets_count, reload_enable, target_xpos, target_ypos);
    endtask

    initial begin
        $display("Starting test...");
        #20;
        rst = 0;
        #20
        print_state();
        // Start game
        game_enable = 1;
        #20;
        print_state();
        #1000;
        $display("START GAME pressed...");
        print_state();
        #400;

        // Simulate miss (click outside duck)
        $display("Missing the target...");
        left_mouse = 1;
        mouse_xpos = 1200;
        mouse_ypos = 800;
        #100;
        left_mouse = 0;
        print_state();

        repeat (1000) @(posedge clk);
        print_state();
        #400;
        // Simulate hit
        $display("Hit the target!");
        mouse_xpos = target_xpos + 4;
        mouse_ypos = target_ypos + 4;
        left_mouse = 1;
        #100;
        left_mouse = 0;
        #40
        print_state();
        repeat (1000) @(posedge clk) ;
        print_state();
        #400;
        // Simulate bullets empty and reload
        $display("Trying to shoot with no bullets...");
        dut.bullets_count_nxt = 0;
        #200;
        left_mouse = 1;
        #20;
        left_mouse = 0;
        print_state();
        #400;

        // Try reloading
        $display("Reloading...");
        right_mouse = 1;
        #100;
        right_mouse = 0;
        print_state();

        #500;
        print_state();
        $display("Test finished.");
        $stop;
    end

endmodule
