module delay_ms #(
    parameter DELAY_MS    = 100  // liczba milisekund do odliczenia
    )(
        input  logic clk,
        input  logic rst,
        input  logic start,
        output logic done
        );
        
    localparam CLK_FREQ_HZ = 65_000_000;
    localparam int CYCLES_PER_MS = CLK_FREQ_HZ / 1000;
    localparam int TOTAL_CYCLES  = CYCLES_PER_MS * DELAY_MS;

    logic [31:0] counter;
    logic        running;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            running <= 0;
            counter <= 0;
            done    <= 0;
        end else begin
            if (start && !running) begin
                running <= 1;
                counter <= 0;
                done    <= 0;
            end else if (running) begin
                if (counter < TOTAL_CYCLES - 1) begin
                    counter <= counter + 1;
                end else begin
                    running <= 0;
                    done    <= 1;
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule
