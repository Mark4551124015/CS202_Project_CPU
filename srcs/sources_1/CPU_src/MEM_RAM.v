`include "includes/defines.v"

module MEM_RAM (
    input clk,
    input [31:0] mem_addr,
    input [31:0] mem_write_data,
    input chip_enable,
    input mem_we,
    input upg_rst_i,  // UPG reset (Active High)
    input upg_clk_i,  // UPG ram_clk_i (10MHz)
    input upg_wen_i,  // UPG write enable
    input [14:0] upg_adr_i,  // UPG write address
    input [31:0] upg_dat_i,  // UPG write data
    input upg_done_i,
    output [31:0] ram_read_data
);

  
  /* CPU work on normal mode when kickOff is 1. CPU work on Uart communicate mode when kickOff is 0.*/
  wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);

  wire upg_wen = upg_wen_i & upg_adr_i[14];
  wire [31:0] readData_tmp;
  assign ram_read_data = (kickOff && chip_enable) ? readData_tmp : `ZeroWord;

  wire clock = ~clk;
  RAM MEM (
      .clka (kickOff ? clock : upg_clk_i),
      .wea  (kickOff ? mem_we : upg_wen),
      .addra(kickOff ? mem_addr[15:2] : upg_adr_i[13:0]),
      .dina (kickOff ? mem_write_data : upg_dat_i),
      .douta(readData_tmp)
  );
endmodule
