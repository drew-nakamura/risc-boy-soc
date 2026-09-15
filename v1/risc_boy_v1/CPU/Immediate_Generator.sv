`timescale 1ns / 1ps
//============================================================
// Module: IMMEDIATE GENERATOR
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   The immediate generator creates the immediate values for the
//   different type instructions. For example, the U_Type immediate
//   is shifted up 12 bits in this module.
//
// Notes:
//   - Educational use only
//   - Not an original architecture design
//============================================================
//IMMEDIATE_GENERATOR (
//    .imm(),
//    .U_TYPE(),
//    .I_TYPE(),
//    .S_TYPE(),
//    .B_TYPE(),
//    .J_TYPE()
//    );

module IMMEDIATE_GENERATOR(
    input [24:0] imm,
    output [31:0] U_TYPE, I_TYPE, S_TYPE, B_TYPE, J_TYPE
    );
    assign I_TYPE = {{21{imm[24]}}, imm[23:18], imm[17:13]};
    assign S_TYPE = {{21{imm[24]}}, imm[23:18], imm[4:0]};
    assign B_TYPE = {{20{imm[24]}}, imm[0], imm[23:18], imm[4:1], 1'b0};
    assign U_TYPE = {imm[24:5], 12'b0};
    assign J_TYPE = {{12{imm[24]}}, imm[12:5], imm[13], imm[23:14], 1'b0};
endmodule
