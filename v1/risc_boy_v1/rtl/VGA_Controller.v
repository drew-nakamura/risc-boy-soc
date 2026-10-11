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

    /*
        pixel clock rate = (# of pixels in H line) x (# of pixels in V line) X (refresh rate) 
        pixel clock rate - 800 x 525 x 60 = 25.2 MHZ
    */
    input clk, //needs to be 25 MHZ
    input [11:0] RGB, //from PPU
    output [9:0] pos_x, //to PPU
    output [9:0] pos_y, //to PPU
    output reg HSYNC, //to Interconnect
    output reg VSYNC, //to Interconnect
    output reg video_on, //to PPU
    output reg [11:0] RGB_pins //to Interconnect
    );
    
    reg [9:0] h_count = {10{1'b0}}; //x coord pixel count (enough for 800)
    reg [9:0] v_count = {10{1'b0}}; //y coord pixel count (enough for 525)
    
    assign pos_x = h_count;
    assign pos_y = v_count;
    
    //FRAME COUNTER
    always@(posedge clk) //every clk edge, the beam moves across the screen at a new pixel
    begin
        //new row
        if(h_count == 799) //restart the edge cnt
        begin
            h_count <= 0;
            
             //new frame
            if(v_count == 524) //restart edge cnt
            begin
                v_count <= 0;
            end
            else
            begin
                v_count <= v_count + 1;
            end
                
        end
        else
        begin
            h_count <= h_count + 1;
        end
        
       
    end
    
    //DECODER
    always@(*)
    begin
        HSYNC = 1; //active low
        VSYNC = 1;
        
        video_on = 1; //we are actively driving a color to display
        
        if( (h_count > 639) || (v_count > 479)) //not in visible region
        begin
            video_on = 0;
        end
        
        if( (h_count >= 656) && (h_count <= 751))
        begin
            HSYNC = 0; //deflection/retrace region (going back to left)
        end
        
        if( (v_count >= 490) && (v_count <= 491) )
        begin
            VSYNC = 0; //deflection/retrace region (
        end
        
    end
    
    always@(*)
    begin
        if(video_on)
            begin
                RGB_pins = RGB;
            end
        else
            begin
                RGB_pins = 12'h000;
            end
    end
    
endmodule
