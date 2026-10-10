`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2026 06:37:11 PM
// Design Name: 
// Module Name: Top_Level_Visuals
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_Level_Visuals(
    //FROM INTERRCONNECT 
    input CLK,
    input reset,
    
    input [31:0] ADDR1, //for the CPU to write to VRAM
    input [31:0] DIN1,
    input RDEN1,
    input WE1,
    input [1:0] SIZE1,
    input SIGN1,
    input sprite_x_addr,
    input sprite_y_addr,
    output [31:0] DOUT1, //whatver CPU might want to read from VRAM
    
    output HSYNC,
    output VSYNC,
    output [11:0] RGB_pins //TO INTERCONNECT
    );
    
    wire [11:0] RGB;
    wire [9:0] pos_x;
    wire [9:0] pos_y;
    wire [31:0] sprite_x;
    wire [31:0] sprite_y;
    wire [31:0] pixel_data; 
    wire [31:0] pixel_addr;
    wire RDEN2;
    wire video_on;
    reg clk;
    
    reg CLK_50 = 0;
    reg CLK_25 = 0;
    reg VID_ON;
    
    //world's shittest clock div 
    always@(posedge CLK)
    begin
        if(reset)
        begin
            VID_ON <= 1'b0;
        end
        else
        begin
            VID_ON <= 1'b1;
        end
    
        if(CLK) 
        CLK_50 <= ~CLK_50;
        
        if(CLK_50) 
        CLK_25 <= ~CLK_25;
        
    end
    
     
    VGA_Controller VGA(
        .clk(CLK_25),
        .RGB(RGB), //[11:0] from PPU
        .pos_x(pos_x), //[9:0] to PPU
        .pos_y(pos_y), //[9:0] to PPU
        .HSYNC(HSYNC), //to constraints
        .VSYNC(VSYNC), //to constraints
        .video_on(video_on), //to PPU
        .RGB_pins(RGB_pins) //[11:0] to constraints
    );
    
    PPU PPU_module(
        .CLK_25(CLK_25), //clock for reading sprite location from vram
        .pos_x(pos_x), //[9:0] from VGA controller, current pixel to draw
        .pos_y(pos_y), //[9:0] from VGA controller
           
        .sprite_x_addr(32'b1110000100), //address to read from VRAM
        .sprite_y_addr(32'b1110000100), // address to read from VRAM
        
        .pixel_data(pixel_data), //[31:0] from VRAM, check for which bits in palette reg
        .video_on(video_on & VID_ON), //from VGA controller + if reset is not asserted
        .pixel_addr(pixel_addr), //[31:0] to VRAM
        .RDEN(RDEN2),
        .RGB(RGB) //[11:0] to VGA controller
    );
    
    VRAM VRAM_module(
        .clk(CLK),
        //PORT 1 is going to be for CPU (READ + WRITE)
        .ADDR1(ADDR1), //1024 rows, therefore, only 10 bits will be utlilized later 
        .RDEN1(RDEN1),
        .DIN1(DIN1),
        .WE1(WE1),
        .SIZE1(SIZE1), //this is only for CPU, 0-Byte, 1-Half, 2-Word
        .SIGN1(SIGN1), //this is only for CPU, 1-Unsigned, 0-Signed
         
        //PORT 2 is going to be for PPU (READ ONLY)
        .ADDR2(pixel_addr), //1024 rows, therefore, only 10 bits will be used later
        .RDEN2(RDEN2),
        .DOUT1(DOUT1),
        .DOUT2(pixel_data)
    );
    
            
endmodule
