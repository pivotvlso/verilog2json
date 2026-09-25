module test_5_1_18;
    wire a;
    wire [1:0] b;
    reg [2:0] c;
    reg [4:0] d;

    always @* begin
        d = {a, b, 2'b11};
        c = {3{a}};
    end
endmodule
