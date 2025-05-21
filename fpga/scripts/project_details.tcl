# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
# modified: Oliwia Szewczyk
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                  
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz_project.xdc
}

# Specify SystemVerilog design files location  
set sv_files {
    ../rtl/Timing/vga_pkg.sv \
    ../rtl/Timing/vga_timing.sv \
    ../rtl/vga_if.sv \
    ../rtl/top_vga.sv \
    ../rtl/Background/Game_Background.sv \
    ../rtl/Mouse_Control/draw_mouse.sv\
    ../rtl/Mouse_Control/mouse_shape.sv\
    ../rtl/Game_Control/top_game.sv \
    ../rtl/Game_Control/game_control_fsm.sv \
    ../rtl/Game_Control/start_screen.sv \
    ../rtl/Game_Control/lfsr_random.sv \
    ../rtl/Game_Control/Text_files/char_rom.sv \
    ../rtl/Game_Control/Text_files/draw_rect_char.sv \
    ../rtl/Game_Control/Text_files/font_rom.sv \
    ../rtl/Game_Control/lfsr_random.sv\
    ../rtl/Game_Control/duck_game_logic.sv \
    ../rtl/Game_Control/duck_ctl.sv \
    ../rtl/Game_Control/draw_files/draw_duck.sv \
    ../rtl/Game_Control/delay_ms.sv \
    ../rtl/Game_Control/draw_files/duck_rom.sv \
    ../rtl/Background/grass_draw.sv\
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location        
 set verilog_files {
    rtl/clk_wiz_project.v
    rtl/clk_wiz_project_clk_wiz.v
}

# Specify VHDL design files location           
 set vhdl_files {
   ../rtl/Mouse_Control/MouseCtl.vhd 
   ../rtl/Mouse_Control/MouseDisplay.vhd
   ../rtl/Mouse_Control/Ps2Interface.vhd
}

# Specify files for a memory initialization    
#  set mem_files {
# }
