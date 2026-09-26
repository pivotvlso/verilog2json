module test_9_1_22;
reg a;
reg en;
reg [7:0] y;
always @* begin
    y = 8'hff;
    y[a] = !en;
end
endmodule