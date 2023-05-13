`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 23:59:25
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb();

    reg[31:0]  Read_data_1 = 32'h00000005;		//r-form rs
    reg[31:0]  Read_data_2 = 32'h00000006;        //r-form rt
    reg[31:0]  Imme_extend = 32'hffffff40;        //i-form
    reg[5:0]   Function_opcode = 6'b100000;      //add 
    reg[5:0]   opcode = 6'b000000;          //op code
    reg[1:0]   ALUOp = 2'b10;
    reg[4:0]   Shamt = 5'b00000;
    reg        Sftmd = 1'b0;
    reg        ALUSrc = 1'b0;
    reg        I_format = 1'b0;
    reg        Jr = 1'b0;
    reg[31:0]  PC_plus_4 = 32'h00000004;
    wire       Zero;
    wire[31:0] ALU_Result;
    wire[31:0] Addr_Result;        //pc op   
    initial begin
        
        begin 
            opcode = 6'b0001010; // SLTI 17
            Read_data_1 = 32'h00000001;        // r-form rs
            Read_data_2 = 32'h00000011;        // r-form rt
            Imme_extend = 32'h00000011;  
            Function_opcode = 6'b001010;      // SLTI 2a
            ALUOp = 2'b10;
            Shamt = 5'b00000;
            Sftmd = 1'b0;
            ALUSrc = 1'b1;
            I_format = 1'b1;
            PC_plus_4 = 32'h00000022;
        end

    end

    
   executs32 Uexe(.Read_data_1(Read_data_1),.Read_data_2(Read_data_2),.Sign_extend(Imme_extend),.Function_opcode(Function_opcode),.Exe_opcode(opcode),.ALUOp(ALUOp),
                     .Shamt(Shamt),.ALUSrc(ALUSrc),.I_format(I_format),.Zero(Zero),.Sftmd(Sftmd),.ALU_Result(ALU_Result),.Addr_Result(Addr_Result),.PC_plus_4(PC_plus_4),
                     .Jr(Jr));




endmodule
