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

module IF (input clk,
            input rst,
            input [31:0] pc,
            input upg_rst_i,            // UPG reset (Active High)
            input upg_clk_i,            // UPG clock (10MHz)
            input upg_wen_i,            // UPG write enable
            input [14:0] upg_adr_i,     // UPG write address
            input [31:0] upg_dat_i,     // UPG write data
            input upg_done_i,
            output reg [31:0] Instruction); // 1 if program finished
    
    
    
    /* if kickOff is 1 means CPU work on normal mode, otherwise CPU work on Uart communication mode */
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    
    wire [31:0] Instruction_read;
    wire upg_wen = upg_wen_i & ~upg_adr_i[14];
    
    prgrom instmem (
    .clka (kickOff ? clock : upg_clk_i),
    .wea  (kickOff ? 1'b0 : upg_wen),
    .addra(kickOff ? pc[15:2] : upg_adr_i[13:0]),
    .dina (kickOff ? `ZeroWord : upg_dat_i),
    .douta(Instruction_read)
    );
    always @(*) begin
        if (kickOff)  Instruction = Instruction_read;
        else Instruction          = `ZeroWord;
    end
    
endmodule
