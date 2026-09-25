module test_5_1_16;
    reg a;
    reg b;
    reg c;
    reg out;

    always @* begin
        out = a, b, c;
    end
endmodule
