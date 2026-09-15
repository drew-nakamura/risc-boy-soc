`timescale 1ns / 1ps
//============================================================
// Package: OTTER_TYPES_PKG
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   This is a helper file to assist in debugging, showing words in stead 
//   of values in the timing diagram. Purely for visuals, no logic affect.
//
// Context:
//   This module was implemented as part of coursework for
//   CPE 233 at California Polytechnic State University
//   (Cal Poly San Luis Obispo).
//
//   The overall processor architecture is based on the
//   "OTTER" RISC-V microcontroller developed for the course
//   by Cal Poly faculty.
//
//   This file contains my own implementation of the module
//   based on the provided specifications.
// 
// Notes:
//   - Educational use only
//   - Not an original architecture design
//============================================================
//import OTTER_TYPES_PKG::*;
package OTTER_TYPES_PKG;
  typedef enum logic [3:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b1000,
    ALU_AND = 4'b0111,
    ALU_OR = 4'b0110,
    ALU_XOR = 4'b0100,
    ALU_SLL = 4'b0001,
    ALU_SRL = 4'b0101,
    ALU_SRA = 4'b1101,
    ALU_SLT = 4'b0010,
    ALU_SLTU = 4'b0011,
    ALU_LUI_COPY = 4'b1001
  } alu_op_e;
  
  typedef enum logic [10:0] {
    I_LUI    = 11'b0_000_0110111,
    I_AUIPC  = 11'b0_000_0010111,
    I_JAL    = 11'b0_000_1101111,
    I_JALR   = 11'b0_000_1100111,

    I_LB     = 11'b0_000_0000011,
    I_LH     = 11'b0_001_0000011,
    I_LW     = 11'b0_010_0000011,
    I_LBU    = 11'b0_100_0000011,
    I_LHU    = 11'b0_101_0000011,

    I_ADDI   = 11'b0_000_0010011,
    I_SLTI   = 11'b0_010_0010011,
    I_SLTIU  = 11'b0_011_0010011,
    I_XORI   = 11'b0_100_0010011,
    I_ORI    = 11'b0_110_0010011,
    I_ANDI   = 11'b0_111_0010011,

    I_SLLI   = 11'b0_001_0010011,
    I_SRLI   = 11'b0_101_0010011,
    I_SRAI   = 11'b1_101_0010011,

    I_BEQ    = 11'b0_000_1100011,
    I_BNE    = 11'b0_001_1100011,
    I_BLT    = 11'b0_100_1100011,
    I_BGE    = 11'b0_101_1100011,
    I_BLTU   = 11'b0_110_1100011,
    I_BGEU   = 11'b0_111_1100011,

    I_SB     = 11'b0_000_0100011,
    I_SH     = 11'b0_001_0100011,
    I_SW     = 11'b0_010_0100011,

    I_ADD    = 11'b0_000_0110011,
    I_SUB    = 11'b1_000_0110011,
    I_SLL    = 11'b0_001_0110011,
    I_SLT    = 11'b0_010_0110011,
    I_SLTU   = 11'b0_011_0110011,
    I_XOR    = 11'b0_100_0110011,
    I_SRL    = 11'b0_101_0110011,
    I_SRA    = 11'b1_101_0110011,
    I_OR     = 11'b0_110_0110011,
    I_AND    = 11'b0_111_0110011,
    
    INST_INVALID = 11'b1_111_1111111
  } instruction_e;
  
  typedef enum logic [1:0] {
    WB_PC4 = 2'b00,
    WB_CSR = 2'b01,
    WB_MEM = 2'b10,
    WB_ALU = 2'b11
  } wb_sel_e;
  
  typedef enum logic [1:0] {
    PC_PC4 = 2'b00,
    PC_JALR = 2'b01,
    PC_BRANCH= 2'b10,
    PC_JAL = 2'b11
  } pc_sel_e;
  
  typedef enum logic {
    SRCA_rs1 = 1'b0,
    SRCA_U_TYPE = 1'b1
  } srca_sel_e;
  typedef enum logic [1:0]{
    SRCB_rs2 = 2'b00,
    SRCB_I_TYPE = 2'b01,
    SRCB_S_TYPE = 2'b10,
    SRCB_PC = 2'b11
  } srcb_sel_e;
  
  typedef enum{
        InF,
        EX,
        WB
   } state_e;
    
   typedef enum logic [6:0]{
        OP_LOAD = 7'b0000011,
        OP_I_TYPE = 7'b0010011,
        OP_BRANCH = 7'b1100011,
        OP_STORE = 7'b0100011,
        OP_LUI = 7'b0110111,
        OP_AUIPC = 7'b0010111,
        OP_JAL = 7'b1101111,
        OP_JALR = 7'b1100111,
        OP_R_TYPE = 7'b0110011
    } opcode_e;
    
endpackage


