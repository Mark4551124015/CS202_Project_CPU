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

`include "includes/defines.v"

module EXE (
    input rst,
    input [5:0] aluop,

    input [31:0] reg_1,
    input [31:0] reg_2,
    input [4:0] write_reg,
    input we,
    input [31:0] inst,
    input [31:0] pc,

    input [31:0] link_addr,

    output reg [2:0] mem_op,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_data,
    output this_load,
    output reg [4:0] wb_write_reg,
    output reg [31:0] wb_write_data,
    output reg wb_we
);

  assign this_load = (aluop == `EXE_LW_OP);

  always @(*) begin
    if (rst) begin
      wb_write_data = `ZeroWord;
      wb_write_reg = `NOPRegAddr;
      wb_we = 0;
    end else begin
      wb_write_data = `ZeroWord;
      wb_write_reg = write_reg;
      wb_we = we;
      case (aluop)
        `EXE_AND_OP:  wb_write_data = reg_1 & reg_2;
        `EXE_OR_OP:   wb_write_data = reg_1 | reg_2;
        `EXE_XOR_OP:  wb_write_data = reg_1 ^ reg_2;
        `EXE_NOR_OP:  wb_write_data = ~(reg_1 | reg_2);
        `EXE_SLL_OP:  wb_write_data = reg_2 << reg_1[4:0];
        `EXE_SRL_OP:  wb_write_data = reg_2 >> reg_1[4:0];
        `EXE_SRA_OP:  wb_write_data = ($signed(reg_2)) >>> reg_1[4:0];
        `EXE_SLT_OP:  wb_write_data = ($signed(reg_1) < $signed(reg_2)) ? 1 : 0;
        `EXE_SLTU_OP: wb_write_data = (reg_1 < reg_2) ? 1 : 0;
        `EXE_ADD_OP:  wb_write_data = reg_1 + reg_2;
        `EXE_SUB_OP:  wb_write_data = reg_1 + (~reg_2) + 1;
        `EXE_MUL_OP:  wb_write_data = reg_1 * reg_2;  //无符号乘法代替有符号乘法
        `EXE_JAL_OP:  wb_write_data = link_addr;

      endcase
    end
  end
  wire [31:0] imm_ext = {{16{inst[15]}}, inst[15:0]};
  always @(*) begin
    if (rst) begin
      mem_op   = `MEM_NOP_OP;
      mem_addr = `ZeroWord;
      mem_data = `ZeroWord;
    end else begin
      case (aluop)
        `EXE_LW_OP: begin
          mem_op   = `MEM_LW_OP;
          mem_addr = reg_1 + imm_ext;
          mem_data = `ZeroWord;
        end
        `EXE_SW_OP: begin
          mem_op   = `MEM_SW_OP;
          mem_addr = reg_1 + imm_ext;
          mem_data = reg_2;
        end
        default: begin
          mem_op   = `MEM_NOP_OP;
          mem_addr = `ZeroWord;
          mem_data = `ZeroWord;
        end
      endcase
    end
  end
endmodule
