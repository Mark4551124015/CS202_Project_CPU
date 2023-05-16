`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/21 23:55:04
// Design Name: 
// Module Name: record_module
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


module displays (
    input clk,  // 200hz system clock
    input [23:0] data_display,  // data_display data
    output reg [7:0] seg_en,  // Rnables of eight seven segment digital tubes
    output [7:0] seg_out  // Outputs
);
  reg [3:0] num0, num1, num2, num3, num4, num5, num6, num7;  // num6 is MSB
  reg [3:0] current_num;
  reg [7:0] seg_state;
  wire [7:0] seg_out_tmp;
  assign seg_out = ~seg_out_tmp;

  n2s number_to_seg(
      .number (current_num),
      .seg_out(seg_out_tmp)
  );

  clk_module #(
      .frequency(1000)
  ) clk_div (
      .clk(clk),
      .enable(1),
      .clk_out(clk_500hz)
  );


  //seg driver
  always @(posedge clk_500hz) begin
    if (seg_state != 8'b0000_0001) seg_state <= seg_state >> 1;
    else seg_state <= 8'b1000_0000;
  end

  always @(posedge clk) begin
    num7 <= data_display / 1_000_000_0 % 10;
    num6 <= data_display / 1_000_000 % 10;
    num5 <= data_display / 1_000_00 % 10;
    num4 <= data_display / 1_000_0 % 10;
    num3 <= data_display / 1_000 % 10;
    num2 <= data_display / 1_00 % 10;
    num1 <= data_display / 1_0 % 10;
    num0 <= data_display % 10;
    seg_en <= ~seg_state;
    case (seg_state)
    8'b1000_0000: current_num <= num7;
    8'b0100_0000: current_num <= num6;
    8'b0010_0000: current_num <= num5;
    8'b0001_0000: current_num <= num4;
    8'b0000_1000: current_num <= num3;
    8'b0000_0100: current_num <= num2;
    8'b0000_0010: current_num <= num1;
    8'b0000_0001: current_num <= num0;
    default: begin
    end
    endcase
  end
endmodule