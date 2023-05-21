`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 21:28:00
// Design Name: 
// Module Name: Dmem
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

module MEM (
    input clk,
    input rst,
    input [31:0] mem_pc,
    input we,
    input [4:0] write_reg,
    input [31:0] write_data,
    input [2:0] mem_op,
    input [31:0] mem_addr,
    input [31:0] mem_data,
    // To wb
    output reg wb_we,
    output reg [4:0] wb_write_reg,
    output reg [31:0] wb_write_data,

    output reg [31:0] ram_addr,
    output reg [31:0] ram_write_data,
    output reg ram_chip_enable,
    output reg ram_we,
    input [31:0] ram_read_data
,

    output reg [31:0] io_addr,
    output reg [31:0] io_write_data,
    output reg io_we,
    input [31:0] io_read_data

    // output stall_req,
    
    );

// assign  stall_req    = (mem_addr >= `IO_START_MEM);
wire IS_IO = (mem_addr >= `IO_START_MEM);

always @(*) begin
  if (rst) begin
    wb_we = 0;
    wb_write_reg = `NOPRegAddr;
    wb_write_data = `ZeroWord;
    
    ram_addr = `ZeroWord;
    ram_write_data = `ZeroWord;
    ram_we = 0;

    io_addr = `ZeroWord;
    io_write_data = `ZeroWord;
    io_we = 0;
    ram_chip_enable = 0;

  end else begin
    wb_we = we;
    wb_write_reg = write_reg;
  end
  case (mem_op)
    `MEM_LW_OP: begin
      if (IS_IO) begin
        wb_write_data = io_read_data;
        ram_addr = `ZeroWord;
        ram_write_data = `ZeroWord;
        ram_we = 0;
        ram_chip_enable = 0;

        io_addr = mem_addr;
        io_write_data = `ZeroWord;
        io_we = 0;
      end else begin
        wb_write_data = ram_read_data;
        ram_addr = mem_addr;
        ram_write_data = `ZeroWord;
        ram_we = 0;
        ram_chip_enable = 1;
        io_addr = `ZeroWord;
        io_write_data = `ZeroWord;
        io_we = 0;
      end
    end

    `MEM_SW_OP: begin
      if (IS_IO) begin
        wb_write_data = `ZeroWord;
        ram_addr = `ZeroWord;
        ram_write_data = `ZeroWord;
        ram_we = 0;
        ram_chip_enable = 0;
        io_addr = mem_addr;
        io_write_data = mem_data;
        io_we = 1;
      end else begin
        wb_write_data = `ZeroWord;
        ram_addr = mem_addr;
        ram_write_data = mem_data;
        ram_we = 1;
        ram_chip_enable = 1;
        io_addr = `ZeroWord;
        io_write_data = `ZeroWord;
        io_we = 0;
      end
    end

    default: begin
        wb_write_data = write_data;

        ram_addr = `ZeroWord;
        ram_write_data = `ZeroWord;
        ram_we = 0;

        io_addr = `ZeroWord;
        io_write_data = `ZeroWord;
        io_we = 0;
        ram_chip_enable = 0;

    end
  endcase
end



endmodule
