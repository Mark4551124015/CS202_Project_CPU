`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 23:59:25
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb();
    reg clk = 1;
    reg cnt = 0;
    reg [31:0] Data = 63'b0;
    wire [31:0] Result;
    reg rst;
    wire [5:0] opcode = 6'b001_000;
    wire ALUSrc = 1;
    wire [31:0] imm = 32'b1100;
    wire [31:0] debug;
    wire I_format=1;
    wire [5:0] funct=5'b0;
    wire [1:0] ALUOp =2'b10;
    initial begin
        repeat(100_000_000) begin
            #1 Data <= Data + 1;
        end
        $finish;
    end

    ALU exe(
        .Read_A(Data[31:0]),
        .Read_I(imm),
        .ALU_Result(Result), 
        .ALUSrc(ALUSrc),
        .debug(debug),
        .opcode(opcode),
        .funct(funct),
        .I_format(I_format),
        .ALUOp(ALUOp)
    );




endmodule
