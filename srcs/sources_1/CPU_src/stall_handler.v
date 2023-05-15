`timescale 1ns / 1ps
//位于ID译码上升沿阶段，当上一条指令是load且出现RAW时
//把本条PC送回PC模块使PC延时
//把功能块工作使能 Mwk(module work)置0，使该指令对后续功能块失效
module Bubble(
        input clk,
        input rst,
        input stall_req_if,
        input stall_req_id,
        input stall_req_ram,
        output stall
    );
    assign stall = stall_req_if | stall_req_id |stall_req_ram;
endmodule