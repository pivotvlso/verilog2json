module test_9_1_7;
    reg clk;
    reg a;
    reg b;
    always @(posedge clk) begin
        a <= @(posedge clk) b;
    end
endmodule
