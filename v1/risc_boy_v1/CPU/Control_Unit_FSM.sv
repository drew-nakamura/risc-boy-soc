`timescale 1ns / 1ps
//============================================================
// Module: CONTROL UNIT FSM
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   The FSM is the main control unit within the OTTER, with 3 stages.
//   First IF, which only fetches the instruction from memory, then the
//   Execute stage handles memory write back and all other modules besdies
//   the register WE, which is what the write back stage is incharge of.
//   The multicycle on handles on instruction per total cycle.
//
// Notes:s
//   - Educational use only
//   - Not an original architecture design
//============================================================
//    CONTROL_UNIT_FSM (
//        .RST(),
//        .CLK(),
//        .opcodes(),
//        .PC_WE(),
//        .RF_WE(),
//        .WE_OUT(),
//        .InstRDEN(),
//        .RDEN_OUT(),
//        .reset()
//        );
import OTTER_TYPES_PKG::*;

module CONTROL_UNIT_FSM(
    input logic CLK,
    input logic RST,
    input logic [6:0] opcodes,
    output logic PC_WE, 
    output logic RF_WE, 
    output logic WE_OUT, 
    output logic InstRDEN, 
    output logic RDEN_OUT, 
    output logic reset
    );
    
    opcode_e opcode;
    state_e PS, NS;
    
    assign opcode = opcode_e'(opcodes);
    assign reset = RST;
    
    always_ff @(posedge CLK)
    begin
        if(RST)
            begin
                PS <= InF;
            end
        else
            PS <= NS;
    end
  
    always_comb
    begin
        PC_WE = 1'b0;
        RF_WE = 1'b0;
        WE_OUT = 1'b0;
        InstRDEN = 1'b0;
        RDEN_OUT = 1'b0;
        case(PS)
            InF:
            begin
                InstRDEN = 1'b1;
                NS = EX;
            end
            
            EX:
            begin
                NS = InF;
               
                case(opcode)
                OP_LUI:
                begin
                    NS = WB;
                end
                
                OP_AUIPC:
                begin
                    NS = WB;
                end
                
                OP_JAL:
                begin
                    PC_WE = 1'b1;
                    RF_WE = 1'b1;
                    NS = InF;
                end
                OP_JALR:
                begin
                    PC_WE = 1'b1;
                    RF_WE = 1'b1;
                    NS = InF;
                end
                OP_LOAD:
                begin
                    RDEN_OUT = 1'b1;
                    NS = WB;
                end
                OP_I_TYPE:
                begin
                    PC_WE = 1'b1;
                    RF_WE = 1'b1;
                    NS = InF;
                end
                
                OP_BRANCH:
                begin
                    PC_WE = 1'b1;
                    NS = InF;
                end
                
                OP_STORE:
                begin
                    PC_WE = 1'b1;
                    WE_OUT = 1'b1;
                    NS = InF;
                end
                
                OP_R_TYPE:
                begin
                    PC_WE = 1'b1;
                    RF_WE = 1'b1;
                    NS = InF;
                end
                
                default: 
                begin
                    NS = InF;
                end
                endcase
            end
            
            WB:
            begin
                RF_WE = 1'b1;
                PC_WE = 1'b1;
                NS = InF;
            end
            
            default: 
            begin
                NS = InF;
            end
        endcase
    end
endmodule
