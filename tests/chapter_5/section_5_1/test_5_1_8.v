module test_5_1_8;
    integer IntA;
    always @* begin
        IntA = -12 / 3;
        IntA = -'d 12 / 3;
        IntA = -'sd 12 / 3;
        IntA = -4'sd 12 / 3;
    end
endmodule
