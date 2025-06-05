
/**
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Łukasz Gąsecki
# Coauthor: Oliwia Szewczyk
# Description: 
# This module is the top-level module for the game control system.
*/

module top_game(
    input logic clk,
    input logic rst,
    input logic [11:0] mouse_xpos,
    input logic [11:0] mouse_ypos,
    input logic left_mouse,
    input logic right_mouse,
    input logic [7:0] uart_data_in,

    output logic [7:0] uart_data_out,

    vga_if.in in,
    vga_if.out out

    );

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

// LOCAL PARAMETERS
localparam logic [3:0] LFSR_WIDTH = 10; // Width of the LFSR



//--------------------------------//
// LOCAL VARIABLES
logic [LFSR_WIDTH-1:0] random_number;
logic start_screen_enable, game_enable, game_end_enable, game_enable_posedge;
logic duck_direction;
logic [11:0] duck_xpos, duck_ypos, dog_xpos, dog_ypos, 
             dog_bird_xpos, dog_bird_ypos;
logic [12:0] pixel_addr;
logic [10:0] pixel_addr_dog_bird;
logic [11:0] pixel_addr_dog;
logic [11:0] pixel_addr_dog_grass;
logic [15:0] pixel_addr_grass;
logic [11:0] rgb_pixel, dog_rgb_pixel, rgb_grass;
logic [11:0] dog_bird_rgb_pixel;
logic [2:0] bullets_in_magazine;
logic [6:0] bullets_left;
logic [6:0] my_score;
logic [6:0] enemy_score;
logic enemy_start_game;
logic enemy_ended_game;
logic hunt_start;
logic show_reload_char;
logic target_killed;
logic [3:0] dog_photo_index;
logic dog_bird_enable;
logic start_pressed;
logic game_finished;
logic [1:0] winner_status; // 00: remis, 01: wygrana, 10: przegrana
logic [15:0] start_logo_address;
logic [11:0] start_logo_rgb;

vga_if start_screen_if();
vga_if logo_if();
vga_if waiting_for_enemy_start_if();
vga_if duck_if();
vga_if dog_bird_if();
vga_if dog_behind_grass_if();
vga_if grass_if();
vga_if dog_if();
vga_if bullets_if();
vga_if reload_if();
vga_if slash_if();
vga_if bullets_left_if();
vga_if your_points_if();
vga_if enemy_points_if();
vga_if my_score_if();
vga_if enemy_score_if();
vga_if your_points_if_end();
vga_if enemy_points_if_end();
vga_if my_score_if_end();
vga_if enemy_score_if_end();
vga_if draw_winner_status_if_draw();
vga_if draw_winner_status_if_winner();

//UART LOGIC
assign uart_data_out = {start_pressed, game_finished, my_score[5:0]}; // Send game status and score to UART POPRAWKA
assign enemy_score = {1'b0,uart_data_in[5:0]}; // Receive enemy score from UART
assign enemy_ended_game = uart_data_in[6]; // Receive enemy ended game signal from UART
assign enemy_start_game = uart_data_in[7]; // Receive enemy start game signal from UART



//------------------------------------------------------------------------------
// MODULES
//------------------------------------------------------------------------------
lfsr_random  // generator liczb pseudolosowych
#(
    .WIDTH(LFSR_WIDTH)
)
 lfsr (
    .clk(clk),
    .rst(rst),
    .enable(game_enable || start_screen_enable),
    .random(random_number)
);

// CONTROL
game_control_fsm u_game_control_fsm (  //Sterowanie etapami gry: Ekran startowy-> Czekanie na start 2 gracza -> Gra -> Czekanie na koniec 2 gracza -> Ekran końcowy
    .clk(clk),
    .rst(rst),
    .left_mouse(left_mouse),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),
    .game_finished(bullets_left == 0 && bullets_in_magazine == 0),
    .enemy_ended(enemy_ended_game),
    .enemy_start(enemy_start_game),
    .start_pressed(start_pressed),
    .game_ended(game_finished),
    .start_screen_enable(start_screen_enable),
    .game_enable_posedge(game_enable_posedge),
    .game_enable(game_enable),
    .game_end_enable(game_end_enable)

);

//START SCREEN------------------------------------------------------
draw_string 
#(
    .CHAR_XPOS(START_CHAR_XPOS), // X position 
    .CHAR_YPOS(START_CHAR_YPOS), // Y position 
    .WIDTH(10), // number of characters in the horizontal direction
    .SIZE(START_CHAR_SIZE), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_BLACK), // RGB color for the character
    .TEXT("START GAME") // text to be displayed
)
u_start_screen (
    .clk(clk),
    .rst(rst),
    .enable(start_screen_enable),

    .in(in),
    .out(start_screen_if)
);

