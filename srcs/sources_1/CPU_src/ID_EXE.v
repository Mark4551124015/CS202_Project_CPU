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

module ID_EXE (
    input clk,
    input rst,

    // From ID
    input [5:0] id_aluop,
    input [31:0] id_pc,
    input [31:0] id_inst,
    input [31:0] id_reg_1,
    input [31:0] id_reg_2,
    input [4:0] id_write_reg,
    input id_we,

    // To EXE
    output reg [5:0] exe_aluop,
    output reg [31:0] exe_pc,
    output reg [31:0] exe_inst,
    output reg [31:0] exe_reg_1,
    output reg [31:0] exe_reg_2,
    output reg [4:0] exe_write_reg,
    output reg exe_we,

    // Brach Addr
    input [31:0] id_link_addr,
    output reg [31:0] exe_link_addr,
    // Stall
    input stall
);

always @(posedge clk)begin
  if (rst || stall) begin
      exe_aluop <= `EXE_NOP_OP;
			exe_reg_1 <= `ZeroWord;
			exe_reg_2 <= `ZeroWord;
			exe_write_reg <= `NOPRegAddr;
			exe_we <= 0;
			exe_inst <= `ZeroWord;
			exe_pc <= `ZeroWord;
			exe_link_addr <= `ZeroWord;
  end else begin
      exe_aluop <= id_aluop;
			exe_reg_1 <= id_reg_1;
			exe_reg_2 <= id_reg_2;
			exe_write_reg <= id_write_reg;
			exe_we <= id_we;
			exe_inst <= id_inst;
			exe_pc <= id_pc;
			exe_link_addr <= id_link_addr;
  end
end
endmodule
