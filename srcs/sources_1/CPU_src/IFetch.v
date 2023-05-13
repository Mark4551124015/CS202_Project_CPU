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
  output [31:0] link_addr;  // (pc+4) to Decoder which is used by jal instruction

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


  always @(*) begin
    // jr
    if (Jr == 1'b1) begin
      Next_PC <= Read_data_1 << 2;
    end  // beq, bne
    else if (((Branch == 1'b1) && (Zero == 1'b1)) || ((nBranch == 1'b1) && (Zero == 1'b0))) begin
      Next_PC <= Addr_result << 2;
    end  // PC + 4
    else begin
      Next_PC <= PC + 4;
    end
  end

  always @(negedge clock) begin
    if (reset == 1'b1) begin
      PC <= 32'h0000_0000;
    end else begin
      // j 或 jal
      if (Jmp || Jal) begin
        PC <= {4'b0000, Instruction[25:0], 2'b00};
      end  // 其它的正常更新
      else begin
        PC <= Next_PC;
      end
    end
  end

  assign branch_base_addr = PC + 4;
  reg [31:0] tmp_base_addr;

  always @(posedge Jmp, posedge Jal) begin
    tmp_base_addr = branch_base_addr >> 2;
  end
  assign link_addr = tmp_base_addr;





  prgrom myRAM (
      .clka(clock),  // input wire clka
      .addra(PC[15:2]),  // input wire [13 : 0] addra
      .douta(Instruction)  // output wire [31 : 0] douta
  );


endmodule