draw_moving_rect 
#(
    .WIDTH(256),
    .HEIGHT(196),
    .SIZE(1),
    .PIXEL_ADDR_WIDTH(16), // 2^18 = 262144
    .INVERTED(0) 
)u_draw_logo (
    .clk(clk),
    .rst(rst),
    .game_enable(!game_end_enable && !game_enable),
    .xpos(12'd256),
    .ypos(12'd20),
    .rgb_pixel(start_logo_rgb),

    .pixel_addr(start_logo_address),
    .in(start_screen_if),
    .out(logo_if)
);

//WAITING FOR SECOND PLAYER--------------------------------

draw_string 
#(
    .CHAR_XPOS(244), // X position
    .CHAR_YPOS(START_CHAR_YPOS), // Y position
    .WIDTH(17), 
    .SIZE(2), 
    .COLOUR(RGB_YELLOW), 
    .TEXT("WAITING FOR ENEMY")
)
u_waiting_for_enemy_start (
    .clk(clk),
    .rst(rst),
    .enable(!start_screen_enable && !game_end_enable && !game_enable),

    .in(logo_if),
    .out(waiting_for_enemy_start_if)
);


//GAME--------------------------------------------------------------
//control
duck_ctl u_duck_ctl (   // Odpowiedzialne za poruszanie celu
    .game_enable(hunt_start && game_enable),
    .clk(clk),
    .rst(rst),
    .lfsr_number(random_number),
    .target_killed(target_killed),

    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .duck_direction(duck_direction)
);

duck_game_logic u_duck_game_logic (     // Odpowiedzialne za logikę gry oraz dane
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable),
    .left_mouse(left_mouse),
    .right_mouse(right_mouse),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos),
    .duck_xpos(duck_xpos),
    .duck_ypos(duck_ypos),

    .my_score(my_score),
    .bullets_in_magazine(bullets_in_magazine),
    .bullets_left(bullets_left),
    .show_reload_char(show_reload_char),
    .hunt_start(hunt_start),
    .duck_killed(target_killed),
    .dog_bird_enable(dog_bird_enable)
);

draw_dog_ctl u_draw_dog_ctl ( 
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable_posedge),

    .dog_xpos(dog_xpos),
    .dog_ypos(dog_ypos),
    .photo_index(dog_photo_index)
);


dog_bird_ctl u_dog_bird_ctl ( // Odpowiedzialne za poruszanie psa po zabojstwie
    .clk(clk),
    .rst(rst),
    .enable(dog_bird_enable),
    .duck_xpos(duck_xpos),

    .xpos(dog_bird_xpos),
    .ypos(dog_bird_ypos)
);

//------------------------------------------------------------------------------
//drawing on screen
draw_duck 
#(
    .DUCK_WIDTH(DUCK_WIDTH),
    .DUCK_HEIGHT(DUCK_HEIGHT)
) 
u_draw_duck (
    .game_enable((hunt_start || target_killed) && game_enable),
    .clk(clk),
    .rst(rst),
    .xpos(duck_xpos),
    .ypos(duck_ypos),
    .duck_direction(duck_direction),
    .rgb_pixel(rgb_pixel),

    .pixel_addr(pixel_addr),
    .in(waiting_for_enemy_start_if),
    .out(duck_if)
);

duck_rom u_duck_rom(
    .clk,
    .address(pixel_addr),
    .duck_killed(target_killed),
    .rgb(rgb_pixel)
);

draw_moving_rect 
#(
    .WIDTH(43),
    .HEIGHT(40),
    .SIZE(2),
    .PIXEL_ADDR_WIDTH(11)
)u_draw_dog_bird (
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable),
    .xpos(dog_bird_xpos),
    .ypos(dog_bird_ypos),
    .rgb_pixel(dog_bird_rgb_pixel),

    .pixel_addr(pixel_addr_dog_bird),
    .in(duck_if),
    .out(dog_bird_if)
);

draw_moving_rect 
#(
    .WIDTH(55),
    .HEIGHT(48),
    .SIZE(2),
    .PIXEL_ADDR_WIDTH(12)
)
u_draw_dog_behind_grass (
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable && dog_photo_index == 8),
    .xpos(dog_xpos),
    .ypos(dog_ypos),
    .rgb_pixel(dog_rgb_pixel),

    .pixel_addr(pixel_addr_dog_grass),
    .in(dog_bird_if),
    .out(dog_behind_grass_if)
);

