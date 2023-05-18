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

module EXE_MEM (
    input clk,
    input rst,

    // From EXE
    input [31:0] exe_pc,
    input [31:0] exe_we,
    input [4:0] exe_write_reg,
    input [31:0] exe_write_data,
    
    input [3:0] exe_mem_op,
    input [31:0] exe_mem_addr,
    input [31:0] exe_mem_data,
    
    // To MEM
    output reg [31:0] mem_pc,
    output reg [3:0] mem_mem_op,
    output reg [31:0] mem_mem_addr,
    output reg [31:0] mem_mem_data,

    output reg mem_we,
    output reg [4:0] mem_write_reg,
    output reg [31:0] mem_write_data,

    // No Stall
    input stall,

    // Brach Addr
    output reg [31:0] last_store_data,
    output reg [31:0] last_store_addr


);

  always @(*) begin
    if (rst) begin
      mem_pc <= `ZeroWord;
      mem_mem_addr <= `MEM_NOP_OP;
      mem_mem_addr <= `ZeroWord;
      mem_mem_data <= `ZeroWord;

      mem_we <= 0;
      mem_write_reg <= `NOPRegAddr;
      mem_write_data <= `ZeroWord;

      last_store_addr <= `ZeroWord;
      last_store_data <= `ZeroWord;
    end else begin
      mem_pc <= exe_pc;
      mem_mem_op <= exe_mem_op;
      mem_mem_addr <= exe_mem_addr;
      mem_mem_data <= exe_mem_data;

      mem_we <= exe_we;
      mem_write_reg <= exe_write_reg;
      mem_write_data <= exe_write_data;
      case (exe_mem_op) 
        `MEM_SW_OP: begin
          last_store_addr <= exe_mem_addr;
          last_store_addr <= exe_mem_addr; 
        end
        default: begin
          last_store_addr <= last_store_addr;
          last_store_addr <= last_store_addr; 
        end
      endcase
    end
  end
endmodule
