module test_9_1_8;
    reg clk;
    reg a;
    reg b;
    always @(posedge clk) begin
        a <= repeat(3) @(posedge clk) b;
    end
endmodule
