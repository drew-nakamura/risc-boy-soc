`timescale 1ns / 1ps
//============================================================
// Module: Interconnect
// Author: Drew Nakamura
// Project: 5_Stage_Pipeline
//
// Description:
//   Splits a CPU address into DMEM or MMIO. Maps switches,
//   buttons, LEDs, and the seven-seg display.
//============================================================
// Interconnect (
//     .address(),
//     .WE(),
//     .RDEN(),
//     .DMEM_DATA(),
//     .SWITCHES(),
//     .BUTTONS(),
//     .DMEM_RDEN(),
//     .DMEM_WE(),
//     .LEDS_WE(),
//     .SSEG_WE(),
//     .VRAM_WE(),
//     .VRAM_RDEN(),
//     .IOBUS_in()
//     );

module Interconnect(
    input logic [31:0] address,

    input logic WE,
    input logic RDEN,
    input logic [31:0] DMEM_DATA,

    input logic [31:0] VRAM_DATA,

    input logic [31:0] SWITCHES,
    input logic [31:0] BUTTONS,
    output logic DMEM_RDEN,
    output logic DMEM_WE,
    output logic LEDS_WE,
    output logic SSEG_WE,

    output logic VRAM_WE, VRAM_RDEN,

    output logic [31:0] IOBUS_in
    );

    always_comb begin
        IOBUS_in = 32'b0;
        DMEM_RDEN = 1'b0;
        DMEM_WE = 1'b0;
        LEDS_WE = 1'b0;
        SSEG_WE = 1'b0;
        VRAM_WE = 1'b0;
        VRAM_RDEN = 1'b0;
        if(address >= 32'h11000000) begin //MMIO
        //if(address >= 32'h4000) begin //MMIO
            case(address)
                32'h11000000: if(RDEN) IOBUS_in = SWITCHES; //SWITCHES 
                32'h11000020: LEDS_WE = WE; //LEDS
                32'h11000040: if(WE) SSEG_WE = 1'b1;//SSEG
               32'h4008: begin
                   VRAM_WE = WE;
                   VRAM_RDEN = RDEN;
                   IOBUS_in = VRAM_DATA;
               end
               32'h4004: begin
                   VRAM_WE = WE;
                   VRAM_RDEN = RDEN;
                   IOBUS_in = VRAM_DATA;
               end
               32'h4000: if(RDEN) IOBUS_in = BUTTONS; //BUTTONS
            endcase
        end
       else if(address >= 32'h3000)begin
           VRAM_WE = WE;
           VRAM_RDEN = RDEN;
           if(RDEN) IOBUS_in = VRAM_DATA;
           //atm not reading from vram so this it
       end
        //else if(address >= 32'h3F60)begin
        else if(address >= 32'h1000)begin
            DMEM_RDEN = RDEN;
            DMEM_WE = WE;
            if(RDEN) begin
                IOBUS_in = DMEM_DATA;
            end
        end else begin
            // IMEM space: no data-bus action
        end
    end
endmodule
