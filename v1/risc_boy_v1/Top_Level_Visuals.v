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
    input CLK_25,
    input reset,
    /*
    input [31:0] ADDR1,
    input [31:0] DIN1,
    input RDEN1,
    input WE1,
    input [1:0] SIZE1,
    input SIGN1,
    */
    
      //TO INTERCONNECT
    //output [31:0] DOUT1, //FOR TESTING THIS GIRL AINT DOING SHIT
    
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
    //reg clk;
    
    //reg clk_50 = 0;
    //reg clk_25 = 0;
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
    
       /* if(CLK) 
        clk_50 <= ~clk_50;
        
        if(clk_50) 
        clk_25 <= ~clk_25;
        */
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
        .pos_x(pos_x), //[9:0] from VGA controller, current pixel to draw
        .pos_y(pos_y), //[9:0] from VGA controller
        
        
        //Hardcoded to be  pixel off the screen for testing
        //900 for x and y 
        .sprite_x(10'b1110000100), //[31:0] Read from VRAM: current pos of sprite's top left pixel of the 20x20 blk
        .sprite_y(10'b1110000100), 
        
        
        
        .pixel_data(pixel_data), //[31:0] from VRAM, check for which bits in palette reg
        .video_on(video_on & VID_ON), //from VGA controller + if reset is not asserted
        .pixel_addr(pixel_addr), //[31:0] to VRAM
        .RDEN(RDEN2),
        .RGB(RGB) //[11:0] to VGA controller
    );
    
    VRAM VRAM_module(
        .clk(CLK),
        //PORT 1 is going to be for CPU (READ + WRITE)
        .ADDR1(32'b0), //1024 rows, therefore, only 10 bits will be utlilized later 
        .RDEN1(32'b0),
        .DIN1(1'b0),
        .WE1(1'b0),
        .SIZE1(2'b0), //this is only for CPU, 0-Byte, 1-Half, 2-Word
        .SIGN1(1'b0), //this is only for CPU, 1-Unsigned, 0-Signed
         
        //PORT 2 is going to be for PPU (READ ONLY)
        .ADDR2(pixel_addr), //1024 rows, therefore, only 10 bits will be used later
        .RDEN2(RDEN2),
        .DOUT1(DOUT1),
        .DOUT2(pixel_data)
    );
    
            
endmodule
