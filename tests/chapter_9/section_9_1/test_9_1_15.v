module test_9_1_15;
reg a;
reg b;
always @(a) begin
    if (a) b = 1;
    else b = 0;
end
endmodule