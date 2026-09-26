module test_9_1_18;
reg a;
reg b;
reg c;
reg d;
reg f;
reg y;
always @(*)
    y = (a & b) | (c & d) | myfunction(f);
endmodule