`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 23:47:41
// Design Name: 
// Module Name: addrALU
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


module addrALU(PC_plus_4,Imme_extend,Addr_Result);
    input [31:0] PC_plus_4;
    input [31:0] Imme_extend;
    output [31:0] Addr_Result;

    // 跳转的分支地址
    wire [32:0] Branch_Addr;     // 该指令的计算地址，Addr_Result是 Branch_Addr[31:0]
    assign Branch_Addr = PC_plus_4[31:2] +  Imme_extend[31:0]; 
    assign Addr_Result  = Branch_Addr[31:0]; 
endmodule
