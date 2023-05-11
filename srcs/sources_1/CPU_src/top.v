`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 21:57:11
// Design Name: 
// Module Name: top
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


module top(clock, rst, switch, led, debug);
    input clock;
    input rst;
    input [31:0] switch;
    output [23:0] led;
    output [31:0] debug;

    wire clk;
    cpuclk clk_23mhz(
        .clk_in1(clock),
        .clk_out1(clk)
    );

    // IFetch
    wire [31:0] Addr_result;            // 从ALU计算出的地址
    wire Zero;                          // 1-ALU Reuslt = 0
    wire [31:0] Read_A;                 // 读数据1 / jr指令所使用的指令地址
    wire Branch, nBranch, Jmp, Jal, Jr; // 控制信号 beq,bne,j,jal,jr

    wire [31:0] Instruction;            // 指令
    wire [31:0] branch_base_addr;       // PC + 4 分支指令使用，多跳一位
    wire [31:0] link_addr;              // jal 指令使用的 $32 寄存器保存的跳转回来的指令
    wire [31:0] pco;                    // PC 正常使用的下一个地址
    



    IFetch fetch(
        .clock(clk),
        .reset(rst),
        .Addr_result(Addr_result),
        .Zero(Zero),
        .Read_data_1(Read_A),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .Jr(Jr),
        .Instruction(Instruction),
        .branch_base_addr(branch_base_addr),
        .link_addr(link_addr),
        .pco(pco)
    );

    // Controller
    wire RegDST, MemorIOtoReg, RegWrite, MemWrite;
    wire ALUSrc, I_format, Sftmd;
    wire [1:0] ALUOp;
    wire [21:0]Alu_resultHigh;
    wire MemRead, IORead, IOWrite;

    Controller control(
        .Opcode(Instruction[31:26]),
        .Function_opcode(Instruction[5:0]),
        .Jr(Jr),
        .Jmp(Jmp),
        .Jal(Jal),
        .Branch(Branch),
        .nBranch(nBranch),
        .RegDST(RegDST),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Sftmd(Sftmd),
        .ALUOp(ALUOp),
        .MemorIOtoReg(MemorIOtoReg),
        .MemRead(MemRead),
        .IORead(IORead),
        .IOWrite(IOWrite)
    );

    //IDecode
    wire [31:0] read_data;  // 从 DATA RAM or I/O port取出的数据
    wire [31:0] ALU_result; // ALU 计算结果

    wire [31:0] Read_data_2; // 读数据2
    wire [31:0] imme_extend; // 立即数(符号拓展)
    
    wire [31:0] r_wdata;

    Decoder decode(
        .clock(clk),
        .reset(rst),
        .Instruction(Instruction),
        .read_data(r_wdata),
        .ALU_result(ALU_result),
        .Jal(Jal),
        .RegWrite(RegWrite),
        .MemtoReg(MemorIOtoReg),
        .RegDst(RegDST),
        .opcplus4(link_addr),
        .read_data_1(Read_A),
        .read_data_2(Read_B),
        .imme_extend(imme_extend)
    );

    // ALU
    ALU execute(
        .Read_A(Read_A),
        .Read_B(Read_B),
        .Read_I(imme_extend),
        .opcode(Instruction[31:26]),
        .funct(Instruction[5:0]),
        .Shamt(Instruction[10:6]),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Sftmd(Sftmd),
        .Zero(Zero),
        .ALU_Result(ALU_result)
    );

    addrALU addrALU(
        .PC_plus_4(PC_plus_4),
        .Imme_extend(Imme_extend),
        .Addr_Result(Addr_Result)
    );

    wire [31:0] addr_out;
    wire [31:0] m_wdata;

    //MEM
    RAM memory(
        .clka(clk),
        .addra(addr_out),
        .wea(Memwrite),
        .dina(m_wdata),
        .douta(read_data)
    );


    
    // debug
    assign debug = ALU_result;

endmodule
