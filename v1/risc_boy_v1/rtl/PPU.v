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
    input CLK_25,
    input [9:0] pos_x, //from VGA controller, current pixel to draw
    input [9:0] pos_y, //from VGA controller
    //input [31:0] sprite_x, //Read from VRAM: current pos of sprite's top left pixel of the 20x20 blk
    //input [31:0] sprite_y, 
    input [31:0] pixel_data, //from VRAM, check for which bits in palette reg
    input [31:0] sprite_x_addr, // address to read sprite x
    input [31:0] sprite_y_addr, // address to read sprite y 
    input video_on, //from VGA controller
    output reg [31:0] pixel_addr, // to VRAM
    output reg RDEN,
    output reg [11:0] RGB //to VGA controller
    );

    reg [31:0] sprite_x;
    reg [31:0] sprite_y;
    wire sprite_hit_x;
    wire sprite_hit_y;
    
    //Standard display is 640x480 
    // 640 pixels / 20 pixels = 32 blks , 480 pixels / 20 pixels = 24 blks 
    // x needs 5 bits to represent blks, y needs 5 bits
    reg [4:0] blk_x;
    reg [4:0] blk_y;
    
    reg [4:0] offset; //which bit in word (which blk in word) 
  
    reg [1:0] INVIS_STATE;
 
    always@(posedge CLK_25) 
    begin
    if(video_on == 0) //when in invisibile region
    case(INVIS_STATE)
        2'b00: 
            begin
                pixel_addr <= sprite_x_addr; //read sprite x location
                RDEN <= 1'b1;
                INVIS_STATE <= 2'b01; //next state: read y , save x
            end
            
        2'b01:
            begin
                sprite_x <= pixel_data; //save sprite x location
                pixel_addr <= sprite_y_addr; //read sprite y location
                RDEN <= 1'b1;
                INVIS_STATE <= 2'b10; //next state: save y
            end
            
        2'b10:
            begin
                sprite_y <= pixel_data; //save sprite y
                RDEN <= 1'b0;
                INVIS_STATE <= 2'b11;
            end
            
        2'b11:
            begin
                RDEN <= 1'b0;
            end
            
         default: 
            INVIS_STATE <= 2'b11;
        endcase
    else
    begin
           INVIS_STATE <= 2'b00;
           
    //0 - white
    //1 - black
            if(sprite_hit_x && sprite_hit_y)
            begin
                //current block should be sprite
                RDEN <= 1'b0;
                pixel_addr <= {32{1'b0}};
                
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
       
                RDEN <= 1'b1;
                pixel_addr <= blk_y;
           end
        end
    end  
  
  
    //VGA speaks in pixels, PPU speaks in blks, trying to decipher if current pixel is within sprite blk
    assign sprite_hit_x = (pos_x >= sprite_x[9:0]) && (pos_x <= sprite_x[9:0] + 19);
    assign sprite_hit_y = (pos_y >= sprite_y[9:0]) && (pos_y <= sprite_y[9:0] + 19);
    
    always@(*)
    begin
        blk_x = pos_x / 20 ; //pixel # / 20 pixels = blk # (which bit in word (which blk))
        blk_y = pos_y / 20;  //pixel # / 20 pixels = blk # (which memory row)      
    end
    
    always @(*)
    begin
    //0 - white
    //1 - black
    
        if (video_on == 0)
        begin
            RGB = 12'h000; //drive to black when video is not on
        end
        
        else
        begin
    
            if(sprite_hit_x && sprite_hit_y)
            begin
                //current block should be sprite
                RGB = 12'h000;      
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
                if(pixel_data[blk_x] == 0)
                    RGB = 12'hFFF; //white
                else
                    RGB = 12'h000; //black for testing
                    
           end
        end
    end

    
endmodule
