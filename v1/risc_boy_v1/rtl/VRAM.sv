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
    
    initial
    begin
    /* MANUALLY WRITTEN MAZE 1
    int i;
    
    memory[0] =  {32{1'b0}};
    memory[1] =  {32{1'b0}};
    memory[2] =  {32{1'b0}};
    memory[3] =  {32{1'b0}};
    memory[4] =  {32{1'b0}};
    memory[5] =  {32{1'b0}};
    memory[6] =  {32{1'b0}};
    memory[7] =  {32{1'b0}};
    memory[8] =  32'b00000000000011111111000000000000;
    memory[9] =  32'b00000000000011111111000000000000;
    memory[10] = 32'b00000000000011111111000000000000;
    memory[11] = 32'b00000000000011111111000000000000;
    memory[12] = 32'b00000000000011111111000000000000;
    memory[13] = 32'b00000000000011111111000000000000;
    memory[14] = 32'b00000000000011111111000000000000;
    memory[15] = 32'b00000000000011111111000000000000;
    memory[16] = {32{1'b0}};
    memory[17] = {32{1'b0}};
    memory[18] = {32{1'b0}};
    memory[19] = {32{1'b0}};
    memory[20] = 32'b01010000000000000000000000000000; 
    memory[21] = 32'b00100000000000000000000000000000;
    memory[22] = 32'b01010000000000000000000000000000;
    memory[23] = {32{1'b0}};

    
    memory[24] =  { {30{1'b0}} , 2'b10 };//sprite x is at blk 2
    memory[25] =  { {30{1'b0}} , 2'b10 };//sprite y is at blk 2
    
     for(i = 26; i <= 1023; i++)//non junk values for the rest of mem
        begin
            memory[i] = {32{1'b0}}; //make white should not be seen 
        end
    */
 
       
    end
    
    reg [9:0] chopped_addr1;
    reg [9:0] chopped_addr2;
    
    reg [1:0] byte_offset1;
    reg [31:0] memReadSized;
    reg [31:0] mem_scaled;
  
    
    /*
    assign chopped_addr1 = ADDR1[11:2]; //spliced CPU addr
    assign byte_offset1 = ADDR1[1:0];
    
    assign chopped_addr2 = ADDR2[9:0]; //spliced PPU addr
    */
    
    assign chopped_addr1 = ADDR1 >> 2; 
    assign byte_offset1 = ADDR1[1:0];
    
    assign chopped_addr2 = ADDR2[9:0]; //also contains the offset
    
    
    always_ff@(posedge clk)
    begin
        //READING VRAM
        if(RDEN1) //CPU reads, not full word
        begin
            memReadSized <= memory[chopped_addr1];
        end
        
        if(RDEN2) //PPU reads always the full word
        begin
            DOUT2 <= memory[chopped_addr2];
        end
              
    end

 
    //CPU READING FROM VRAM
    always_comb
    begin
        //Scaling data coming out
        /*RISC instructions such lb, lhu, are the reason for SIZE and SIGN values and this case statement
          Since the PPU will also ask for the complete word, the PPU will not need to complete this scaling*/
        case({SIGN1 ,SIZE1, byte_offset1})
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
            5'b1_00_11: mem_scaled = {{24{1'b0}}, memReadSized[31:23]}; //unsigned byte 3
            
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
                4'b00_00: memory[chopped_addr1] <= DIN1[7:0];//byte 0
                4'b00_01: memory[chopped_addr1] <= DIN1[7:0];//byte 1
                4'b00_10: memory[chopped_addr1] <= DIN1[7:0];//byte 2
                4'b00_11: memory[chopped_addr1] <= DIN1[7:0];//byte 3
                
                4'b01_00: memory[chopped_addr1] <= DIN1[15:0]; //half 0
                4'b01_01: memory[chopped_addr1] <= DIN1[23:8]; //half 1 FOR MISALIGNED WRITES
                4'b01_10: memory[chopped_addr1] <= DIN1[31:16]; //half 2
                
                4'b10_00: memory[chopped_addr1] <= DIN1; //full word
                
            endcase
        end
    end
    
    always_comb
    begin 
        DOUT1 = mem_scaled;
    end 
    
    
endmodule