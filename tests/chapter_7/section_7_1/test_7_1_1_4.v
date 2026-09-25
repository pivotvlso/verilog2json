module test_7_1_1_4;
    wire out1;
    wire out2;
    wire out3;
    wire in1;
    wire in2;
    wire in3;
    wire ctrl;

    and a1 (out1, in1, in2, in3);
    nand na1 (out2, in1, in2);
    or o1 (out3, in1, in2);
    nor no1 (out1, in1, in2);
    xor x1 (out2, in1, in2);
    xnor xn1 (out3, in1, in2);

    buf b1 (out1, out2, in1);
    not n1 (out3, in1);

    bufif1 bf1 (out1, in1, ctrl);
    notif0 nf0 (out2, in2, ctrl);

endmodule
