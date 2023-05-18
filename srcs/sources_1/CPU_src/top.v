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
            reset,
            switch,
            led,
            button,
            seg_en,
            seg_out,
            rx,
            tx);
    input clock;
    input reset;
    input [23:0] switch;
    output [23:0] led;
    output [7:0] seg_en;
    output [7:0] seg_out;
    input [4:0] button;
    input rx;
    output tx;  // start Uart communicate at high level
    
    // Control and IO
    wire upg_clk_o;
    wire upg_wen_o;         //Uart write out enable
    wire upg_done_o;        //Uart rx data have done
    wire [14:0] upg_adr_o;  //data to which memory unit of program_rom/dmemory32
    wire [31:0] upg_dat_o;  //data to program_rom or dmemory32
    wire blink_out;
    wire [31:0] switch_out = switch;
    wire [15:0] led_out;
    wire enter,enterA,enterB,start_pg;
    wire rst;
    wire clk;
    wire inited;
    
    //Clock
    cpuclk clk_mod (
    .clk_in1 (clock),
    .clk_out1(clk),
    .clk_out2(clk_10mhz)
    );
    
    reg upg_rst;
    always @(posedge clock) begin
        if (start_pg) upg_rst = 0;
        if (reset) upg_rst    = 1;
    end
    
    //used for other modules which don't relate to UART
    assign rst = reset | !upg_rst;
    
    TW U2 (.clk(clock),.I(button[3]),.O(enter));
    TW U3 (.clk(clock),.I(button[2]),.O(start_pg));
    TW U4 (.clk(clock),.I(button[1]),.O(enterA));
    TW U5 (.clk(clock),.I(button[0]),.O(enterB));
    
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
    
    wire stall;
    wire stall_req_if, stall_req_id, stall_req_io;
    CTRL ctrl(
    .rst(rst),
    .enter(enter),
    .stall_req_id(stall_req_id),
    .stall_req_if(stall_req_if),
    .stall_req_io(stall_req_io));
    
    wire [31:0] pc_reg_pc;
    wire branch_flag;
    wire [31:0] branch_addr;
    wire pc_chip_enable;
    // pc and IF
    PC_reg pc_reg(
    .rst(rst),
    .branch_flag(branch_flag),
    .branch_addr(branch_addr),
    .stall(stall),
    .pc(pc_reg_pc),
    .chip_enable(pc_chip_enable)
    );
    
    wire [31:0] if_inst;
    
    IF ifetch(
        .clk(clk),
        .rst(rst),
        .pc(pc_reg_pc),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_o),
        .upg_wen_i(upg_wen_o),
        .upg_adr_i(upg_adr_o),
        .upg_wen_i(upg_wen_o),
        .upg_done_i(upg_done_o),
        .Instruction(if_inst)
    );
    
    wire [31:0] if_id_pc;
    wire [31:0] if_id_inst;
    
    IF_ID if_id(
        .clk(clk),
        .rst(rst),
        .if_pc(pc_reg_o),
        .if_inst(if_inst),
        .id_pc(if_id_pc),
        .id_inst(if_id_inst),
        .stall(stall_req_id)
    );
    
    wire [31:0] id_read_addr_1;
    wire [31:0] id_read_addr_2;
    wire id_re_1, id_re_2;
    wire [5:0] id_aluop;
    wire [31:0] id_reg_1;
    wire [31:0] id_reg_2;
    wire [4:0] id_write_reg;
    wire id_we;
    wire [31:0] id_inst;
    wire id_branch_flag;
    wire [31:0] id_branch_addr;
    wire [31:0] id_link_addr;
    
    // Forwarding
    wire exe_we;
    wire [4:0] exe_write_reg;
    wire [31:0] exe_write_data;
    
    wire mem_we;
    wire [4:0] mem_write_reg;
    wire [31:0] mem_write_data;
    
    wire last_is_load;
    wire [31:0] last_store_addr;
    wire [31:0] last_store_data;
    wire [31:0] exe_load_addr;
    // IDecoder
    ID idecoder(
        .clk(clk),
        .rst(rst),
        .pc(if_id_pc),
        .inst(if_id_inst),
        .read_addr_1(id_read_addr_1),
        .re_1(id_re_1),
        .read_addr_2(id_read_addr_2),
        .re_2(id_re_2),
        .read_data_1(id_reg_1),
        .read_data_2(id_reg_2),
        .write_reg(id_write_reg),
        .we(id_we),
        .id_inst(id_inst),
        .exe_we(exe_wwe),
        .exe_write_reg(exe_write_reg),
        .exe_write_data(exe_write_data),
        .mem_we(mem_we),
        .mem_write_reg(mem_write_reg),
        .mem_write_data(mem_write_data),
        .last_store_addr(last_store_addr),
        .last_store_data(last_store_data),
        .exe_load_addr(exe_load_addr),
        .branch_flag(id_branch_flag),
        .branch_addr(id_branch_addr),
        .link_addr(id_link_addr),
        .last_is_load(last_is_load),
        .stall_req(stall_req_id)
    );

    wire wb_we;
    wire [31:0] wb_write_data;
    wire [4:0]  wb_write_reg;

    REGS regs(
        .clk(clk),
        .rst(rst),

        .read_addr_1(id_read_addr_1),
        .re_1(id_re_1),
        .read_data_1(id_reg_1),

        .read_addr_2(id_read_addr_2),
        .re_2(id_re_2),
        .read_data_2(id_reg_2),

        .wb_we(wb_we),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data)
    ); 
    
    wire [5:0] id_exe_aluop;
    wire [31:0] id_exe_pc;
    wire [31:0] id_exe_inst;
    wire [31:0] id_exe_reg_1;
    wire [31:0] id_exe_reg_2;
    wire [4:0] id_exe_write_reg;
    wire id_exe_we;
    wire [31:0] id_exe_link_addr;
    
    ID_EXE id_exe(
        .clk(clk),
        .rst(rst),
        .id_pc(if_id_pc),
        .id_aluop(id_aluop),
        .id_inst(id_inst),
        .id_reg_1(id_reg_1),
        .id_reg_2(id_reg_2),
        .id_write_reg(id_write_reg),
        .id_we(id_we),
        
        .exe_aluop(id_exe_aluop),
        .exe_pc(id_exe_pc),
        .exe_inst(id_exe_inst),
        .exe_reg_1(id_exe_reg_1),
        .exe_reg_2(id_exe_reg_2),
        .exe_write_reg(id_exe_write_reg),
        .exe_we(id_exe_we),
        .id_link_addr(id_link_addr),
        .exe_link_addr(id_exe_link_addr),
        .stall(stall)
    );
    
    wire [3:0] exe_memop;       // Exe to exe_mem
    wire [31:0] exe_memaddr;
    wire [31:0] exe_memdata;
    
    EXE exe(
        .rst(rst),
        .aluup(id_exe_aluop),
        .reg_1(id_exe_reg_1),
        .reg_2(id_exe_reg_2),
        .write_reg(id_exe_write_reg),
        .we(id_exe_we),
        .inst(id_exe_inst),
        .pc(id_exe_pc),
        .link_addr(id_exe_link_addr),
        .mem_op(exe_memop),
        .mem_addr(exe_memaddr),
        .mem_data(exe_memdata),
        .this_load(last_is_load),
        .wb_write_reg(exe_write_reg),
        .wb_write_data(exe_write_data),
        .wb_we(exe_we)
    );
    
    wire [31:0] exe_mem_pc;
    wire [3:0] exe_mem_memop;
    wire [31:0] exe_mem_memaddr;
    wire [31:0] exe_mem_memdata;
    wire exe_mem_we;
    wire [4:0] exe_mem_write_reg;
    wire [31:0] exe_mem_write_data;
    
    EXE_MEM exe_mem(
        .clk(clk),
        .rst(rst),
        
        .exe_pc(id_exe_pc),
        .exe_we(exe_we),
        .exe_write_reg(exe_write_reg),
        .exe_write_data(exe_write_data),
        
        .exe_mem_op(exe_memop),
        .exe_mem_addr(exe_memaddr),
        .exe_mem_data(exe_memdata),
        
        .mem_pc(exe_mem_pc),
        .mem_mem_op(exe_mem_memop),
        .mem_mem_addr(exe_mem_memaddr),
        .mem_mem_data(exe_mem_memdata),
        
        .mem_we(exe_mem_we),
        .mem_write_reg(exe_mem_write_reg),
        .mem_write_data(exe_mem_write_data),
        
        .last_store_addr(last_store_addr),
        .last_store_data(last_store_data),
        .stall(stall)
    );
    
    wire ram_wb_we;
    wire [4:0] ram_wb_write_reg;
    wire [4:0] ram_wb_write_data;

    wire [31:0] ram_addr;
    wire [31:0] ram_write_data;
    wire ram_chip_enable;
    wire [31:0] ram_read_data;
    wire ram_we;

    wire [31:0] io_addr;
    wire [31:0] io_write_data;
    wire [31:0] io_read_data;
    wire io_we;

    // MEM
    MEM mem(
        .clk(clk),
        .rst(rst),
        .mem_pc(exe_mem_pc),
        .we(exe_mem_we),
        .write_reg(exe_mem_write_reg),
        .write_data(exe_mem_write_data),
        .mem_op(exe_mem_memop),
        .mem_addr(exe_mem_memaddr),
        .mem_data(exe_mem_memdata),

        .wb_we(ram_wb_we),
        .wb_write_reg(ram_wb_write_reg),
        .wb_write_data(ram_wb_write_data),

        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_chip_enable(ram_chip_enable),
        .ram_read_data(ram_read_data),
        .ram_we(ram_we),

        .io_addr(io_addr),
        .io_write_data(io_write_data),
        .io_read_data(io_read_data)
    );

    MEM_RAM mem_ram(
        .mem_addr(ram_addr),
        .mem_write_data(ram_write_data),
        .mem_we(ram_we),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_o),
        .upg_wen_i(upg_wen_o),
        .upg_adr_i(upg_adr_o),
        .upg_dat_i(upg_dat_o),
        .upg_done_i(upg_done_o),
        .ram_read_data(ram_read_data)
    );

    wire [23:0] io_seg_data;
    wire [15:0] io_led_data;
    wire io_blink_data;
    MEM_IO mem_io(
        .clk(clock),
        .rst(rst),
        .io_we(io_we),
        .io_addr(io_addr),
        .io_data(io_write_data),
        .io_read_data(io_read_data),
        .enterA(enterA),
        .enterB(enterB),
        .AB_input(switch[7:0]),
        .TEST_input(switch[22:20]),
        .IO_seg_out(io_seg_data),
        .IO_blink_out(io_blink_data)
    );

    MEM_WB mem_wb(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .mem_write_reg(ram_wb_write_reg),
        .mem_we(ram_wb_we),
        .mem_write_data(ram_wb_write_data),
        .wb_write_reg(wb_write_reg),
        .wb_we(wb_we),
        .wb_write_data(wb_write_data)
    );
    // WB
    



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    displays disp(
    .clk(clock),
    .data_display(io_seg_data),
    .led_display(io_led_data),
    .blink_need(io_blink_data),
    .seg_out(seg_out),
    .seg_en(seg_en),
    .led_out(led),
    .blink_out(blink_out)
    );
    
    
    
endmodule
