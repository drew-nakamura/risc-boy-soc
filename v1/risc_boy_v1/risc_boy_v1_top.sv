`timescale 1ns / 1ps
//============================================================
// Module: risc_boy_v1_top
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//    Our risc-boy-soc-v1_top connect all modules and FPGA board
//    
// 
// Notes:
//   - Educational use only
//   - Not an original architecture design
// Decsion:
// 8/24/2026: Making it 16K bytes of ram, no particualr reason, just sounds enough for v1
// 8/30/2026: YO 16 K bytes sounds like way too much now, so we doing 4 KB, should still be hella room
//============================================================

module risc_boy_v1_top(
    input CLK,
    input BTNC, //the middle reset button
    input [3:0] BUTTONS, //up down left right
    output logic [3:0] vga_r, //Red Channel
    output logic [3:0] vga_g, //Green Channe;
    output logic [3:0] vga_b, // Blue CHannel
    output logic vga_hs, //Horizontal Sync
    output logic vga_vs //Vertical Sync
)
    //MEMMORY MAPPED INPUT AND OUTPUT
    localparam JOYPAD = 32'h0004000; //ButtonAddress LSB 4 LSB, BUTTON

    logic clk_50 = 0; //Divided clock

    //Wires
    //==CPU WIRES===
    logic [31:0] CPU_data_out;
    logic CPU_RDEN;
    loigic CPU_WE;
    //==Interconnect Wires===
    logic [31:0] 

    CPU_TOP CPU(
        .RESET(BTNC),
        .CLK(clk_50),
        .data_in(),
        .address_out(),
        .data_out(CPU_data_out),
        .RDEN_OUT(RDEN),
        .WE_OUT(CPU_WE)
    );