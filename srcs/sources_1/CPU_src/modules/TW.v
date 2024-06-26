`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/20 00:43:51
// Design Name: 
// Module Name: click_detector
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
// module TW (
//     input clk,  // 100MHz system clock
//     input I,  // Input I signal
//     output reg O  // Output I signal
// );
//   reg tmp = 0;
//   reg [31:0] protect_press = 0;
//   reg [31:0] protect_release = 0;
//   parameter cool_sec = 32'd2_000_000;
//   always @(posedge clk) begin
//       if (~tmp & I) begin
//         if (protect_press < cool_sec) begin
//           protect_press = protect_press + 1; 
//           O = 0;
//         end
//         else begin
//           tmp = 1;
//           O = 1;
//           protect_release = 0;
//         end
//       end else if (tmp & ~I) begin
//         if (protect_release < cool_sec) begin
//           protect_release = protect_release + 1; 
//         end
//         else begin
//           tmp = 0;
//           protect_press = 0;
//           O = 1;
//         end
//       end else begin
//         O = 0;
//       end
//   end
// endmodule

module TW(
    input wire clk,
    input wire I,
    output reg O
    );

    localparam TIME_20MS = 2_000_000;       // just for test

    // variable
    reg [32:0] cnt;
    reg key_cnt;
    
    // debounce time passed, refresh key state
    always @(posedge clk) begin
            if(cnt == TIME_20MS - 1)
            O <= I;
    end

    // while in debounce state, count, otherwise 0
    always @(posedge clk) begin
        if(key_cnt)
            cnt <= cnt + 1'b1;
        else
            cnt <= 0; 
    end
     
     // 
     always @(posedge clk) begin
            if(key_cnt == 0 && I != O)
                key_cnt <= 1;
            else if(cnt == TIME_20MS - 1)
                key_cnt <= 0;
     end
endmodule