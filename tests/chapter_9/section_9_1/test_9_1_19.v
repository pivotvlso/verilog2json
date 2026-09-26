module test_9_1_19;
reg a;
reg b;
reg c;
reg d;
reg tmp1;
reg tmp2;
reg y;
always @* begin
    tmp1 = a & b;
    tmp2 = c & d;
    y = tmp1 | tmp2;
end
endmodule