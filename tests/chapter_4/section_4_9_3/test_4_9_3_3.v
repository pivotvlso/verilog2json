module test_4_9_3_3;
    reg arrayb[7:0][0:255];
    initial begin
        arrayb[1] = 0; // Illegal Syntax - Attempt to write to elements [1][0]..[1][255]
    end
endmodule
