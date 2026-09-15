`timescale 1ns / 1ps
//============================================================
// Module: WRAM(Working RAM)
// Author: Drew Nakamura
// Project: risc-boy-soc-v1
//
// Description:
//    CPU uses to store information 
//    
// 
// Notes:
//   - Educational use only
//   - Not an original architecture design
// Decsion:
// 8/24/2026: Making it 32K bytes of ram, no particualr reason, just sounds enough for v1
// 8/30/2026: Unlike in the otter, CPU now leader, meaning the followers will not by parsed/extended, 
//  it will be the cpu's job to alter data. Byte offset is still here though for +4 Bytes
// 8/30/2026: Yo 32 K Bytes of ram is probably overkill, we will do 8 K bytes for now, a little less overkill
//============================================================
//WE should probably make sutffl ike address width auto calcualte based on ram size, rembeer to maunally change when we change stuff
module WRAM(
    input CLK,
    input WE,
    input RDEN,
    input [12:0] address,
    input [31:0] data_in,
    input [31:0] data_out
)

logic [12:0] wordAddress;

(* ram_style="{distributed | block}" *)
(* ram_decomp = "power " *)
logic [31:0] working_ram[0:2047];

//Read from loaded w_ramS file!!
initial begin
    $readmemh("ram.mem")
end

//imposible for non word read/write
assign wordAddress ={address[12:2], 2'b0};

always_ff @@(posedge CLK) begin
    if(WE) begin
        memory[wordAddress] <= data_in;
    end

    if(RDEN) begin
        data_out <= memory[wordAddress]
    end
end

