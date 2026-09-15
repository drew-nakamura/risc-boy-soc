`timescale 1ns / 1ps
//============================================================
// Module: IMEM(Instruction Memory)
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//    All instructions will be loaded in here, acting as read only memory(rom).
//    
// 
// Notes:
//   - Educational use only
//   - Not an original architecture design
// Decsion:
// 8/24/2026: Making it 16K bytes of ram, no particualr reason, just sounds enough for v1
// 8/30/2026: YO 16 K bytes sounds like way too much now, so we doing 4 KB, should still be hella room
//============================================================

module IMEM(
    input CLK,
    input [9:0] address,
    input [31:0] instruction
)
logic [11:0] wordAddress;
(* rom_style="{distributed | block}" *)
(* ram_decomp = "power " *)
logic [31:0] instruction_memory[0:1023];

//Read from loaded imem file!!
initial begin
    $readmemh("imem.mem", memory, 0, 1023);
end

//imposible for non word read
assign wordAddress ={address[9:2], 2'b0};

always_ff @(posedge clk) begin
    instruction = instruction_memory[wordAddress];
end
