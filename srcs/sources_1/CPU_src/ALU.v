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

`include "includes/defines.v"

module executs32 (
    Read_data_1,
    Read_data_2,
    Sign_extend,
    Function_opcode,
    opcode,
    Shamt,
    ALUOp,
    ALUSrc,
    I_format,
    Zero,
    Jr,
    Sftmd,
    ALU_result,
    Addr_result,
    PC_plus_4
);
  //Decoder 数据 有符号
  input [31:0] Read_data_1;  // 从译码单元的Read_data_1中来
  input [31:0] Read_data_2;  // 从译码单元的Read_data_2中来
  input [31:0] Sign_extend;  // 从译码单元来的扩展后的立即数
  input [5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
  input [5:0] opcode;  // 取指单元来的操作码
  input [1:0] ALUOp;  // 来自控制单元的运算指令控制编码
  input [4:0] Shamt;  // 来自取指单元的instruction[10:6]，指定移位次数
  input Sftmd;  // 来自控制单元的，表明是移位指令
  input ALUSrc;  // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
  input I_format;  // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
  input Jr;  // 来自控制单元，表明是JR指令
  output Zero;  // 为1表明计算值为0 
  output reg [31:0] ALU_result;  // 计算的数据结果
  output [31:0] Addr_result;  // 计算的地址结果        

  input [31:0] PC_plus_4;  // 来自取指单元的PC+4
  reg [31:0] ALU_output;



  // 决定输入
  wire [31:0] A_in, B_in;
  assign A_in = Read_data_1;
  assign B_in = ALUSrc ? Sign_extend : Read_data_2;
  assign Addr_result = PC_plus_4 + (Sign_extend << 2);
  reg  [31:0] Shift_Result;

  // 生成CPU控制码
  wire [ 5:0] Ext_code;
  assign Ext_code = (I_format == 1'b0) ? Function_opcode : {3'b000, opcode[2:0]};
  wire [2:0] ALU_ctrl;
  assign ALU_ctrl[0] = (Ext_code[0] | Ext_code[3]) & ALUOp[1];
  assign ALU_ctrl[1] = (!Ext_code[2]) | (!ALUOp[1]);
  assign ALU_ctrl[2] = (Ext_code[1] & ALUOp[1]) | ALUOp[0];
  initial begin
    ALU_output = 32'b0;
    ALU_result = 32'b0;
  end

  // ALU 计算，输出到 ALU_output
  always @(ALU_ctrl, A_in, B_in) begin
    case (ALU_ctrl)
      3'b000:  ALU_output = A_in & B_in;
      3'b001:  ALU_output = A_in | B_in;
      3'b010:  ALU_output = $signed(A_in) + $signed(B_in);
      3'b011:  ALU_output = A_in + B_in;
      3'b100:  ALU_output = A_in ^ B_in;
      3'b101:  ALU_output = ~(A_in | B_in);
      3'b110:  ALU_output = $signed(A_in) - $signed(B_in);
      3'b111:  ALU_output = (A_in) - (B_in);
      default: ALU_output = 32'b0;
    endcase
  end



  always @(*) begin
    if (Sftmd) begin
      case (Function_opcode)
        `SLL_FUNC: Shift_Result = B_in << Shamt;  // sll
        `SRL_FUNC: Shift_Result = B_in >> Shamt;  // srl
        `SLLV_FUNC: Shift_Result = B_in << A_in;  // sllv
        `SRLV_FUNC: Shift_Result = B_in >> A_in;  // srlv
        `SRA_FUNC: Shift_Result = $signed(B_in) >>> Shamt;  // sra
        `SRAV_FUNC: Shift_Result = $signed(B_in) >>> A_in;  // srav
        default: Shift_Result = B_in;
      endcase
    end else begin
      Shift_Result = B_in;
    end
  end

  always @(*) begin
    if (((ALU_ctrl == 3'b111) && (Ext_code[3] == 1)) || (ALU_ctrl[2:1] == 2'b11 && I_format)) begin
      ALU_result = {31'b0, (ALU_output[31] == 1)};
    end else if (ALU_ctrl == 3'b101 && I_format == 1) begin
      ALU_result = {B_in[15:0], {16'b0}};
    end else if (Sftmd == 1'b1) begin
      ALU_result = Shift_Result;
    end else begin
      ALU_result = ALU_output;
    end
  end

  assign Zero = (ALU_output == `ZeroWord);

endmodule
