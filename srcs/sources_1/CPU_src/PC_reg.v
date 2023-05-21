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

module PC_reg (
    input clk,
    input rst,
    input branch_flag,
    input [31:0] branch_addr,
    input stall,
    output reg [31:0] pc,
    input inited);
    

    always @(posedge clk) begin
        if (!inited) pc <= `ZeroWord;
        else if (!stall) begin
            if (branch_flag) begin
                pc <= branch_addr;
            end else if (pc < 32'd4294967295) begin
                pc <= pc + 4;
            end
        end
    end
endmodule
