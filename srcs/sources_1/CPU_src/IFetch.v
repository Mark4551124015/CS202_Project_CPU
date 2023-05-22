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
    link_addr,
    // rom_clk_i,  // ROM clock
    // rom_adr_i,  // From IFetch
    // Instruction_o,  // To IFetch

    // UART Programmer Pinouts
    upg_rst_i,  // UPG reset (Active High)
    upg_clk_i,  // UPG clock (10MHz)
    upg_wen_i,  // UPG write enable
    upg_adr_i,  // UPG write address
    upg_dat_i,  // UPG write data
    upg_done_i,  // 1 if program finished
    inited
);
  output reg [31:0] Instruction;  // the instruction fetched from this module
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

  // input rom_clk_i;  // ROM clock
  // input [13:0] rom_adr_i;  // From IFetch
  // output [31:0] Instruction_o;  // To IFetch

  // UART Programmer Pinouts
  input upg_rst_i;  // UPG reset (Active High)
  input upg_clk_i;  // UPG clock (10MHz)
  input upg_wen_i;  // UPG write enable
  input [14:0] upg_adr_i;  // UPG write address
  input [31:0] upg_dat_i;  // UPG write data
  input upg_done_i;  // 1 if program finished
  input inited;

  /* if kickOff is 1 means CPU work on normal mode, otherwise CPU work on Uart communication mode */
  wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);


  wire [31:0] Instruction_read;
  wire upg_wen = upg_wen_i & ~upg_adr_i[14];

  prgrom instmem (
      .clka (kickOff ? clock : upg_clk_i),
      .wea  (kickOff ? 1'b0 : upg_wen),
      .addra(kickOff ? PC[15:2] : upg_adr_i[13:0]),
      .dina (kickOff ? `ZeroWord : upg_dat_i),
      .douta(Instruction_read)
  );

  always @(*) begin
    if (reset) begin
      Next_PC = `ZeroWord;
    end else if ((Branch && Zero) || (nBranch && ~Zero)) begin
      Next_PC = Addr_result;
    end else if (PC < 16'd65535) begin
      Next_PC = PC + 4;
    end else begin
    end

    if (kickOff)  Instruction = Instruction_read; 
    else Instruction = `ZeroWord;
  end

  always @(negedge clock) begin
    if (reset) begin
      PC <= `ZeroWord;
      link_addr <= `ZeroWord;
    end 
    else if (!inited) begin
      PC <= `ZeroWord;
      link_addr <= `ZeroWord;
    end else begin
      if (Jmp || Jal) begin
        PC <= {4'b0000, Instruction[25:0], 2'b00};
        link_addr <= branch_base_addr;
      end else if (Jr) begin
        PC <= Read_data_1;
      end else begin 
        PC <= Next_PC;
      end
    end
  end

endmodule
