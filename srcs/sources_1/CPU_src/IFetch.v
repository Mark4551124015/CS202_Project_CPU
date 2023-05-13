`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 21:28:00
// Design Name: 
// Module Name: Ifetc32
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

module Ifetc32 (
    Instruction,
    branch_base_addr,
    Addr_result,
    Read_data_1,
    Branch,
    nBranch,
    Jmp,
    Jal,
    Jr,
    Zero,
    clock,
    reset,
    link_addr
);
  output [31:0] Instruction;  // the instruction fetched from this module
  output [31:0] branch_base_addr;  // (pc+4) to ALU which is used by branch type instruction
  output reg [31:0] link_addr;  // (pc+4) to Decoder which is used by jal instruction

  input [31:0] Addr_result;  // the calculated address from ALU
  input [31:0] Read_data_1;  // the address of instruction used by jr instruction
  input Branch;  // while Branch is 1,it means current instruction is beq
  input nBranch;  // while nBranch is 1,it means current instruction is bnq
  input Jmp;  // while Jmp 1, it means current instruction is jump
  input Jal;  // while Jal is 1, it means current instruction is jal
  input Jr;  // while Jr is 1, it means current instruction is jr
  input Zero;  // while Zero is 1, it means the ALUresult is zero
  input        clock,reset;           // Clock and reset (Synchronous reset signal, high level is effective, when reset=1, PC value is 0)
  reg [31:0] PC, Next_PC;
  assign branch_base_addr = PC + 4;


  always @(*) begin
    if (Jr) begin
      Next_PC = Read_data_1;
    end else if ((Branch && Zero) || (nBranch && ~Zero)) begin
      Next_PC = Addr_result;
    end else begin
      Next_PC = PC + 4;
    end
  end

  always @(negedge clock) begin
    if (reset) begin
      PC = `ZeroWord;
    end else begin
      if (Jmp || Jal) begin
        PC = {4'b0000, Instruction[25:0], 2'b00};
      end else PC = Next_PC;
    end
  end



  always @(posedge Jmp or posedge Jal) begin
    link_addr = branch_base_addr;
  end

  prgrom myRAM (
      .clka(clock),  // input wire clka
      .addra(PC[15:2]),  // input wire [13 : 0] addra
      .douta(Instruction)  // output wire [31 : 0] douta
  );


endmodule
