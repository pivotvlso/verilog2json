module test_4_9_3_4;
    reg arrayb[7:0][0:255];
    initial begin
        arrayb[1][12:31] = 0; // Illegal Syntax - Attempt to write to elements [1][12]..[1][31]
    end
endmodule
