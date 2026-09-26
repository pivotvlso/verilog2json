module test_9_1_11;
reg a;

initial a = 1;

initial begin
    a <= #4 0;
    a <= #4 1;
end
endmodule