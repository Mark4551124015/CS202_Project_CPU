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

module IO_module (
    IO_input,
    IO_seg_out,
    IO_led_out,
    IO_blink_out,
    TEST_input,
    IORead,
    IOWrite,
    ALU_result,
    Read_data_2,
    MemReadData,
    MemorIO_Result,
    enterA,
    enterB,
    clk
);
  // input clock;  //Clock signal.
  input IORead, IOWrite;
  input [7:0] IO_input;
  input [2:0] TEST_input;
  input [31:0] Read_data_2;
  input [31:0] ALU_result;
  input [31:0] MemReadData;
  input enterA, enterB;

  input clk;

  reg [31:0] counter;
  reg [ 4:0] front;
  reg [ 4:0] back;

  reg [23:0] VRAM       [0:31];
  reg [31:0] VRAM_time;
  reg [31:0] Blink_time;

  output reg [31:0] MemorIO_Result;
  output reg [23:0] IO_seg_out;
  output reg [23:0] IO_led_out;
  output reg IO_blink_out;

  reg [7:0] A_reg;
  reg [7:0] B_reg;

  reg seg_write;
  reg led_write;
  reg blk_write;


  integer i;
  initial begin
    A_reg <= 8'b0;
    B_reg <= 8'b0;
    IO_seg_out <= 24'b0;
    IO_led_out <= 24'b0;
    front <= 0;
    back <= 0;
    for (i = 0; i < 32; i = i + 1) VRAM[i] <= 0;
    VRAM_time = `One_Sec;
  end

  always @(*) begin
    if (enterA) begin
      A_reg <= IO_input;
    end
    if (enterB) begin
      B_reg <= IO_input;
    end
  end

  always@(posedge clk) begin
    if (front != back) begin
        if (VRAM_time > 0) VRAM_time = VRAM_time - 1;
        else  begin
            if (back != 5'd31)back = back + 1;
            else back = 0;
            VRAM_time = `One_Sec;
        end
        IO_seg_out <= VRAM[back];
    end else begin
        IO_seg_out <= 24'b0;
    end

    if (seg_write) begin
        VRAM[front] = Read_data_2;
        if (front != 5'd31) begin
            front = front + 1;
        end else begin
            front = 0;
        end
    end
    IO_led_out = {8'b0,A_reg,B_reg};

    if (led_write) begin
        // IO_led_out <= Read_data_2[15:0];
    end
    if (blk_write) begin
      Blink_time = Read_data_2;
    end
    if (Blink_time>0) begin
        IO_blink_out = 1;
        Blink_time = Blink_time - 1;
    end else begin
        IO_blink_out = 0;
    end
  end

  always @(*) begin
    if (IOWrite) begin
        case (ALU_result)
            `IO_SEG_ADDR: begin
               seg_write <= 1;
               led_write <= 0;
               blk_write <= 0;
            end
            `IO_BLINK_ADDR: begin
               seg_write <= 0;
               led_write <= 0;
               blk_write <= 1;
            end
            `IO_LED_ADDR: begin
               seg_write <= 0;
               blk_write <= 0;
               led_write <= 1;
            end
            default: begin
               seg_write <= 0;
               blk_write <= 0;
               led_write <= 0;
            end
        endcase
    end

    if (IORead) begin
      case (ALU_result)
        `IO_A_ADDR:    MemorIO_Result <= {24'b0, A_reg};
        `IO_B_ADDR:    MemorIO_Result <= {24'b0, B_reg};
        `IO_TEST_ADDR: MemorIO_Result <= {29'b0, TEST_input};
        default:       MemorIO_Result <= MemReadData;
      endcase
    end else begin
      MemorIO_Result = MemReadData;
    end
  end








endmodule
