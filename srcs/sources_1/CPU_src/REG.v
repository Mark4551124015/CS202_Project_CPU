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

module registers (
    input clk,
    input rst,

    // Read Register
    input [4:0] read_addr_1,
    input re_1,
    output reg [31:0] read_data_1,

    input [4:0] read_addr_2,
    input re_2,
    output reg [31:0] read_data_2,

    // Write Register
    input wb_we,
    input [4:0] wb_write_reg,
    input [31:0] wb_write_data
    );
    
    reg [31:0] registers[0:31];
    
    // Write reg
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i = 0;i < 32; i = i + 1) registers[i] <= 0;
        end else begin
            if (wb_we && wb_write_reg != 5'b0) begin
                registers[wb_write_reg] <= wb_write_data; 
            end
        end
    end

    // Read regs
    always @(*) begin
        if (rst) begin
            read_data_1 = `ZeroWord;
        end else begin
            if (re_1) begin
                if (read_addr_1 == 5'b0) begin
                    read_data_1 =5'b0;
                end else if (re_1 == wb_write_reg && wb_we) begin
                    read_data_1 = wb_write_data;
                end else begin
                    read_data_1 = registers[read_addr_1];
                end
            end else begin
                read_data_1 = `ZeroWord;
            end
        end
    end

    always @(*) begin
        if (rst) begin
            read_data_2 = `ZeroWord;
        end else begin
            if (re_2) begin
                if (read_addr_2 == 5'b0) begin
                    read_data_2 =5'b0;
                end else if (re_2 == wb_write_reg && wb_we) begin
                    read_data_2 = wb_write_data;
                end else begin
                    read_data_2 = registers[read_addr_2];
                end
            end else begin
                read_data_2 = `ZeroWord;
            end
        end
    end
endmodule
