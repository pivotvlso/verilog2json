module test_7_1_1_2;
    wire [3:0] data;
    wire clk;

// Ordered instantiation with literal and slice
my_gate u1 (1'b1, data[3:0], clk);

// Named instantiation with literal and slice
my_gate u2 (.en(1'b0), .d(data[1:0]), .clk(clk));
endmodule