draw_moving_rect 
#(
    .WIDTH(256),
    .HEIGHT(70),
    .SIZE(2),
    .PIXEL_ADDR_WIDTH(16) 
) u_grass_draw (
    .clk(clk),
    .rst(rst),
    .game_enable(1'b1),
    .xpos(12'd0),
    .ypos(12'd488),
    .rgb_pixel(rgb_grass),

    .pixel_addr(pixel_addr_grass),
    .in(dog_behind_grass_if),
    .out(grass_if)
);

grass_rom u_grass_rom (
    .clk(clk),
    .address(pixel_addr_grass),

    .rgb(rgb_grass)
);


draw_moving_rect 
#(
    .WIDTH(55),
    .HEIGHT(48),
    .SIZE(2),
    .PIXEL_ADDR_WIDTH(12)
)u_draw_dog (
    .clk(clk),
    .rst(rst),
    .game_enable(game_enable && dog_photo_index != 8),
    .xpos(dog_xpos),
    .ypos(dog_ypos),
    .rgb_pixel(dog_rgb_pixel),

    .pixel_addr(pixel_addr_dog),
    .in(grass_if),
    .out(dog_if)
);

dog_rom u_dog_rom (
    .clk(clk),
    .address(pixel_addr_dog | pixel_addr_dog_grass),
    .dog_bird_address(pixel_addr_dog_bird),
    .start_logo_address(start_logo_address),

    .start_logo_rgb(start_logo_rgb),
    .dog_select(dog_photo_index),
    .dog_bird_rgb(dog_bird_rgb_pixel),
    .rgb(dog_rgb_pixel)
);

draw_bullets u_draw_bullets (
    .game_enable(game_enable),
    .clk(clk),
    .rst(rst),
    .bullets_in_magazine(bullets_in_magazine),

    .in(dog_if),
    .out(bullets_if)
);

draw_string 
#(
    .CHAR_XPOS(MY_SCORE_XPOS - 24), 
    .CHAR_YPOS(MY_SCORE_YPOS - 70), 
    .WIDTH(6), 
    .SIZE(2), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_WHITE), 
    .TEXT("RELOAD")
)
u_draw_reload (
    .clk(clk),
    .rst(rst),
    .enable(show_reload_char && game_enable && left_mouse),

    .in(bullets_if),
    .out(reload_if)
);
draw_string 
#(
    .CHAR_XPOS(168), 
    .CHAR_YPOS(MY_SCORE_YPOS - 6), 
    .WIDTH(2), 
    .SIZE(2), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_BLACK), 
    .TEXT("/ ")
)
u_draw_slash (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(reload_if),
    .out(slash_if)
); 

draw_2_numbers 
#(
    .NUMB_XPOS(200), 
    .NUMB_YPOS(MY_SCORE_YPOS), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_bullets_left (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(bullets_left),
    .in(slash_if),
    .out(bullets_left_if)
);
    

draw_string 
#(
    .CHAR_XPOS(MY_SCORE_XPOS + 8), 
    .CHAR_YPOS(MY_SCORE_YPOS - 20), 
    .WIDTH(3), 
    .SIZE(1), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_GREEN), 
    .TEXT("YOU")
)
u_draw_score_your_points (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(bullets_left_if),
    .out(your_points_if)
);

draw_string 
#(
    .CHAR_XPOS(ENEMY_SCORE_XPOS - 8), 
    .CHAR_YPOS(ENEMY_SCORE_YPOS - 20), 
    .WIDTH(5), 
    .SIZE(1), 
    .COLOUR(RGB_RED), 
    .TEXT("ENEMY") 
)
u_draw_score_enemy_points (
    .clk(clk),
    .rst(rst),
    .enable(game_enable),

    .in(your_points_if),
    .out(enemy_points_if)
);
draw_2_numbers 
#(
    .NUMB_XPOS(MY_SCORE_XPOS), 
    .NUMB_YPOS(MY_SCORE_YPOS), 
    .COLOUR(RGB_BLUE), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_my_score (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(my_score),
    .in(enemy_points_if),
    .out(my_score_if)
);

draw_2_numbers 
#(
    .NUMB_XPOS(ENEMY_SCORE_XPOS), 
    .NUMB_YPOS(ENEMY_SCORE_YPOS), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(2) // 2^POWER_OF_2 = 4
)
u_draw_enemy_score (
    .clk(clk),
    .rst(rst),

    .game_enable(game_enable),
    .bin_number(enemy_score),
    .in(my_score_if),
    .out(enemy_score_if)
);
//WAITING FOR 2ND PLAYER TO END -----------------------------------


