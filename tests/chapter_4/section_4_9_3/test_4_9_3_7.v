module test_4_9_3_7;
    reg arrayb[7:0][0:255];
    reg cond;
    initial begin
        if (cond == 1) begin
            arrayb[1][1] = 0; // Legal
        end else if (cond == 0) begin
            arrayb[1][12:31] = 0; // Illegal Syntax
        end
    end
endmodule
