module test_9_1_14;
reg a;
always @(a) begin
    if (a) ;
    else a = 0;
end
endmodule