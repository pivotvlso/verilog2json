module test_9_1_1;
    reg clk;
    reg a;
    reg b;
    reg c;

    initial begin
        #10 clk = 0;
        #5 a = 1;
        b = 0;
    end

    always @(posedge clk or negedge reset) begin
        c = a & b;
    end

endmodule
