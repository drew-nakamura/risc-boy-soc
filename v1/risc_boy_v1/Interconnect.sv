//============================================================
// Module: Interconnect
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   Directs all traffic inbetween modules,
//   primarily as a router for the CPU(Leader/Master).
//
// Design Decision:
// 8/20/2026: Removed memory module and sepearted IMEM and DMEM. Slightly changed memory 
//              Memory mapped I/O address to fit the project necessities.
//
// Notes:
//   - Educational use only
//   - Not an original architecture design
//============================================================
//Interconnects:
//  CPU
//  DMEM
//  PPU
//  Joypad

module Interconnect(
    input logic [31:0] address,
    inout logic [31:0] data,
    input logic WE,
    input logic RE,
    output logic DMEM_RDEN,
    output logic DMEM_WE,
    output logic PPU
)