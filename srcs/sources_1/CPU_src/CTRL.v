`timescale 1ns / 1ps


module CTRL (
    input  clk,
    input  rst,
    input  enter,
    output stall,
    input  stall_req_if,
    input  stall_req_id,
    input  stall_req_io,
    output reg inited
);

    always @(posedge clk) begin
        if (rst) begin
            inited <= 0;
        end else if (enter) begin
            inited <= 1;
        end else begin
        end
    end
    assign stall =  stall_req_id;

endmodule
