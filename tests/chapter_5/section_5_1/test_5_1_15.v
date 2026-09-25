module test_5_1_15;
    reg a;
    reg b;
    reg c;
    reg d;
    reg [5:0] out;

    always @* begin
        out = {a, {2{b, c}}, d};
    end
endmodule
