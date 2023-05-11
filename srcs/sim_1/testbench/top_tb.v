`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 23:59:25
// Design Name: 
// Module Name: top_tb
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


module top_tb();
    reg clk = 1;
    reg cnt = 0;
    wire [31:0] Instruction;

    reg rst;
    initial begin
        repeat(250) begin
            if (cnt < 1) begin
                rst = 1;
                cnt = cnt+1;
            end else begin
                rst = 0;
            end
            #1 clk <= clk+1;
            
        end
        $finish;
    end
    top cpu(
        .clock(clk),
        .rst(rst),
        .debug(Instruction)
    );
endmodule
