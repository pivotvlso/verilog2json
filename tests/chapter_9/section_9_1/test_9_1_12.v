module test_9_1_12;
reg a;
wire b;
reg c;

initial begin
    {a, {b, c}} = 3'b111;
end
endmodule