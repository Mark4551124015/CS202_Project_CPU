`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 21:28:00
// Design Name: 
// Module Name: Dmem
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

module dmemory32 (
    input clock,  //Clock signal.
    input memWrite,  //From controller. 1'b1 indicates write operations to data-memory.
    input [31:0] address,  //The unit is byte. The address of memory unit which is to be read/writen.
    input [31:0] writeData,  //Data to be wirten to the memory unit.
    output [31:0] readData,  //Data read from memory unit.

    // UART Programmer Pinouts
    // input ram_clk_i,  // from CPU top
    // input ram_wen_i,  // from Controller
    // input [13:0] ram_adr_i,  // from alu_result of ALU
    // input [31:0] ram_dat_i,  // from read_data_2 of Decoder
    // output [31:0] ram_dat_o,  // the data read from data-ram

    input upg_rst_i,  // UPG reset (Active High)
    input upg_clk_i,  // UPG ram_clk_i (10MHz)
    input upg_wen_i,  // UPG write enable
    input [14:0] upg_adr_i,  // UPG write address
    input [31:0] upg_dat_i,  // UPG write data
    input upg_done_i
);  // 1 if programming is finished

  wire clk;
  assign clk = ~clock;

  /* CPU work on normal mode when kickOff is 1. CPU work on Uart communicate mode when kickOff is 0.*/
  wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);

//   RAM ram2 (
//       .clka (kickOff ? ram_clk : upg_clk_i),
//       .wea  (kickOff ? ram_wen_i : upg_wen_i),
//       .addra(kickOff ? ram_adr_i : upg_adr_i),
//       .dina (kickOff ? ram_dat_i : upg_dat_i),
//       .douta(ram_dat_o)
//   );
  reg [31:0] IO_in;     // 8bit switch
  reg [31:0] IO_out;    // 32bit leds
  wire upg_wen = upg_wen_i & upg_adr_i[14];
  wire [31:0] readData_tmp;
  assign readData = kickOff ? readData_tmp:`ZeroWord;
  RAM MEM (
      .clka (kickOff ? clk : upg_clk_i),  
      .wea  (kickOff ? memWrite : upg_wen),
      .addra(kickOff ? address[15:2] : upg_adr_i[13:0]),
      .dina (kickOff ? writeData : upg_dat_i),
      .douta(readData_tmp)
  );

endmodule
