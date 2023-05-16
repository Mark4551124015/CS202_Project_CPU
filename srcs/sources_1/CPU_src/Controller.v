`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SUSTech
// Engineer: Little Skirt
//
// Create Date: 2023/05/08 17:56:30
// Design Name: 
// Module Name: ALU.v
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

module control32 (
    opcode,
    Function_opcode,
    inited,
    Jr,
    RegDST,
    ALUSrc,
    RegWrite,
    MemWrite,
    Branch,
    nBranch,
    Jmp,
    Jal,
    I_format,
    Sftmd,
    ALUOp,
    MemorIOtoReg,
    Alu_resultHigh,
    IORead,
    IOWrite
);
  input [5:0] opcode;  // 来自IFetch模块的指令高6bit
  input [5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit，用于区分r-类型中的指令
  input [21:0] Alu_resultHigh;
  input inited;

  output Jr;  // 为1表明当前指令是jr，为0表示当前指令不是jr
  output RegDST;  // 为1表明目的寄存器是rd，为0时表示目的寄存器是rt
  output ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）来自立即数（beq，bne除外），为0时表示第二个操作数来自寄存器
  // output MemtoReg;     // 为1表明从存储器或I/O读取数据写到寄存器，为0时表示将ALU模块输出数据写到寄存器
  output RegWrite;  // 为1表明该指令需要写寄存器，为0时表示不需要写寄存器
  output MemWrite;  // 为1表明该指令需要写存储器，为0时表示不需要写储存器
  output Branch;  // 为1表明是beq指令，为0时表示不是beq指令
  output nBranch;  // 为1表明是bne指令，为0时表示不是bne指令
  output Jmp;  // 为1表明是j指令，为0时表示不是j指令
  output Jal;  // 为1表明是jal指令，为0时表示不是jal指令
  output I_format;      // 为1表明该指令是除beq，bne，lw，sw之外的I-类型指令，其余情况为0
  output Sftmd;  // 为1表明是移位指令，为0表明不是移位指令
  output [1:0]  ALUOp;        // 当指令为R-type或I_format为1时，ALUOp的高比特位为1，否则高比特位为0; 当指令为beq或bne时，ALUOp的低比特位为1，否则低比特位为0
  output IORead, IOWrite;
  output MemorIOtoReg;

  wire R_format, sw, lw;
  assign R_format = (opcode == `R_OP);
  assign I_format = (opcode[5:3] == 3'b001);
  assign lw       = (opcode == `LW_OP);
  assign sw       = (opcode == `SW_OP);
  assign RegDST   = R_format && (~I_format && ~lw);  //rd or rt
  assign Jr       = (Function_opcode == `JR_FUNC && R_format);
  assign RegWrite = (R_format || lw || Jal || I_format) && !(Jr) && inited;
  assign Jmp      = (opcode == `J_OP);
  assign Jal      = (opcode == `JAL_OP);
  assign Branch   = (opcode == `BEQ_OP);
  assign nBranch  = (opcode == `BNE_OP);

  wire MemRead;
  //OJ need
  assign MemWrite = sw && inited;
  assign MemRead  = lw && inited;
  wire IO = (Alu_resultHigh == `IO_MEM);
  // assign MemWrite     = (sw && !IO);
  // assign MemRead      = (lw && !IO);
  assign IORead       = (lw && IO && inited);
  assign IOWrite      = (sw && IO && inited);
  assign MemorIOtoReg = IORead || MemRead;


  assign Sftmd        = (R_format && Function_opcode[5:3] == 3'b000);
  assign ALUOp        = {(R_format || I_format), (Branch || nBranch)};
  assign ALUSrc       = (I_format || lw || sw);

  //R-type/立即数作32位扩展--指令1位为1
  //beq、bne--0位为1

endmodule
