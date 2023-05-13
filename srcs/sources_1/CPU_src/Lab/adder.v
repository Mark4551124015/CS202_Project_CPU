module adder (in1,
              in2,
              sum,
              overflow); //in verilog
    input [2:0]in1,in2;
    output [2:0] sum;
    output overflow;
    assign sum = in1 + in2;
    assign overflow = 
    (in1[2] & in2[2] & ~sum[2]) | /* two +ve operands, get -ve operand*/
    (~in1[2] & ~in2[2] & sum[2]); /* two -ve operands, get +ve operand*/
    //hi
    
    
endmodule
