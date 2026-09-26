module test_9_1_9;
    reg c;
    always c = #5 ~c;
endmodule
