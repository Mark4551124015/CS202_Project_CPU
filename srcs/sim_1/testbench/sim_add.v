module sim_add(); //verilog
    reg [2:0] in1,in2;
    wire overflow_adder;
    wire overflow_sub;
    wire [2:0] sum_add;
    wire [2:0] sum_sub;
    adder ua(in1,in2,sum_add,overflow_adder);
    sub us(in1,in2,sum_sub,overflow_sub);
    initial
    begin
        {in1[2],in2[2]}     = 2'b0;
        repeat(4)
        begin
            {in1[1:0],in2[1:0]} = 4'b0;
            repeat(16)
            begin
                #10 {in1[1:0],in2[1:0]} = {in1[1:0],in2[1:0]} + 1;
            end
            {in1[2],in2[2]} = {in1[2],in2[2]} + 1;

        end
        $finish;
    end
endmodule
