`timescale 1ns / 1ps


module CTRL (
    input  rst,
    input  enter,
    output stall,
    input  stall_req_if,
    input  stall_req_id,
    input  stall_req_io
);
    reg inited;
    
    initial begin
        inited <= 0;
    end

    always @(*) begin
        if (rst) begin
            inited = 0;
        end else if (enter) begin
            inited = 1;
        end
    end

    assign stall = stall_req_if | stall_req_id | stall_req_io | !inited;

endmodule
