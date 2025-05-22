module char_ram (
    input  logic        clk,
    input  logic        load_text,        // sygnał załadunku dwóch znaków
    input  logic [13:0] text_in,          // dwa znaki ASCII: [15:8] i [7:0]
    input  logic  [7:0] char_xy,          // indeks znaku: 0 lub 1
    output logic  [6:0] char_code         // wyjście: 7-bitowy kod ASCII
);

    // RAM na 2 znaki ASCII
    logic [6:0] ram [0:1];
    logic unused_bit; // nieużywany bit

    // Ładowanie RAMu
    always_ff @(posedge clk) begin
        if (load_text) begin
            ram[0] <= text_in[13:7]; // pierwszy znak
            ram[1] <= text_in[6:0];  // drugi znak
        end
    end

    // Odczyt z RAMu
    always_ff @(posedge clk) begin
        if (char_xy < 2)
            char_code <= ram[char_xy][6:0];
        else
            char_code <= 7'h20; // spacja, jeśli poza zakresem
    end

endmodule