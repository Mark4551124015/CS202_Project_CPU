`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SUSTech
// Engineer: Mark455
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
// 

`include "includes/defines.v"

module decode32 (
    Read_data_1,
    Read_data_2,

    Instruction,
    mem_data,
    ALU_result,
    Jal,
    RegWrite,
    MemorIOtoReg,
    RegDst,
    Sign_extend,
    clock,
    reset,
    opcplus4
);
  output [31:0] Read_data_1;  // 输出的第一操作数
  output [31:0] Read_data_2;  // 输出的第二操作数
  input [31:0] Instruction;  // 取指单元来的指令
  input [31:0] mem_data;  //  从DATA RAM or I/O port取出的数据
  input [31:0] ALU_result;  // 从执行单元来的运算的结果
  input Jal;  //  来自控制单元，说明是JAL指令 
  input RegWrite;  // 来自控制单元
  input MemorIOtoReg;


  input RegDst;
  output [31:0] Sign_extend;  // 扩展后的32位立即数
  input clock, reset;  // 时钟和复位
  input [31:0] opcplus4;  // 来自取指单元，JAL中用


  wire [ 5:0] opcode;
  wire [ 4:0] rs;
  wire [ 4:0] rt;
  wire [ 4:0] rd;
  wire [ 4:0] shamt;
  wire [ 5:0] funct;
  wire [15:0] immediate;
  wire [25:0] address;
  assign opcode    = Instruction[31:26];
  assign rs        = Instruction[25:21];
  assign rt        = Instruction[20:16];
  assign rd        = Instruction[15:11];
  assign shamt     = Instruction[10:6];
  assign funct     = Instruction[5:0];
  assign immediate = Instruction[15:0];
  assign address   = Instruction[25:0];

  reg [31:0] register[0:31];

  reg [4:0] write_register_address;
  reg [31:0] write_data;

  assign Sign_extend = (opcode == `ANDI_OP || opcode == `ORI_OP || 
                        opcode == `XORI_OP || opcode == `SLTIU_OP) ? {16'b0, immediate} : {{16{immediate[15]}}, immediate};

  assign Read_data_1 = register[rs];
  assign Read_data_2 = register[rt];

  always @(negedge clock) begin
    if (RegWrite) begin
      if (Jal) write_register_address <= 5'b11111;
      else write_register_address <= RegDst ? rd : rt;
    end
  end

  always @(negedge clock) begin
    if (RegWrite) begin
      if (Jal) write_data <= opcplus4;
      else if (!MemorIOtoReg) write_data <= ALU_result;
      else if (MemorIOtoReg) begin
          write_data <= mem_data;
      end
    end
  end

  integer i;
  always @(posedge clock) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) register[i] <= 0;
    end else if (RegWrite && write_register_address != 0 ) begin
      register[write_register_address] <= write_data;
    end
  end

endmodule
