`timescale 1ns / 1ps
//============================================================
// Testbench: MCU_WRAPPER
//
// Clocks the wrapper, holds BTNC (reset) high, then releases
// it. No other stimulus.
//============================================================

module tb_MCU_WRAPPER;

    logic CLK;
    logic BTNC;
    logic [3:0] BTNS;
    logic [15:0] SWITCHES;
    logic [15:0] LEDS;
    logic [7:0] CATHODES;
    logic [3:0] ANODES;
    logic HSYNC;
    logic VSYNC;
    logic [11:0] RGB_pins;

    MCU_WRAPPER dut (
        .CLK(CLK),
        .BTNC(BTNC),
        .BTNS(BTNS),
        .SWITCHES(SWITCHES),
        .LEDS(LEDS),
        .CATHODES(CATHODES),
        .ANODES(ANODES),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .RGB_pins(RGB_pins)
    );

    // Basys 3 input clock is 100 MHz
    initial CLK = 0;
    always #5 CLK = ~CLK;

    initial begin
        BTNS = '0;
        SWITCHES = '0;
        BTNC = 1'b1;

        #200;          // reset held for 200 ns
        BTNC = 1'b0;

        #2000;
        $finish;
    end

endmodule
