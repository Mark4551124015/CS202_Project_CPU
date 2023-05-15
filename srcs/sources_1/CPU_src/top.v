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


module top (clock,
            rst_n,
            switch,
            led,
            button,
            rx,
            tx);
    input clock;
    input rst_n;
    input [23:0] switch;
    output [23:0] led;
    
    
    //  input [23:0] switch2N4;
    //   output [23:0] led2N4;  // UART Programmer Pinouts
    
    input [4:0] button;
    
    wire enter,enterA,enterB,start_pg;
    
    
    input rx;
    output tx;  // start Uart communicate at high level
    wire rst;
    wire clk_23mhz;
    reg clk;
    wire clk_10mhz;
    reg inited;
    initial begin
        inited <= 0;
    end
    always @(clock) begin
        if (inited) begin
            clk <= clk_23mhz;
        end
        if (!rst_n) begin
            inited <= 0;
        end else if (enter) begin
            inited <= 1;
        end
    end

    cpuclk clk_mod (
    .clk_in1 (clock),
    .clk_out1(clk_23mhz),
    .clk_out2(clk_10mhz)
    );
    
    
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o;         //Uart write out enable
    wire upg_done_o;        //Uart rx data have done
    wire [14:0] upg_adr_o;  //data to which memory unit of program_rom/dmemory32
    wire [31:0] upg_dat_o;  //data to program_rom or dmemory32
    wire spg_bufg;
    wire [31:0] switch_out = switch;
    wire prg_ram;
    
    
    // Button and switches up,mid,down,left,right
    // BUFG U1 (
    // .I(button[4]),
    // .O(enter)
    // );
    BUFG U2 (
    .I(button[3]),
    .O(enter)
    );
    BUFG U3 (
    .I(button[2]),
    .O(start_pg)
    );
    BUFG U4 (
    .I(button[1]),
    .O(enterA)
    );
    BUFG U5 (
    .I(button[0]),
    .O(enterB)
    );
    
    // BUFG U6(
    // .I(start_pg),
    // .O(spg_bufg)
    // )
    assign spg_bufg = start_pg;
    assign prg_ram  = switch[19];
    
    
    reg upg_rst;
    always @(posedge clk) begin
        if (spg_bufg) upg_rst = 0;
        if (~rst_n) upg_rst   = 1;
    end
    
    //used for other modules which don't relate to UART
    assign rst = ~rst_n | !upg_rst;


    
    uart UART (
    .upg_clk_i(clk_10mhz),
    .upg_rst_i(upg_rst),
    .upg_rx_i (rx),
    .upg_clk_o (upg_clk_o),
    .upg_wen_o (upg_wen_o),
    .upg_done_o(upg_done_o),
    .upg_tx_o  (tx),
    .upg_dat_o(upg_dat_o),
    .upg_adr_o(upg_adr_o)
    );


    //CPU:
    wire [31:0] Addr_result;             // 从ALU计算出的地址
    wire        Zero;                    // 1-ALU Reuslt = 0
    wire [31:0] Read_A;                  // 读数�????1 / jr指令�????使用的指令地�????
    wire Branch, nBranch, Jmp, Jal, Jr;  // 控制信号 beq,bne,j,jal,jr
    wire [31:0] Instruction;       // 指令
    wire [31:0] branch_base_addr;  // PC + 4 分支指令使用，多跳一�????
    wire [31:0] link_addr;         // jal 指令使用�???? $32 寄存器保存的跳转回来的指�????
    wire [31:0] pco;               // PC 正常使用的下�????个地�????
    wire RegDST, MemorIOtoReg, RegWrite, MemWrite;
    wire ALUSrc, I_format, Sftmd;
    wire [1:0] ALUOp;
    wire [21:0] Alu_resultHigh;
    wire [31:0] MemReadData;
    wire [31:0] MemorIO_Result;
    wire MemRead, IORead, IOWrite;
    wire [5:0] opcode;
    wire [4:0] Shamt;
    wire [5:0] Function_opcode;
    wire [31:0] ALU_result;  // ALU 计算结果
    wire [31:0] Read_data_1;  // 读数1
    wire [31:0] Read_data_2;  // 读数2
    wire [31:0] Imme_extend;  // 立即(符号拓展)
    wire [31:0] r_wdata;
    assign opcode          = Instruction[31:26];
    assign Shamt           = Instruction[10:6];
    assign Function_opcode = Instruction[5:0];
    
    
    Ifetc32 if3 (
    .Instruction(Instruction),
    .branch_base_addr(branch_base_addr),
    .Addr_result(Addr_result),
    .Read_data_1(Read_data_1),
    .Branch(Branch),
    .nBranch(nBranch),
    .Jmp(Jmp),
    .Jal(Jal),
    .Jr(Jr),
    .Zero(Zero),
    .clock(clk),
    .reset(rst),
    .link_addr(link_addr),
    .upg_rst_i(upg_rst),       // UPG reset (Active High)
    .upg_clk_i(upg_clk_o),     // UPG clock (10MHz)
    .upg_wen_i(upg_wen_o),     // UPG write enable
    .upg_adr_i(upg_adr_o),     // UPG write address
    .upg_dat_i(upg_dat_o),     // UPG write data
    .upg_done_i(upg_done_o)    // 1 if program finished
    );
    
    
    
    
    control32 ctrl32 (
    .opcode(opcode),
    .Function_opcode(Function_opcode),
    .Jr(Jr),
    .RegDST(RegDST),
    .ALUSrc(ALUSrc),
    .MemorIOtoReg(MemorIOtoReg),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .nBranch(nBranch),
    .Jmp(Jmp),
    .Jal(Jal),
    .I_format(I_format),
    .Sftmd(Sftmd),
    .ALUOp(ALUOp),
    .Alu_resultHigh(ALU_result[31:10]),
    .IORead(IORead),
    .IOWrite(IOWrite)
    );
    
    
    decode32 u3 (
    .Read_data_1(Read_data_1),
    .Read_data_2(Read_data_2),
    .Instruction(Instruction),
    .mem_data(MemorIO_Result),
    .ALU_result(ALU_result),
    .Jal(Jal),
    .RegWrite(RegWrite),
    .MemorIOtoReg(MemorIOtoReg),
    .RegDst(RegDST),
    .Sign_extend(Imme_extend),
    .clock(clock),
    .reset(reset),
    .opcplus4(link_addr)
    );
    
    // ALU
    executs32 Uexe (
    .Read_data_1(Read_data_1),
    .Read_data_2(Read_data_2),
    .Sign_extend(Imme_extend),
    .Function_opcode(Function_opcode),
    .opcode(opcode),
    .ALUOp(ALUOp),
    .Shamt(Shamt),
    .ALUSrc(ALUSrc),
    .I_format(I_format),
    .Zero(Zero),
    .Sftmd(Sftmd),
    .ALU_result(ALU_result),
    .Addr_result(Addr_result),
    .PC_plus_4(branch_base_addr),
    .Jr(Jr)
    );
    
    IO_module MemORIO(
    .IO_input(switch_out[7:0]),
    .IO_output(led),
    .TEST_input(switch_out[23:21]),
    .IORead(IORead),
    .IOWrite(IOWrite),
    .ALU_result(ALU_result),
    .MemReadData(MemReadData),
    .MemorIO_Result(MemorIO_Result),
    .enterA(enterA),
    .enterB(enterB)
    );
    
    dmemory32 uram (
    .clock(clk),
    .memWrite(MemWrite),
    .address(ALU_result),
    .writeData(Read_data_2),
    .readData(MemReadData),
    .upg_rst_i(upg_rst),       // UPG reset (Active High)
    .upg_clk_i(upg_clk_o),     // UPG clock (10MHz)
    .upg_wen_i(upg_wen_o),     // UPG write enable
    .upg_dat_i(upg_dat_o),     // UPG write address
    .upg_adr_i(upg_adr_o),     // UPG write data
    .upg_done_i(upg_done_o)    // 1 if program finished
    );
    
    // debug
    // assign debug = ALU_result;
    
endmodule
