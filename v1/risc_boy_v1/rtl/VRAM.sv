`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ariana Rodriguez Birruete
// 
// Create Date: 08/30/2026 10:23:27 AM
// Design Name: 
// Module Name: VRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VRAM DRAFT ONE: V1
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VRAM(
    input clk,
    
    //PORT 1 is going to be for CPU (READ + WRITE)
    input [31:0] ADDR1, //1024 rows, therefore, only 10 bits will be utlilized later 
    input RDEN1,
    input [31:0] DIN1,
    input WE1,
    
    //PORT 2 is going to be for PPU (READ ONLY)
    input [31:0] ADDR2, //1024 rows, therefore, only 10 bits will be used later
    input RDEN2,
    input [1:0] SIZE1, //this is only for CPU, 0-Byte, 1-Half, 2-Word
    input SIGN1, //this is only for CPU, 1-Unsigned, 0-Signed
    output reg [31:0] DOUT1,
    output reg [31:0] DOUT2
    );
    
    (* rom_style="{block}" *) //Tell Vivado that VRAM should be stored in BRAM 
    logic [31:0] memory [0:1023]; // allocate space into array memory for 4KB
    
    reg [9:0] chopped_addr1;
    reg [9:0] chopped_addr2;
    
    reg [1:0] byte_offset1;
    reg [31:0] memReadSized;
    reg [31:0] mem_scaled;
    
    logic [1:0] buf_byte_offset1;
    logic [1:0] buf_SIZE1;
    logic buf_SIGN1;
    
  

    assign chopped_addr1 = ADDR1 >> 2; 
    assign byte_offset1 = ADDR1[1:0];
    
    assign chopped_addr2 = ADDR2 >> 2; //get rid of byte offset
    
    
    always_ff@(posedge clk)
    begin
        //READING VRAM
        if(RDEN1) //CPU reads
        begin
            memReadSized <= memory[chopped_addr1];
            buf_byte_offset1 <= byte_offset1;
            buf_SIZE1 <= SIZE1;
            buf_SIGN1 <= SIGN1;
        end
        
        if(RDEN2) //PPU reads always the full word
        begin
            //memReadSized <= memory[chopped_addr2];
            DOUT2 <= memory[chopped_addr2];
        end
              
    end

 
    //CPU READING FROM VRAM
    always_comb
    begin
        //Scaling data coming out
        /*RISC instructions such lb, lhu, are the reason for SIZE and SIGN values and this case statement
          Since the PPU will also ask for the complete word, the PPU will not need to complete this scaling*/
        case({buf_SIGN1 ,buf_SIZE1, buf_byte_offset1})
       //SIZE: 0-Byte, 1-Half, 2-Word
       //SIGN: 1-Unsigned, 0-Signed
        
            5'b0_00_00: mem_scaled = {{24{memReadSized[7]}}, memReadSized[7:0]};//signed byte 0 
            5'b0_00_01: mem_scaled = {{24{memReadSized[15]}}, memReadSized[15:8]};//signed byte 1
            5'b0_00_10: mem_scaled = {{24{memReadSized[23]}},  memReadSized[23:16]}; //signed byte 2
            5'b0_00_11: mem_scaled = {{24{memReadSized[31]}},  memReadSized[31:24]}; //signed byte 3
            
            5'b0_01_00: mem_scaled = {{16{memReadSized[15]}}, memReadSized[15:0]}; //signed half 0
            5'b0_01_01: mem_scaled = {{16{memReadSized[23]}}, memReadSized[23:8]}; //signed half 1
            5'b0_01_10: mem_scaled = {{16{memReadSized[31]}}, memReadSized[31:16]}; //signed half 2
            
            5'b1_00_00: mem_scaled = {{24{1'b0}}, memReadSized[7:0]}; //unsigned byte 0 
            5'b1_00_01: mem_scaled = {{24{1'b0}}, memReadSized[15:8]}; //unsigned byte 1
            5'b1_00_10: mem_scaled = {{24{1'b0}}, memReadSized[23:16]}; //unsigned byte 2
            5'b1_00_11: mem_scaled = {{24{1'b0}}, memReadSized[31:24]}; //unsigned byte 3
            
            5'b1_01_00: mem_scaled = {{16{1'b0}}, memReadSized[15:0]}; //unsigned half 0
            5'b1_01_01: mem_scaled = {{16{1'b0}}, memReadSized[23:8]}; //unsigned half 1 FOR MISALIGNED READS
            5'b1_01_10: mem_scaled = {{16{1'b0}}, memReadSized[31:16]}; //unsigned half 2
            
            5'b0_10_00: mem_scaled = memReadSized[31:0]; //complete wordword
            default: 
                mem_scaled = 32'b0; 
        endcase 
    end
    
   
   //CPU WRITING TO VRAM 
    always_ff@(posedge clk)
    begin
        if(WE1)
        begin
            case({SIZE1, byte_offset1})
            //SIZE: 0-Byte, 1-Half, 2-Word
                4'b00_00: memory[chopped_addr1][7:0] <= DIN1[7:0];//byte 0
                4'b00_01: memory[chopped_addr1][15:8] <= DIN1[7:0];//byte 1
                4'b00_10: memory[chopped_addr1][23:16] <= DIN1[7:0];//byte 2
                4'b00_11: memory[chopped_addr1][31:24] <= DIN1[7:0];//byte 3
                
                4'b01_00: memory[chopped_addr1][15:0] <= DIN1[15:0]; //half 0
                4'b01_01: memory[chopped_addr1][23:8] <= DIN1[23:8]; //half 1 FOR MISALIGNED WRITES
                4'b01_10: memory[chopped_addr1][31:16] <= DIN1[31:16]; //half 2
                
                4'b10_00: memory[chopped_addr1] <= DIN1; //full word
                
            endcase
        end
    end
    
    always_comb
    begin 
        DOUT1 = mem_scaled;
       // DOUT2 = mem_scaled;
    end 
    
    
endmodule