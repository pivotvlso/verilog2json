module test_9_1_5;
    reg clk;
    reg a;
    reg b;
    always @(posedge clk) begin
        a = b;
    end
endmodule
