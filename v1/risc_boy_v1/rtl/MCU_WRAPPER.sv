`timescale 1ns / 1ps
//============================================================
// Module: MCU Wrapper
// Author: Drew Nakamura
// Project: 5_Stage_Pipeline
//
// Description:
//   Wrapper for the 5-stage pipeline CPU and memory-mapped I/O.
//   Connects the CPU to switches, LEDs, and the 7-segment display.
//============================================================


module MCU_WRAPPER(
     input logic CLK,
     input logic BTNC,
     input logic [3:0] BTNS,
     input logic [15:0] SWITCHES,
     output logic HSYNC,
     output logic VSYNC,
     output logic [11:0] RGB_pins //TO INTERCONNECT
   );
    //====PARAMETERS=====
    localparam SWITCHES_AD = 32'h11000000;
    localparam BUTTON_AD  = 32'h11000080; //32'h11000080
    localparam VRAM_OFFSET = 32'h00003000;
    //localparam DMEM_OFFSET = 32'h00003F60; //Test all
    localparam DMEM_OFFSET = 32'h00001000; //RiscBoy
    //=====CPU Wires=====
    logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
    logic IOBUS_RDEN, IOBUS_WE;
    //===========Seven Segment Dispaly & LED WIRES=========
    //======Registers for buffering outputs==============
    logic SSEG_WE, LEDS_WE;
    //=====DMEM WIRES======
    logic [2:0] mem_data;
    logic DMEM_RDEN, DMEM_WE;
    logic [31:0] DMEM_DATA;
    //====PPU & VGA & VRAM WIRES===================
    logic [31:0] VRAM_DATA;
    logic [11:0] RGB;
    logic [9:0] pos_x;
    logic [9:0] pos_y;
    logic [31:0] sprite_x;
    logic [31:0] sprite_y;
    logic [31:0] pixel_data; 
    logic [31:0] pixel_addr;
    logic VRAM_RDEN;
    logic PIXEL_DATA_RDEN;
    logic video_on;
    logic VID_ON;
    logic VRAM_WE;
    //====BOARD WIRES=====
    logic clk_50; //50 MHz clock
    logic clk_25; //25 Mhz clock
    logic reset_100;
    logic reset_100_meta;
    logic reset_25;
    logic reset_25_meta;
    logic reset_50;
    logic reset_50_meta;
    logic [3:0] pulsed_BTNS;

   CPU_TOP CPU_TOP(
        .RST(reset_50),
        .CLK(clk_50),
        .IOBUS_IN(IOBUS_in),
        .mem_data(mem_data),
        .DATA_ADDRESS(IOBUS_addr),
        .DATA_OUT(IOBUS_out),
        .IOBUS_RDEN(IOBUS_RDEN),
        .IOBUS_WE(IOBUS_WE)
    );

   Interconnect Interconnect(
        .CLK(clk_50),
        .address(IOBUS_addr),
        .WE(IOBUS_WE),
        .RDEN(IOBUS_RDEN),
        .DMEM_DATA(DMEM_DATA),
        .VRAM_DATA(VRAM_DATA),
        .SWITCHES({16'b0,SWITCHES}),
        .BUTTONS({28'b0, pulsed_BTNS}),
        .DMEM_RDEN(DMEM_RDEN),
        .DMEM_WE(DMEM_WE),
        .LEDS_WE(LEDS_WE),
        .SSEG_WE(SSEG_WE),
        .VRAM_WE(VRAM_WE),
        .VRAM_RDEN(VRAM_RDEN),
        .IOBUS_in(IOBUS_in)
   );

   oneshot_hold #(
    .CYCLES(100_000)
    ) oneshot_hold (
        .clk          (CLK),
        .on           (1'b1),
        .rst          (reset_50),
        .button_raw   (BTNS),
        .button_pulse (pulsed_BTNS)
    );

   DMEM DATA_MEMORY(
        .CLK(clk_50),
        .WE(DMEM_WE),
        .RDEN(DMEM_RDEN),
        .address(IOBUS_addr - DMEM_OFFSET),
        .data_in(IOBUS_out),
        .mem_data(mem_data), //Meta data for half, byte, and word
        .data_out(DMEM_DATA)
    );

    VGA_Controller VGA(
        .clk(clk_25),
        .RESET(reset_25),
        .RGB(RGB), //[11:0] from PPU
        .pos_x(pos_x), //[9:0] to PPU
        .pos_y(pos_y), //[9:0] to PPU
        .HSYNC(HSYNC), //to constraints
        .VSYNC(VSYNC), //to constraints
        .video_on(video_on), //to PPU
        .RGB_pins(RGB_pins) //[11:0] to constraints
    );

     PPU PPU_module(
        .CLK_25(clk_25),
        .RESET(reset_25),
        .pos_x(pos_x), //[9:0] from VGA controller, current pixel to draw
        .pos_y(pos_y), //[9:0] from VGA controller
        
        //Hardcoded to be  pixel off the screen for testing
        //900 for x and y 
        .sprite_x_addr(32'h00003404), //address to sprite x location (in hex)
        .sprite_y_addr(32'h00003408), //address to sprite y location (in hex)
        
        .pixel_data(pixel_data), //[31:0] from VRAM, check for which bits in palette reg
        .video_on(video_on & VID_ON), //from VGA controller + if reset is not asserted
        .pixel_addr(pixel_addr), //[31:0] to VRAM
        .RDEN(PIXEL_DATA_RDEN),
        .RGB(RGB) //[11:0] to VGA controller
    );

    VRAM VRAM_module(
        .clk(clk_50),
        //PORT 1 is going to be for CPU (READ + WRITE)
        .ADDR1(IOBUS_addr - VRAM_OFFSET), //1024 rows, therefore, only 10 bits will be utlilized later 
        .RDEN1(VRAM_RDEN),
        .DIN1(IOBUS_out),
        .WE1(VRAM_WE),
        .SIZE1(mem_data[2:1]), //this is only for CPU, 0-Byte, 1-Half, 2-Word
        .SIGN1(mem_data[0]), //this is only for CPU, 1-Unsigned, 0-Signed
         
        //PORT 2 is going to be for PPU (READ ONLY)
        .ADDR2(pixel_addr - VRAM_OFFSET), //1024 rows, therefore, only 10 bits will be used later
        .RDEN2(PIXEL_DATA_RDEN),
        .DOUT1(VRAM_DATA), // CPU
        .DOUT2(pixel_data)//PPU ONLY
    );
                            
   // Clock stuff, we need to make it from the board instewad of flip flops later
   initial begin
    clk_50 <= 1'b0;
    clk_25 <= 1'b0;
    reset_100 <= 1'b0;
    reset_100_meta <= 1'b0;
    reset_25 <= 1'b0;
    reset_25_meta <= 1'b0;
    reset_50 <= 1'b0;
    reset_50_meta <= 1'b0;
   end
   always_ff @(posedge CLK) begin
        reset_100_meta <= BTNC;
        reset_100 <= reset_100_meta;
        VID_ON <= 1'b1;
        clk_50 <= ~clk_50;
        if(clk_50) clk_25 <= ~clk_25;
   end
   always_ff @(posedge clk_50) begin
        reset_50_meta <= BTNC;
        reset_50 <= reset_50_meta;
   end
   always_ff @(posedge clk_25) begin
        reset_25_meta <= BTNC;
        reset_25 <= reset_25_meta;
   end
   

endmodule
