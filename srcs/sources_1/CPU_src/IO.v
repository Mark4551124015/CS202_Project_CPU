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
    input [2:0] TEST_input;
    input [31:0] ALU_result;
    input [31:0] MemReadData;
    input enterA,enterB;
    output reg [31:0] MemorIO_Result;
    output reg [23:0] IO_output;
    
    // reg [7:0] A_tmp;
    // reg [7:0] B_tmp;
    reg [23:0] led_tmp;
    reg [7:0] A_reg;
    reg [7:0] B_reg;
    initial begin
        A_reg <= 8'b0;
        B_reg <= 8'b0;
        IO_output <=24'b0;
    end
    // reg [23:0] Leds;
    // assign IO_output      = Leds;
    // reg [31:0] IO_reg     = 32'b0;

    // assign             = (ALU_Result == `IO_B_ADDR) ? {24'b0,B_reg} : {24'b0,A_reg};
    // assign MemorIO_Result = IORead ? IO_reg : MemReadData;
    always @(*) begin
        if(enterA) A_reg <= IO_input;
        // else A_reg <= A_tmp;
        if(enterB) B_reg <= IO_input;
        // else B_reg <= B_tmp;
        // A_tmp <= A_reg;
        // B_tmp <= B_reg;
    end

    always @(*) begin
        if (IOWrite) IO_output <= ALU_result;
        if (IORead) begin
            case (ALU_result)
                `IO_A_ADDR: MemorIO_Result    = {24'b0,A_reg};
                `IO_B_ADDR: MemorIO_Result    = {24'b0,B_reg};
                `IO_TEST_ADDR: MemorIO_Result = {29'b0, TEST_input};
                default: MemorIO_Result       = MemReadData;
            endcase
        end else begin
            MemorIO_Result = MemReadData;
        end
    end
    
    
endmodule
