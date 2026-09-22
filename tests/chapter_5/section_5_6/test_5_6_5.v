module test_5_6_5;
    reg [7:0] a;
    reg signed [7:0] b;
    reg signed [5:0] c;
    reg signed [5:0] d;

    initial begin
        a = 8'hff;
        c = a;
        b = -113;
        d = b;
    end
endmodule
