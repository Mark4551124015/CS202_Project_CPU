`timescale 1ns / 1ps
module Controller(Opcode,Function_opcode,Jr,Jmp,Jal,
Alu_resultHigh, 
Branch,nBranch,
RegDST, MemorIOtoReg, RegWrite,
MemRead, MemWrite, 
IORead, IOWrite,
ALUSrc,ALUOp,Sftmd,I_format);

input[5:0]   Opcode;    
input[5:0]   Function_opcode;
input[21:0]  Alu_resultHigh;//From the execution unit Alu_Result[31..10]
//The real address of LW and SW is Alu_Result, the signal comes from the execution unit
//From the execution unit Alu_Result[31..10], used to help determine whether to process Mem or IO
output       Jr;            //1--jr
output       Jmp;           //1--j
output       Jal;           //1--jal
output       Branch;        //beq
output       nBranch;       //bne
output       ALUSrc;        //second is imme exp.bne/beq
output       I_format;      //I-type exp.beq,bne,lw,sw
output       Sftmd;         //shift
output       RegDST;        //1--rd,0--rt(dst reg)
output[1:0]  ALUOp;         //是R-类型或I_format=1时位1为1, beq、bne指令则位0为1

output MemorIOtoReg;        //1--read from memory or I/O to the register
output RegWrite;            //1--write to the register
output MemRead;             //1--read from the memory
output MemWrite;            //1--write to the memory
output IOWrite;             //1--IO write
output IORead;              //1--I/O read

wire R_format, sw, lw;
assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;   //--00h 
assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1:1'b0;
assign lw = (Opcode==6'b100011)? 1'b1:1'b0;
assign RegDST = R_format && (~I_format && ~lw);     //rd or rt
assign Jr       = ((Function_opcode==6'b001000) && (Opcode==6'b000000)) ? 1'b1:1'b0;
assign RegWrite = (R_format || lw || Jal || I_format) && !(Jr) ; // Write memory or write IO
assign Jmp      = (Opcode==6'b000010) ? 1'b1:1'b0;
assign Jal      = (Opcode==6'b000011) ? 1'b1:1'b0;
assign Branch   = (Opcode==6'b000100) ? 1'b1:1'b0;
assign nBranch  = (Opcode==6'b000101) ? 1'b1:1'b0;

assign MemWrite = ((sw==1'b1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1 : 1'b0;
assign MemRead  = ((lw==1'b1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1 : 1'b0;
assign IORead   = ((lw==1'b1) && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1'b1 : 1'b0;
assign IOWrite  = ((sw==1'b1) && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1'b1 : 1'b0;
assign MemorIOtoReg = IORead || MemRead;
assign Sftmd    = (Opcode == 6'b000000 && Function_opcode[5:3] == 3'b000)? 1'b1:1'b0;
assign ALUOp    = {(R_format || I_format),(Branch || nBranch)}; 
assign sw = (Opcode == 6'b101011)?1'b1:1'b0;
assign ALUSrc = (I_format || lw || sw);

//R-type/立即数作32位扩展--指令1位为1
//beq、bne--0位为1

endmodule