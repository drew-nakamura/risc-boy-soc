`timescale 1ns / 1ps
//============================================================
// Module: Branch Address Generator
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   The branch address generator takes in PC, immediates made by
//   immediate generator, and rs1 to computer possible branch values
//   for the PC Next.
//
// Notes:
//   - Educational use only
//   - Not an original architecture design
//=============================
//BRANCH_ADDRESS_GENERATOR (
//    .PC(),
//    .J_Type(),
//    .B_Type(),
//    .I_Type(),
//    .rs1(),
//    .jalr(),
//    .branch(),
//    .jal()
//    );

module BRANCH_ADDRESS_GENERATOR(
    input logic [31:0] PC, J_Type, B_Type, I_Type, rs1,
    output logic [31:0] jalr, branch, jal
    );
    
    assign jalr = I_Type + rs1;
    assign branch = PC + B_Type;
    assign jal = PC + J_Type;
endmodule
