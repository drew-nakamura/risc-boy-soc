`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ariana Rodriguez Birruete
// 
// Create Date: 08/28/2026 09:54:22 PM
// Design Name: 
// Module Name: VGA_Controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VGA Controller DRAFT ONE: V1
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//20x20 pixels
//32x24 blks 
module VGA_Controller(
    input clk,
    input [11:0] RGB, //from PPU
    output [9:0] pos_x, //to PPU
    output [9:0] pos_y, //to PPU
    output reg HSYNC, //to constraints
    output reg VSYNC, //to constraints
    output reg video_on, //to PPU
    output reg [11:0] RGB_pins //to constraints
    );
    
    reg [9:0] h_count; //x coord pixel count
    reg [9:0] v_count; //y coord pixel count
    
    assign pos_x = h_count;
    assign pos_y = v_count;
    
    always@(posedge clk) //every clk edge, the beam moves across the screen at a new pixel
    begin
        if(h_count == 799) //restart the edge cnt
        begin
            h_count <= 0;
            v_count <= v_count + 1;
        end
        else
        begin
            h_count <= h_count + 1;
        end
        
        if(v_count == 524) //restart edge cnt
        begin
            v_count <= 0;
        end
    end
    
    always@(*)
    begin
        HSYNC = 1;
        VSYNC = 1;
        video_on = 1;
        
        if( (h_count > 639) || (v_count > 479))
        begin
            video_on = 0;
        end
        
        if( (h_count >= 656) && (h_count <= 751))
        begin
            HSYNC = 0;
        end
        
        if( (v_count >= 490) && (v_count <= 491) )
        begin
            VSYNC = 0;
        end
        
    end
    
    always@(*)
    begin
        if(video_on)
            begin
                RGB_pins <= RGB;
            end
        else
            begin
                RGB_pins <= 12'h000;
            end
    end
    
endmodule
