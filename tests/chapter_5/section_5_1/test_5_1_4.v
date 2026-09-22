module test_5_1_4;
    wire a;
    wire b;
    reg [1:0] c;
    always @* begin
        c = {a, b};
    end
endmodule
