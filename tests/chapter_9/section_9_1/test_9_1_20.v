module test_9_1_20;
reg b;
reg kid;
always @* begin
    @(i) kid = b;
end
endmodule