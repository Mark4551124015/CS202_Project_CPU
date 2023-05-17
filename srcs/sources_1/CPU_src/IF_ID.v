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

module IF_ID (input clk,
              input rst,

              // From IF
              input [31:0] if_pc,
              input [31:0] if_inst,

              // To ID
              output reg [31:0] id_pc,
              output reg [31:0] id_inst,
              input stall);
    
    // Update and stall
    always @(posedge clk) begin
        if (rst | stall) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else begin 
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule
