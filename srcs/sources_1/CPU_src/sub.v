//verilog
module sub(in1,
           in2,
           result,
           overflow);
    input [2:0]in1,in2;
    output [2:0] result;
    output overflow;
    assign result = in1 - in2;
    assign overflow = 
    (~in1[2] & in2[2] & result[2]) |
    (in1[2] & ~in2[2] & ~result[2]);
endmodule
