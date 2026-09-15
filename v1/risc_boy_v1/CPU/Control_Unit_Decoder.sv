`timescale 1ns / 1ps
//============================================================
// Module: Control Unit Decoder
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   The control unit decoder takes in instruction data like opcode,
//   func3, ir30, and others, to send signals to other modules like
//   the ALU function and PC. Works asynchronously.
// 
// Notes:
//   - Educational use only
//   - Not an original architecture design
//============================================================


import OTTER_TYPES_PKG::*;

module CONTROL_UNIT_DECODER(
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic ir30, br_eq, br_lt, br_ltu,
    output logic [3:0] ALU_FUN,
    output logic srcA_SEL,
    output logic [1:0] srcB_SEL, PC_SEL, RF_SEL
    );
    //==U-Type==
    always_comb
    begin
       //Base Case
       ALU_FUN = ALU_ADD;
       srcA_SEL =  SRCA_rs1;
       srcB_SEL = SRCB_rs2;
       RF_SEL = WB_PC4;
       PC_SEL = PC_PC4;
       case(opcode)
        7'b0110111://==U-Type -> LUI====================
        begin
            ALU_FUN = ALU_LUI_COPY;
            srcA_SEL = SRCA_U_TYPE;
            RF_SEL = WB_ALU;
        end
            
        7'b0010111://==U-Type -> AUPIC====================
        begin
            srcA_SEL =  SRCA_U_TYPE;
            srcB_SEL = SRCB_PC;
            RF_SEL = WB_ALU;
        end
            
        7'b1101111://==J-Type -> JAL====================
        begin
            srcA_SEL =  SRCA_U_TYPE;
            srcB_SEL = SRCB_PC;
            PC_SEL = PC_JAL;
            RF_SEL = WB_PC4;  
        end
        7'b1100111://==I-Type -> JALR====================
        begin
            PC_SEL = PC_JALR;
            srcB_SEL = SRCB_I_TYPE;
            RF_SEL = WB_PC4;
        end
            
        7'b0000011://==I-Type -> LOADS=====================
        begin
            //Size difference is detemrined in the memory module
            srcA_SEL =  SRCA_rs1;
            srcB_SEL = SRCB_I_TYPE;
            RF_SEL = WB_MEM; //Write back stage will load from mem
        end
        
        7'b0010011://==I-Type -> ALU STUFF=====================
        begin
            //Base case covers ADDI,
            ALU_FUN = ALU_ADD;
            srcA_SEL =  SRCA_rs1;
            srcB_SEL = SRCB_I_TYPE;
            RF_SEL = WB_ALU;
            
            case(func3)
                3'b000: ALU_FUN = ALU_ADD; //ADD
                3'b010: ALU_FUN = ALU_SLT;//SLTI            
                3'b011: ALU_FUN = ALU_SLTU;//SLTIU
                3'b110: ALU_FUN = ALU_OR;//ORI
                3'b100: ALU_FUN = ALU_XOR; //XORI
                3'b111: ALU_FUN = ALU_AND;//ANDI
                3'b001: ALU_FUN = ALU_SLL;//SLLI
                3'b101: ALU_FUN = ir30 ? ALU_SRA : ALU_SRL;//SRA and SRL
                default: ALU_FUN = 'X;
            endcase
        end
        
        7'b0110011://==R-Type=====================
        begin
            //All other defaults work for R type
            RF_SEL = WB_ALU;
            case(func3)
            3'b000: ALU_FUN = ir30 ? ALU_SUB : ALU_ADD;
            3'b001: ALU_FUN = ALU_SLL;//SLL
            3'b010: ALU_FUN = ALU_SLT;//SLT
            3'b011: ALU_FUN = ALU_SLTU;//SLTU
            3'b100: ALU_FUN = ALU_XOR;//XOR
            3'b101: ALU_FUN = ir30 ? ALU_SRA : ALU_SRL; // SRA/SRL
            3'b110: ALU_FUN = ALU_OR;//OR
            3'b111: ALU_FUN = ALU_AND;//AND
            default: ALU_FUN = 'X;
            endcase
        end
        
        7'b0100011://S-Type
        begin
            srcB_SEL = SRCB_S_TYPE;
        end
        
        7'b1100011: //B-Type
        begin
            case(func3)
                3'b000: begin PC_SEL = br_eq  ? PC_BRANCH : PC_PC4; end // BEQ
                3'b001: begin PC_SEL = ~br_eq ? PC_BRANCH : PC_PC4; end // BNE
                3'b100: begin PC_SEL = br_lt  ? PC_BRANCH : PC_PC4; end // BLT
                3'b101: begin PC_SEL = ~br_lt ? PC_BRANCH : PC_PC4; end // BGE
                3'b110: begin PC_SEL = br_ltu ? PC_BRANCH : PC_PC4; end // BLTU
                3'b111: begin PC_SEL = ~br_ltu? PC_BRANCH : PC_PC4; end // BGEU
                default: PC_SEL = PC_PC4;
            endcase
        end
    default:
    begin
       ALU_FUN = 'X;
       srcA_SEL =  'X;
       srcB_SEL = 'X;
       RF_SEL = 'X;
       PC_SEL = 'X;
    end
    endcase
    end
endmodule
