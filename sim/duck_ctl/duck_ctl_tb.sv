`timescale 1ns / 1ps

module duck_ctl_tb;

  // Clock parameters
  localparam CLK_PERIOD_NS = 15.3846; // 65MHZ = 15.3846ns

  // Signals
  logic clk, rst;
  logic game_enable;
//   logic target_killed;
  logic [9:0] lfsr_number;
  logic [11:0] xpos, ypos;

  // Instantiate DUT
  duck_ctl dut (
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable),
    // .target_killed(target_killed),
    .lfsr_number(lfsr_number),
    .xpos(xpos),
    .ypos(ypos)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD_NS / 2) clk = ~clk;
  end

  // Testbench logic
  initial begin
    int fd;
    fd = $fopen("../../results/duck_ctl_output.csv", "w");
    if (!fd) begin
      $display("ERROR: Cannot open output file.");
      $finish;
    end

    // Header for CSV
    $fdisplay(fd, "xpos;ypos");

    // Initial reset
    rst = 1;
    game_enable = 0;
    // target_killed = 0;
    lfsr_number = 16'hA222; // Arbitrary non-zero start value
    #(10 * CLK_PERIOD_NS);
    rst = 0;

    // Start game after some delay
    #(10 * CLK_PERIOD_NS);
    game_enable = 1;

    // Let it run for a while
    repeat (2500) begin
      @(posedge clk);
      $fdisplay(fd, "%0d;%0d", xpos, ypos);
    end

    // Simulate target kill
    // target_killed = 1;
    @(posedge clk);
    $fdisplay(fd, "%0d,%0d", xpos, ypos);

    $fclose(fd);
    $display("Simulation complete. Output written to duck_ctl_output.csv");
    $finish;
  end

endmodule
