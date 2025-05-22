module bcd_to_string #(
    parameter N_DIGITS = 2  // liczba cyfr BCD (np. 4 -> 16-bitowy BCD)
)(
    input  logic [N_DIGITS*4-1:0] bcd_in,      // BCD input: np. 16-bit for 4 BCD digits
    output logic [8*N_DIGITS-1:0] ascii_out    // ASCII output string: np. 32-bit for 4 chars
);

    integer i;
    always_comb begin
        for (i = 0; i < N_DIGITS; i++) begin
            // Wyciągaj każdą cyfrę BCD i zamieniaj na znak ASCII ('0' + cyfra)
            ascii_out[8*(N_DIGITS-i)-1 -: 8] = "0" + bcd_in[4*(N_DIGITS-i)-1 -: 4];
        end
    end

endmodule
