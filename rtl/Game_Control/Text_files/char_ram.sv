module char_ram_char (
    input  logic        clk,
    input  logic [15:0] text_in,          // dwa znaki ASCII: [15:8] i [7:0]
    input  logic  [7:0] char_xy,          // indeks znaku: 0 lub 1
    output logic  [6:0] char_code         // wyjście: 7-bitowy kod ASCII
);

    // RAM na 2 znaki ASCII
    logic [7:0] ram [0:1];
    logic [6:0] char_code_nxt;

    // Ładowanie RAMu
    always_ff @(posedge clk) begin
            ram[0] <= text_in[15:8]; // pierwszy znak
            ram[1] <= text_in[7:0];  // drugi znak
    end

    // Odczyt z RAMu
    always_ff @(posedge clk) begin
        if (char_xy < 2)
            char_code <= char_code_nxt; // odczyt z RAMu
        else
            char_code <= 7'h20; // spacja, jeśli poza zakresem
    end

    always_comb begin
        char_code_nxt = ram[char_xy][6:0];
    end

endmodule
