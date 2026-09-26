module test_9_1_4;
    reg a;
    reg b;
    wire c;
    wire d;
    initial begin
        a = #10 b;
    end
endmodule
