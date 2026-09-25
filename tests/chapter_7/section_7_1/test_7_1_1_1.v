module test_7_1_1_1;
    wire a;
    wire b;
    wire c;
    wire d;

// Ordered instantiation with empty port
my_gate u1 (a, , c);

// Named instantiation with empty port
my_gate u2 (.p1(a), .p2(), .p3(c));
endmodule
