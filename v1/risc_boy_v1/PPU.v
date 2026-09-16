`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ariana Rodriguez Birruete
// 
// Create Date: 08/26/2026 08:12:12 PM
// Design Name: 
// Module Name: PPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Pixel Processing Unit - DRAFT ONE: V1
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//32x24
module PPU(
    input clk,
    input [9:0] pos_x, //from VGA controller, current pixel to draw
    input [9:0] pos_y, //from VGA controller
    input [9:0] sprite_x, //current pos of sprite's top left pixel of the 20x20 blk
    input [9:0] sprite_y, /*I NEED TO MODIFY THESE TO NO LONGER COME FROM AN INPUT VALUE 
                            BUT FROM THE PPU READING THE SPRITE LOCATION FROM VRAM
                            WE COULD HAVE IT SO THAT I GET AN ADDY FROM A REG OF WHERE THE SPRITE LOCATION WILL BE,
                            OR WE CAN HARDCODE IT INTO THIS MODULE*/
    input [31:0] pixel_data, //from VRAM, check for which bits in palette reg
    input video_on, //from VGA controller
    output reg [31:0] pixel_addr, // to VRAM
    output reg [11:0] RGB //to VGA controller
    );
    
    wire sprite_hit_x;
    wire sprite_hit_y;
    
    //Standard display is 640x480 
    // 640 pixels / 20 pixels = 32 blks , 480 pixels / 20 pixels = 24 blks 
    // x needs 5 bits to represent blks, y needs 5 bits
    reg [4:0] blk_x;
    reg [4:0] blk_y;
    
    reg [4:0] offset; //which bit in word (which blk in byte) 
    
  
    //VGA speaks in pixels, PPU speaks in blks, trying to decipher if current pixel is within sprite blk
    //IN THE MODIFIED VERS. I WOULD READ VRAM HERE TO GET SPRITE_X AND Y
    assign sprite_hit_x = (pos_x >= sprite_x) && (pos_x <= sprite_x + 19);
    assign sprite_hit_y = (pos_y >= sprite_y) && (pos_y <= sprite_y + 19);
    
    always@(*)
    begin
        blk_x = pos_x / 20 ; //pixel # / 20 pixels = blk # (which bit in word (which blk))
        blk_y = pos_y / 20;  //pixel # / 20 pixels = blk # (which memory row)
        //offset = pos_x % 8; //which bit('blk') in mem row
    end
  
    
    always @(*)
    begin
    //0 - white
    //1 - black
        if (video_on == 0)
        begin
            RGB = 12'hFFF;
            pixel_addr = 32'b0;
        end
        else
        begin
    
            if(sprite_hit_x && sprite_hit_y)
            begin
                //current block should be sprite
                RGB = 12'h000;
                pixel_addr = 32'b0;
                
            end
            else
            begin
            //current block is background, PU works in units of blks, 1 bit = 1 blk. 
            //0 - white, 1 - black (obstacle)
            //Therefore, we take:   pixel_y # // 20 pixels , which byte(memory row) (which row does that blk reside)
            //              then:   pixel_x # // 20 pixels = blk # (which blk the pixel is in, within that row)
            //             
            
            //32 blks / 8 = 4 bytes, therefore, when we fetch from VRAM as its a word, itll be 1 word = 1 grid row
            //Therefore, blk_y will take us to the correct row
            //and blk_x will take us to the correct bit(blk) within the row 
       
                pixel_addr = blk_y;
                if(pixel_data[blk_x] == 0)
                    RGB = 12'hFFF;
                else
                    RGB = 12'h000;
                    
           end
        end
    end

    
endmodule
