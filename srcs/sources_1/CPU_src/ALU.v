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


module ALU(Read_A,Read_B,Read_I,funct,opcode,shamt,ALUOp,ALUSrc,I_format,Sftmd,Zero,ALU_Result);
    //Decoder 数据
    input [31:0] Read_A;    // 输入A  - Reg
    input [31:0] Read_B;    // 输入B1 - Reg
    input [31:0] Read_I;    // 输入B2 - Immed

    //IF 数据
    input [5:0] funct;      // function码
    input [5:0] opcode;     // 操作码
    input [4:0] shamt;      // 位移
    
    //ALU 控制信号
    input[1:0] ALUOp;
    // 如果指令是 R-type 或 I_format = 1, ALUOp = 2'b10;
    // 如果指令是 beq 或 bne, ALUOp = 2'b01;
    // 如果指令是 lw 或 sw, ALUOP = 2'b00;
    input ALUSrc;          // 1 - 输入B为立即数 （除了beq、bne）
    input I_format;         // 1 - 指令是 I-类型（除了beq、bne、lw、sw）
    input Sftmd;

    output wire Zero;                       // 1 - 输出是0
    output reg  [31:0]  ALU_Result;         // ALU计算结果
    reg         [31:0]  ALU_output;
    
    assign Zero = (ALU_output[31:0] == 32'h00000000) ? 1'b1 : 1'b0;

    // 决定输入
    wire signed [31:0]  A_in,B_in;  //两个计算输入
    assign A_in = Read_A;
    assign B_in = (ALUSrc == 0) ? Read_B : Read_I;

    //决定 Ext_code
    wire    [5:0] Ext_code;         // 用于生成 ALU_ctrl
    assign Ext_code = (I_format == 0) ? funct : { 3'b000 , opcode[2:0]};

    // 生成CPU控制码
    wire [2:0] ALU_ctrl;
    assign ALU_ctrl[0] = (Ext_code[0] | Ext_code[3]) & ALUOp[1];
    assign ALU_ctrl[1] = ((!Ext_code[2]) | (!ALUOp[1]));
    assign ALU_ctrl[2] = (Ext_code[1] & ALUOp[1]) | ALUOp[0];
    

    // ALU 计算，输出到 ALU_output
    always @(ALU_ctrl or A_in or B_in) begin
        case(ALU_ctrl)
            3'b000: ALU_output = A_in & B_in;
            3'b001: ALU_output = A_in | B_in;
            3'b010: ALU_output = A_in + B_in ;
            3'b011: ALU_output = A_in + B_in;
            3'b100: ALU_output = A_in ^ B_in;
            3'b101: ALU_output = ~(A_in | B_in);
            3'b110: ALU_output = A_in - B_in;
            3'b111: ALU_output = A_in - B_in;
            default: ALU_output <= 32'h0000_0000;
        endcase
    end

    reg [31:0] Shift_Result;    // 移位结果
    wire [2:0] shift_ctrl;           // 移位操作操作码
    assign shift_ctrl = funct[2:0];

    always @(*) begin
        if (Sftmd) begin
        case (shift_ctrl) 
                3'b000: Shift_Result = B_in << shamt;   // sll
                3'b010: Shift_Result = B_in >> shamt;   // srl
                3'b100: Shift_Result = B_in << A_in;    // sllv
                3'b110: Shift_Result = B_in >> A_in;    // srlv
                3'b011: Shift_Result = B_in >>> shamt;  // sra
                3'b111: Shift_Result = B_in >>> A_in;   // srav
                default:Shift_Result = B_in;
        endcase
        end
        else begin
            Shift_Result = B_in;
        end
    end
    
    
    wire slt;
    assign slt = (((ALU_ctrl == 3'b111) && (Ext_code[3] == 1))||((ALU_ctrl[2:1] == 2'b11) && (I_format == 1)));
    always @(*) begin
        if (slt) begin
            ALU_output = (A_in-B_in<0)? 1:0;
        end
        else if (ALU_ctrl == 3'b101 && I_format == 1) begin
            ALU_output = {B_in[15:0],{16'b0}};    
        end
        else if (Sftmd == 1'b1) begin
            ALU_output = Shift_Result;
        end 
        else begin
            ALU_output = ALU_Result;
        end
    end
endmodule
