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
//

`include "includes/defines.v"

module ID (input clk,
           input rst,
           input [31:0] pc,
           input [31:0] inst,

           output reg [4:0] read_addr_1,
           output reg re_1,
           output reg [4:0] read_addr_2,
           output reg re_2,
           input [31:0] read_data_1,
           input [31:0] read_data_2,
           output reg [5:0] aluop,
           output reg [31:0] reg_1,
           output reg [31:0] reg_2,
           output reg [4:0] write_reg,

           output reg we,
           output [31:0] id_inst,             // pass inst
           input exe_we,
           input [4:0] exe_write_reg,
           input [31:0] exe_write_data,
           
           input mem_we,
           input [4:0] mem_write_reg,
           input [31:0] mem_write_data,
           input [31:0] last_store_addr,
           input [31:0] last_store_data,
           input [31:0] exe_load_addr,

           output reg branch_flag,
           output reg [31:0] branch_addr,
           output reg [31:0] link_addr,
           input last_is_load,
           output stall_req);
    
    wire[5:0] opcode            = inst[31:26];
    wire[4:0] rs            = inst[25:21];
    wire[4:0] rt            = inst[20:16];
    wire[4:0] rd            = inst[15:11];
    wire[4:0] shamt         = inst[10:6];
    wire[5:0] funct          = inst[5:0];
    // I-Type
    wire [15:0] imm = inst[15:0];
    // J-type
    wire [25:0] inst_index = inst[25:0];
    // Extend Imme
    wire [31:0] imm_u = {{16{1'b0}}, imm};
    wire [31:0] imm_s = {{16{imm[15]}}, imm};
    wire [31:0] next_pc;
    wire [31:0] jump_addr   = {next_pc[31:28], inst_index, 2'b00};
    wire [31:0] branch_address = next_pc + {imm_s[29:0], 2'b00};
    
    reg stall_req_reg1;
    reg stall_req_reg2;

    
    reg [31:0] imm_ext;
    
    assign next_pc = pc + 4;

    assign stall_req = stall_req_reg1 | stall_req_reg2;
    assign id_inst = inst;
    // Decoding
    always @(*) begin
        if (rst) begin
            aluop        = `EXE_NOP_OP;
            re_1         = 0;
            read_addr_1  = `NOPRegAddr;
            re_2         = 0;
            read_addr_2  = `NOPRegAddr;
            we           = 0;
            write_reg    = `NOPRegAddr;
            imm_ext = `ZeroWord;
        end else begin
            aluop        = `EXE_NOP_OP;
            re_1         = 0;
            read_addr_1  = rs;
            re_2         = 0;
            read_addr_2  = rt;
            we           = 0;
            write_reg    = rd;
            imm_ext = `ZeroWord;
        end
        
        case (opcode)
            //addi, addiu
            `ADDIU_OP,`ADDI_OP: begin
                aluop        = `EXE_ADD_OP;
                re_1         = 1;
                re_2         = 0;
                we           = 1;
                write_reg    = rt;
                imm_ext = imm_s;
            end
            `SLTI_OP: begin
                aluop        = `EXE_SLT_OP;
                re_1         = 1;
                re_2         = 0;
                we           = 1;
                write_reg    = rt;
                imm_ext = imm_s;
            end
            `SLTIU_OP: begin
                aluop        = `EXE_SLTU_OP;
                re_1         = 1;
                re_2         = 0;
                we           = 1;
                write_reg    = rt;
                imm_ext = imm_s;
            end
            // `MUL_OP:begin
            //     if (shamt == 5'b0) begin
            //         case (funct)
            //             `MUL_FUNC: begin
            //                 aluop = `EXE_MUL_OP;
            //                 re_1  = 1;
            //                 re_2  = 1;
            //                 we    = 1;
            //                 // Write back to LOW/HIGH
            //             end
            //             default: begin
            //             end
            //         endcase
            //     end else begin
            //     end
            // end
            `ANDI_OP: begin
                aluop = `EXE_AND_OP;
                re_1 = 1;
                re_2 = 0;
                we = 1;
                write_reg = rt;
                imm_ext = imm_u;
            end
            `LUI_OP: begin
               aluop = `EXE_OR_OP;
               re_1 = 1;
               re_2 = 0;
               we = 1;
               write_reg = rt;
               imm_ext =  {imm, 16'b0};
            end
            `ORI_OP: begin
               aluop = `EXE_OR_OP;
               re_1 = 1;
               re_2 = 0;
               we = 1;
               write_reg = rt;
               imm_ext = imm_u;
            end
            `XORI_OP: begin
               aluop = `EXE_XOR_OP;
               re_1 = 1;
               re_2 = 0;
               we = 1;
               write_reg = rt;
               imm_ext = imm_u;
            end

            
            `BEQ_OP: begin
                re_1 = 1;
                re_2 = 1;
                we = 0;
            end
            `BNE_OP: begin
                re_1 = 1;
                re_2 = 1;
                we = 0;
            end        
            `J_OP: begin
                re_1 = 0;
                re_2 = 0;
                we = 0;
            end        
            `JAL_OP:begin
                aluop = `EXE_JAL_OP;
                re_1 = 0;
                re_2 = 0;
                we = 1;
                write_reg = 5'b11111;
            end

            `LB_OP: begin
                aluop = `EXE_LB_OP;
                re_1 = 1;
                re_2 = 0;
                we = 1;
                write_reg = rt;
                imm_ext = imm_s;
            end         
            `LW_OP: begin
                aluop = `EXE_LW_OP;
                re_1 = 1;
                re_2 = 0;
                we = 1;
                write_reg = rt;
                imm_ext = imm_s;
            end         
            `SB_OP: begin
                aluop = `EXE_SB_OP;
                re_1 = 1;
                re_2 = 1;
                we = 0;
            end           
            `SW_OP: begin
                aluop = `EXE_SW_OP;
                re_1 = 1;
                re_2 = 1;
                we = 0;
            end           
            `R_OP: begin
                if(shamt == 5'b00000) begin
                    case(funct)
                        `ADDU_FUNC,
                        `ADD_FUNC: begin
                            aluop = `EXE_ADD_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end
                        `SUBU_FUNC,
                        `SUB_FUNC: begin
                            aluop = `EXE_SUB_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end
                        `SLT_FUNC: begin
                            aluop = `EXE_SLT_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end
                        `SLTU_FUNC: begin
                            aluop = `EXE_SLTU_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end

                        `AND_FUNC: begin
                            aluop = `EXE_AND_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end  
                        `OR_FUNC: begin
                            aluop = `EXE_OR_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end   
                        `XOR_FUNC: begin
                            aluop = `EXE_XOR_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end   
                        `NOR_FUNC: begin
                            aluop = `EXE_NOR_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end

                        `SLLV_FUNC: begin
                            aluop = `EXE_SLL_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end  
                        `SRAV_FUNC: begin
                            aluop = `EXE_SRA_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end
                        `SRLV_FUNC :begin
                            aluop = `EXE_SRL_OP;
                            re_1 = 1;
                            re_2 = 1;
                            we = 1;
                        end 

                        `JR_FUNC: begin
                            re_1 = 1;
                            re_2 = 0;
                            we = 0;
                        end
                        `JALR_FUNC: begin
                            aluop = `EXE_JAL_OP;
                            re_1 = 1;
                            re_2 = 0;
                            we = 1;
                        end
                        default : begin
                        end
                    endcase
                end else if (rs == 5'b0) begin
                  case (funct) 
                    `SLL_FUNC: begin
                            aluop = `EXE_SLL_OP;
                            re_1 = 0;
                            re_2 = 1;
                            we = 1;
                            write_reg = rd;
                            imm_ext[4:0] = shamt;
                        end   
                        `SRL_FUNC: begin
                            aluop = `EXE_SRL_OP;
                            re_1 = 0;
                            re_2 = 1;
                            we = 1;
                            write_reg = rd;
                            imm_ext[4:0] = shamt;
                        end
                        `SRA_FUNC: begin
                            aluop = `EXE_SRA_OP;
                            re_1 = 0;
                            re_2 = 1;
                            we = 1;
                            write_reg = rd;
                            imm_ext[4:0] = shamt;
                        end
                        default : begin
                        end
                  endcase                  
                end else begin
                end
            end
            // More Instruction can be add here

            default: begin
            end
        endcase
    end




        //确定是否跳转及跳转地址
    always @(*) begin
        if(rst) begin
            branch_flag = 0;
            branch_addr = `ZeroWord;
            link_addr = `ZeroWord;
        end else begin
            branch_flag = 0;
            branch_addr = `ZeroWord;
            link_addr = `ZeroWord;
        end
        case(opcode)
            `BEQ_OP: begin
                if(reg_1 == reg_2) begin
                    branch_flag = 1;
                    branch_addr = branch_address;
                end else begin 
                end
            end
            `BNE_OP: begin
                if(reg_1 != reg_2) begin
                    branch_flag = 1;
                    branch_addr = branch_address;
                end else begin
                end
            end        
            `J_OP: begin
                branch_flag = 1;
                branch_addr = jump_addr;
            end        
            `JAL_OP: begin
                branch_flag = 1;
                branch_addr = jump_addr;
                link_addr = next_pc + 4;
            end
            `R_OP: begin
                if(shamt == 5'b00000) begin
                    case(funct) 
                        `JR_FUNC: begin
                            branch_flag = 1;
                            branch_addr = reg_1;
                        end
                        `JALR_FUNC: begin
                            branch_flag = 1;
                            branch_addr = reg_1;
                            link_addr = next_pc + 4;
                        end
                    default:	begin
                        end
                    endcase
                end
            end
            default :begin
                branch_flag = 0;
                branch_addr = `ZeroWord;
                link_addr = `ZeroWord;
            end
        endcase
    end


    wire reg_1_load_hazard = last_is_load && exe_write_reg == read_addr_1 && re_1;
    always @(*) begin
      reg_1 = `ZeroWord;
      stall_req_reg1 = 0;
      if (rst) begin
         reg_1 = `ZeroWord;
      end else if (reg_1_load_hazard) begin             // Load
            stall_req_reg1 = 1;
      end else if (re_1 && exe_we && exe_write_reg == read_addr_1) begin // EXE-EXE Forwarding
        reg_1 = exe_write_data;
      end else if (re_1 && mem_we && mem_write_reg == read_addr_1) begin // MEM-EXE Forwarding
        reg_1 = mem_write_data;
      end
      else if (re_1) begin
        reg_1 = read_data_1;
      end else if (~re_1) begin
        reg_1 = imm_ext;
      end else begin
        reg_1 = `ZeroWord;
      end
    end

    wire reg_2_load_hazard = last_is_load && exe_write_reg == read_addr_2 && re_2;
    always @(*) begin
      reg_2 = `ZeroWord;
      stall_req_reg2 = 0;
      if (rst) begin
        reg_2 = `ZeroWord;
      end else if (reg_2_load_hazard) begin             // Load
        stall_req_reg2 = 1;
      end else if (re_2 && exe_we && exe_write_reg == read_addr_2) begin // EXE-EXE Forwarding
        reg_2 = exe_write_data;
      end else if (re_2 && mem_we && mem_write_reg == read_addr_2) begin // MEM-EXE Forwarding
        reg_2 = mem_write_data;
      end
      else if (re_2) begin
        reg_2 = read_data_2;
      end else if (~re_2) begin
        reg_2 = imm_ext;
      end else begin
        reg_2 = `ZeroWord;
      end
    end
    
endmodule
