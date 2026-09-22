module test_5_5_1;
    reg [15:0] a;
    reg signed [7:0] b;

    initial begin
        a = b[7:0];
    end
endmodule
