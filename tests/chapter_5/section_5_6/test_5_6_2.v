module test_5_6_2;
    reg [15:0] a;
    reg [15:0] b;
    reg [15:0] c;
    reg signed [15:0] s;

    initial begin
        a = (s / b);
        c = (a + b);
    end
endmodule
