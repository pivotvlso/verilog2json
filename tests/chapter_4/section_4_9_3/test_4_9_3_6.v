module test_4_9_3_6;
    reg arrayb[7:0][0:255];
    reg cond;
    initial begin
        if (cond == 1) begin
            arrayb[1] = 0; // Illegal Syntax
        end
    end
endmodule
