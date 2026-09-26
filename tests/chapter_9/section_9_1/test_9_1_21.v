module test_9_1_21;
reg a;
reg b;
reg c;
reg d;
reg x;
always @* begin
    x = a ^ b;
    @*
        x = c ^ d;
end
endmodule