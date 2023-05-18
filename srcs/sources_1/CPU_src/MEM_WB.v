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

module MEM_WB (
    input             clk,
    input             rst,
    input             stall,
    //来自mem阶段的信息	
    input wire [ 4:0] mem_write_reg,
    input wire        mem_we,
    input wire [31:0] mem_write_data,

    output reg [ 4:0] wb_write_reg,
    output reg        wb_we,
    output reg [31:0] wb_write_data
);

  always @(posedge clk) begin
    if (rst) begin
      wb_write_reg <= `NOPRegAddr;
      wb_we <= 0;
      wb_write_data <= `ZeroWord;
    end else begin
      wb_write_reg <= mem_write_reg;
      wb_we <= mem_we;
      wb_write_data <= mem_write_data;
    end
  end
endmodule
