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

module pc_reg (input clk,
               input rst,
               input Branch,
               input nBranch,
               input Jmp,
               input Jal,
               input Jr,
               input Zero,
               input link_addr,
               input stall,
               input [31:0] Jraddr, // From Jump Register, Read_data_1
               output [13:0] pc,    // PC
               output chip_enable); 
  
        input branch_flag;
        input [31:0] branch_addr;
        input stall;
        output reg [13:0] pc;
        output reg chip_enable;
        
        
        always @(posedge clk) begin
            if (rst) chip_enable <= 0;
            else chip_enable     <= 1;
        end
        
        always @(posedge clk) begin
            if (chip_enable) pc <= `ZeroWord;
            else if (!stall) begin
            if (branch_flag) begin
                pc <= branch_addr;
                end else begin
                pc <= pc + 4;
            end
        end
        end
    endmodule
