module test_6_1_3;
    reg [3:0] a;
    reg [3:0] b;
    reg [7:0] c;

    initial begin
        {a, b} = c;
    end
endmodule