//GAME_END---------------------------------------------------------
draw_string 
#(
    .CHAR_XPOS(MY_SCORE_XPOS_END), 
    .CHAR_YPOS(MY_SCORE_YPOS_END), 
    .WIDTH(3), 
    .SIZE(3), // 2^POWER_OF_2 = 4
    .COLOUR(RGB_BLACK), 
    .TEXT("YOU")
)
u_draw_score_your_points_end (
    .clk(clk),
    .rst(rst),
    .enable(game_end_enable),

    .in(enemy_score_if),
    .out(your_points_if_end)
);

draw_string 
#(
    .CHAR_XPOS(ENEMY_SCORE_XPOS_END), 
    .CHAR_YPOS(ENEMY_SCORE_YPOS_END), 
    .WIDTH(5), 
    .SIZE(3), 
    .COLOUR(RGB_BLACK), 
    .TEXT("ENEMY") 
)
u_draw_score_enemy_points_end (
    .clk(clk),
    .rst(rst),
    .enable(game_end_enable),

    .in(your_points_if_end),
    .out(enemy_points_if_end)
);

draw_2_numbers 
#(
    .NUMB_XPOS(MY_SCORE_XPOS_END + 40), 
    .NUMB_YPOS(MY_SCORE_YPOS_END + 100), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(3) // 2^POWER_OF_2 = 4
)
u_draw_your_score_end (
    .clk(clk),
    .rst(rst),

    .game_enable(game_end_enable),
    .bin_number(my_score),
    .in(enemy_points_if_end),
    .out(my_score_if_end)
);

draw_2_numbers 
#(
    .NUMB_XPOS(ENEMY_SCORE_XPOS_END + 70), 
    .NUMB_YPOS(ENEMY_SCORE_YPOS_END + 100), 
    .COLOUR(RGB_BLACK), // RGB color for the character
    .SCALE_POWER_OF_2(3) // 2^POWER_OF_2 = 4
)
u_draw_enemy_score_end (
    .clk(clk),
    .rst(rst),

    .game_enable(game_end_enable),
    .bin_number(enemy_score),
    .in(my_score_if_end),
    .out(enemy_score_if_end)
);

compare_scores u_compare_scores ( // Porównanie wyników
    .my_score(my_score),
    .enemy_score(enemy_score), // Przeciwnik ma stały wynik 11
    .winner_status(winner_status)
);


draw_string 
#(
    .CHAR_XPOS(RESULT_XPOS - 300),       // Pozycja X komunikatu
    .CHAR_YPOS(RESULT_YPOS),       // Pozycja Y komunikatu
    .WIDTH(10),                     // Liczba znaków w komunikacie
    .SIZE(3),                      // Rozmiar tekstu
    .COLOUR(RGB_BLUE),             // Kolor tekstu
    .TEXT("IT'S A TIE") // Tekst do wyświetlenia
)
u_draw_winner_status_tie (
    .clk(clk),
    .rst(rst),
    .enable(game_end_enable && (winner_status == 2'b00)),      // Wyświetlanie aktywne tylko na końcu gry
    .in(enemy_score_if_end),                      // Wejście sygnału
    .out(draw_winner_status_if_draw)                      // Wyjście sygnału
);

draw_string 
#(
    .CHAR_XPOS(RESULT_XPOS - 200),       // Pozycja X komunikatu
    .CHAR_YPOS(RESULT_YPOS),       // Pozycja Y komunikatu
    .WIDTH(7),                     // Liczba znaków w komunikacie
    .SIZE(3),                      // Rozmiar tekstu
    .COLOUR(RGB_GREEN),             // Kolor tekstu
    .TEXT("YOU WIN") // Tekst do wyświetlenia
)
u_draw_winner_status_winner (
    .clk(clk),
    .rst(rst),
    .enable(game_end_enable && (winner_status == 2'b01)),      // Wyświetlanie aktywne tylko na końcu gry
    .in(draw_winner_status_if_draw),                      // Wejście sygnału
    .out(draw_winner_status_if_winner)                      // Wyjście sygnału
);

draw_string 
#(
    .CHAR_XPOS(RESULT_XPOS - 230),       // Pozycja X komunikatu
    .CHAR_YPOS(RESULT_YPOS),       // Pozycja Y komunikatu
    .WIDTH(8),                     // Liczba znaków w komunikacie
    .SIZE(3),                      // Rozmiar tekstu
    .COLOUR(RGB_RED),             // Kolor tekstu
    .TEXT("YOU LOST") // Tekst do wyświetlenia
)
u_draw_winner_status_losser (
    .clk(clk),
    .rst(rst),
    .enable(game_end_enable && (winner_status == 2'b10)),      // Wyświetlanie aktywne tylko na końcu gry
    .in(draw_winner_status_if_winner),                      // Wejście sygnału
    .out(out)                      // Wyjście sygnału
);

//---------------------------------//
endmodule
