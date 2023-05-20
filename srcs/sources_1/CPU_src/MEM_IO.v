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

module MEM_IO (
  input clk,
  input rst,
  input io_we,
  input [31:0] io_data,
  input [31:0] io_addr,
  output reg [31:0] io_read_data,
  
  // Interaction with IO
  input enterA, enterB,
  input [7:0] AB_input,
  input [2:0] TEST_input,

  output reg [23:0] IO_seg_out,
  output reg [23:0] IO_led_out,
  output reg IO_blink_out
);

  reg [31:0] counter;
  reg [ 4:0] front;
  reg [ 4:0] writter;
  reg [ 4:0] back;
  reg [23:0] VRAM       [0:31];
  reg [31:0] VRAM_time;
  reg [31:0] Blink_time;



  reg [7:0] A_reg;
  reg [7:0] B_reg;

  wire seg_write;
  wire led_write;
  wire blk_write;


  integer i;
  initial begin
    A_reg <= 8'b0;
    B_reg <= 8'b0;
    IO_seg_out <= 24'b0;
    IO_led_out <= 24'b0;
    front <= 0;
    back <= 0;
    for (i = 0; i < 32; i = i + 1) VRAM[i] = 0;
    VRAM_time = `One_Sec;
  end

  always @(*) begin
    if (enterA) begin
      A_reg = AB_input;
    end
    if (enterB) begin
      B_reg = AB_input;
    end
  end

  always @(negedge clk) begin
    writter <= front;
    if (rst) begin
      VRAM[writter] = 0;
      front=0;
      back=0;
    end else begin
      if (seg_write) begin
        VRAM[writter] = io_data[23:0];
        if (front != 5'd31) begin
          front <= front + 1;
        end else begin
          front <= 0;
        end
      end

      if (front != back) begin
        IO_seg_out = VRAM[back];
        if (VRAM_time > 0) VRAM_time <= VRAM_time - 1;
        else begin
          if (back != 5'd31) back <= back + 1;
          else back <= 0;
          VRAM_time <= `One_Sec;
        end
      end else begin
        IO_seg_out = 24'b0;
      end
    end
    

    if (led_write) begin
      IO_led_out = io_data[15:0];
    end

    if (blk_write) begin
      Blink_time <= io_data * `One_Sec;
    end
    if (Blink_time > 0) begin
      IO_blink_out = 1;
      Blink_time <= Blink_time - 1;
    end else begin
      IO_blink_out = 0;
    end
  end

  assign seg_write = (io_we && io_addr == `IO_SEG_ADDR);
  assign led_write = (io_we && io_addr == `IO_LED_ADDR);
  assign blk_write = (io_we && io_addr == `IO_BLINK_ADDR);

  always @(*) begin
    if (!io_we) begin
      case (io_addr)
        `IO_A_ADDR:    io_read_data = {24'b0, A_reg};
        `IO_B_ADDR:    io_read_data = {24'b0, B_reg};
        `IO_TEST_ADDR: io_read_data = {29'b0, TEST_input};
        default:       io_read_data = `ZeroWord;
      endcase
    end else begin
      io_read_data = `ZeroWord;
    end
  end

endmodule
