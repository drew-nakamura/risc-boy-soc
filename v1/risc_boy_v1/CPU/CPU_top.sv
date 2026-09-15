//============================================================
// Module: CPU_top
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//   The OTTER stands for "Our Two Thirty", and was designed by professors at Cal Poly to
//   be a learning tool for students. Although not an original architectur, I implamented 
//   the design in System Verilog and slightly modified the memory to better for the project.
//   The main design changes are written below.
//
// Design Decision:
// 8/20/2026: Removed memory module and sepearted IMEM and DMEM. Slightly changed memory 
//              Memory mapped I/O address to fit the project necessities.
//
// Notes:
//   - Educational use only
//   - Not an original architecture design
//============================================================
import OTTER_TYPES_PKGL::*;

module CPU_top(
    input logic RESET,
    input logic CLK,
    input logic [31:0] data_in,
    output logic [31:0] address_out,
    output logic [31:0] data_out,
    output logic [31:0] RDEN_OUT,
    output logic [31:0] WE_OUT
    );
//======WIRES================
//===Global Wires==========
//===Program Counter Wires=
    logic [31:0] PC;
    
//===PC Mux Wires==========
    logic [31:0] PC_NEXT;
    
//===Memory Wires==========
    logic [31:0] ir;
    
//===Register File Wires===
    logic [31:0] rs1, rs2;
    
//===Reg File MUX==========
    logic [31:0] W_DATA;
    
//===Contol Unit FSM=======
    logic PC_WE, RF_WE, InstRDEN, reset;
    
//===Control Unit Decoder==
    logic [3:0] ALU_FUN;
    logic srcA_SEL;
    logic [1:0] srcB_SEL, PC_SEL, RF_SEL;
    
//===Branch Condition Gen==
    logic br_eq, br_lt, br_ltu;
    
//===ALU Wires=============
    logic [31:0] ALU_RESULT;
    //==ALU MUX A AND B WIRES
    logic [31:0] srcA, srcB;
    
//===Immediate Generator Wires
    logic [31:0] U_Type, I_Type, S_Type, J_Type, B_Type;

//===Branch Address Generator
    logic [31:0] jalr, branch, jal;
//============================
    instruction_e instruction;

    logic [10:0] inst_key;
    always_comb begin
        case (ir[6:0])
            7'b0110111,  // LUI    - U-type, no func3
            7'b0010111,  // AUIPC  - U-type, no func3
            7'b1101111:  // JAL    - J-type, no func3
                inst_key = {4'b0, ir[6:0]};            // force func3 and ir[30] to 0
            7'b0110011:
            begin
                case(ir[14:12])
                3'b000,//ADD and SUB
                3'b101://SRL and SRA
                inst_key = {ir[30],ir[14:12], ir[6:0]};  
                default:  inst_key = {1'b0, ir[14:12], ir[6:0]};
                endcase
            end
            default:
                inst_key = {1'b0,ir[14:12], ir[6:0]};
        endcase
        
    end


    FOUR_TO_ONE_MUX PC_MUX(
        .A(PC+4),
        .B(jalr),
        .C(branch),
        .D(jal),
        .SEL(PC_SEL),
        .OUT(PC_NEXT)
     );

     Program_Counter Program_Counter(
        .PC_DIN(PC_NEXT),
        .reset(reset),
        .PC_WE(PC_WE),
        .CLK(CLK),
        .PC(PC)
     );

     IMEM instruction_memory(
        .CLK(CLK),
        .address(PC[9:0]),//byte offset inside imem
        .instruction(ir)
     )

     FOUR_TO_ONE_MUX REGISTER_MUX(
        .A(PC+4),
        .B('X),
        .C(data_in),
        .D(ALU_RESULT),
        .SEL(RF_SEL),
        .OUT(W_DATA)
     );

     REG_FILE REG_FILE(
        .CLK(CLK),
        .en(RF_WE),
        .adr1(ir[19:15]),
        .adr2(ir[24:20]),
        .w_adr(ir[11:7]),
        .w_data(W_DATA),
        .rs1(rs1),
        .rs2(rs2)
    );

    BRANCH_CONDITION_GENERATOR Branch_Cond_Gen(
        .rs1(rs1),
        .rs2(rs2),
        .br_lt(br_lt),
        .br_eq(br_eq),
        .br_ltu(br_ltu)
    );

    CONTROL_UNIT_DECODER CU_DCDR(
        .opcode(ir[6:0]),
        .func3(ir[14:12]),
        .ir30(ir[30]),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu),
        .ALU_FUN(ALU_FUN),
        .srcA_SEL(srcA_SEL),
        .srcB_SEL(srcB_SEL), 
        .PC_SEL(PC_SEL),
        .RF_SEL(RF_SEL)
     );

     CONTROL_UNIT_FSM CU_FSM(
        .RST(RST),
        .CLK(CLK),
        .opcodes(ir[6:0]),
        .PC_WE(PC_WE),
        .RF_WE(RF_WE),
        .WE_OUT(WE_OUT),
        .InstRDEN(InstRDEN),
        .RDEN_OUT(RDEN_OUT),
        .reset(reset)
        );

    BRANCH_ADDRESS_GENERATOR BRANCH_ADDR_GEN(
        .PC(PC),
        .J_Type(J_Type),
        .B_Type(B_Type),
        .I_Type(I_Type),
        .rs1(rs1),
        .jalr(jalr),
        .branch(branch),
        .jal(jal)
    );