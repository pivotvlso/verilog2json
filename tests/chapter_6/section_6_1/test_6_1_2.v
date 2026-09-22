module test_6_1_2;
    reg [15:0] a;
    integer idx;

    initial begin
        a[0] = 1'b1;
        a[3:1] = 3'b101;
        a[idx+:4] = 4'hA;
    end
endmodule
