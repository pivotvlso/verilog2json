module test_5_1_17;
    reg a;
    reg b;
    reg c;
    reg [2:0] out;

    always @* begin
        out = {a, b, c;
    end
endmodule
