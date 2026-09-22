module test_5_1_10;
    reg [31:0] a;
    reg [31:0] foo;
    reg [31:0] result1;
    reg [31:0] result2;
    reg [31:0] result3;
    reg [31:0] result4;

    always @* begin
        result1 = a < foo - 1;
        result2 = a < (foo - 1);
        result3 = foo - (1 < a);
        result4 = foo - 1 < a;
    end
endmodule
