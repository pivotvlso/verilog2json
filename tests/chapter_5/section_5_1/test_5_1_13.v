module test_5_1_13;
    reg a;
    reg b;
    reg c;
    reg d;
    reg [3:0] out;

    always @* begin
        out = {a, b, c, d};
    end
endmodule
