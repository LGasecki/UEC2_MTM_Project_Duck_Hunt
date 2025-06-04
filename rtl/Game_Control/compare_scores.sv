module compare_scores (
    input  logic enable,
    input  logic [6:0] my_score,       // Wynik gracza
    input  logic [6:0] enemy_score,   // Wynik przeciwnika
    output logic [1:0] winner_status  // 00: remis, 01: wygrana, 10: przegrana
);

    always_comb begin
        if (my_score > enemy_score) begin
            winner_status = 2'b01; // Wygrana
        end else if (my_score < enemy_score) begin
            winner_status = 2'b10; // Przegrana
        end else begin
            winner_status = 2'b00; // Remis
        end
    end

endmodule