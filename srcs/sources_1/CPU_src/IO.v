`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/05/08 21:28:00
// Design Name:
// Module Name: Dmem
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

`include "includes/defines.v"

module IO_module (IO_input,
                  IO_output,
                  TEST_input,
                  IORead,
                  IOWrite,
                  ALU_result,
                  MemReadData,
                  MemorIO_Result,
                  enterA,
                  enterB);
    // input clock;  //Clock signal.
    input IORead,IOWrite;
    input [7:0] IO_input;
    output [31:0] IO_output;
    input [2:0] TEST_input;
    input [31:0] ALU_result;
    input [31:0] MemReadData;
    input enterA,enterB;
    output [31:0] MemorIO_Result;
    
    
    
    wire [7:0] A_reg      = 8'b0, B_reg      = 8'b0;
    reg [31:0] Leds       = IOWrite ? ALU_result : Leds;
    assign IO_output      = Leds;
    reg [31:0] IO_reg     = 32'b0;
    assign A_reg          = enterA ? IO_input : A_reg;
    assign B_reg          = enterB ? IO_input : B_reg;
    // assign             = (ALU_Result == `IO_B_ADDR) ? {24'b0,B_reg} : {24'b0,A_reg};
    assign MemorIO_Result = IORead ? IO_reg : MemReadData;
    
    always @(*) begin
        
        case (ALU_result)
            `IO_A_ADDR: IO_reg    = {24'b0,A_reg};
            `IO_B_ADDR: IO_reg    = {24'b0,B_reg};
            `IO_TEST_ADDR: IO_reg = {29'b0, TEST_input};
            default: IO_reg       = MemReadData;
        endcase
    end
    
    
endmodule
