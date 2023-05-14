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


module top(clock, rst, switch, led, debug,fpga_clk,fpga_rst,switch2N4,led2N4,start_pg,rx,tx);
    input clock;
    input rst;
    input [31:0] switch;
    output [23:0] led;
    output [31:0] debug;

    input fpga_rst; //Active High
    input fpga_clk; 
    input[23:0] switch2N4;
    output[23:0] led2N4;// UART Programmer Pinouts
    input start_pg;
    input rx;
    output tx;// start Uart communicate at high level
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
    // Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge fpga_clk) begin
        if (spg_bufg) upg_rst = 0;
        if (fpga_rst) upg_rst = 1;
    end
    //used for other modules which don't relate to UART
    wire rst;
    assign rst = fpga_rst | !upg_rst;























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
    



    Ifetc32 if3(.Instruction(Instruction),.branch_base_addr(branch_base_addr),.Addr_result(Addr_result),.Read_data_1(Read_data_1),.Branch(Branch),.nBranch(nBranch),.Jmp(Jmp),.Jal(Jal),.Jr(Jr),.Zero(Zero),.clock(clk),.reset(rst),.link_addr(link_addr));
    

    // Controller
    wire RegDST, MemorIOtoReg, RegWrite, MemWrite;
    wire ALUSrc, I_format, Sftmd;
    wire [1:0] ALUOp;
    wire [21:0]Alu_resultHigh;
    wire MemRead, IORead, IOWrite;

    control32 ctrl32(.Opcode (Opcode_tb),.Function_opcode (Function_opcode_tb),.Jr (Jr_tb),.RegDST (RegDST_tb),.ALUSrc (ALUSrc_tb),
    .MemtoReg (MemtoReg_tb),.RegWrite (RegWrite_tb),.MemWrite (MemWrite_tb),.Branch (Branch_tb),.nBranch (nBranch_tb),.Jmp (Jmp_tb),.Jal (Jal_tb),
    .I_format (I_format_tb),.Sftmd (Sftmd_tb),.ALUOp (ALUOp_tb));

    //IDecode
    wire [31:0] read_data;  // 从 DATA RAM or I/O port取出的数据
    wire [31:0] ALU_result; // ALU 计算结果

    wire [31:0] Read_data_2; // 读数据2
    wire [31:0] imme_extend; // 立即数(符号拓展)
    
    wire [31:0] r_wdata;

    decode32 u3 (
      .read_data_1(read_data_1),
      .read_data_2(read_data_2),
      .Instruction(Instruction),
      .mem_data(mem_data),
      .ALU_result(ALU_result),
      .Jal(Jal),
      .RegWrite(RegWrite),
      .MemtoReg(MemtoReg),
      .RegDst(RegDst),
      .Sign_extend(Sign_extend),
      .clock(clock),
      .reset(reset),
      .opcplus4(opcplus4)
  );

    // ALU
    executs32 Uexe(.Read_data_1(Read_data_1),.Read_data_2(Read_data_2),.Sign_extend(Imme_extend),.Function_opcode(Function_opcode),.Exe_opcode(opcode),.ALUOp(ALUOp),
                     .Shamt(Shamt),.ALUSrc(ALUSrc),.I_format(I_format),.Zero(Zero),.Sftmd(Sftmd),.ALU_Result(ALU_Result),.Addr_Result(Addr_Result),.PC_plus_4(PC_plus_4),
                     .Jr(Jr));

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
