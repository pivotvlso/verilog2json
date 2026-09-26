module test_9_1_16;
reg index;
reg rega;
reg regb;
reg result;
always @* begin
    if (index > 0)
        if (rega > regb)
            result = rega;
        else
            result = regb;
end
endmodule
