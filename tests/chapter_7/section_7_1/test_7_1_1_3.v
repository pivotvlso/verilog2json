module test_7_1_1_3;
    wire a;
    wire b;
    wire [1:0] c;

    // Named instantiation with concatenation
my_gate u1 (.in({a, b}), .out(c));
endmodule
