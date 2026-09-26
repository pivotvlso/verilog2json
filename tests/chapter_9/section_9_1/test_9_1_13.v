module test_9_1_13;
wire a;
wire b;
assign a = b;
assign #10 a = ~b;
endmodule
