module test_5_1_11;
    reg [15:0] big_vect;
    reg [0:15] little_vect;
    reg [7:0] out;
    always @* begin
        out = big_vect[2 +: 8];
        little_vect[2 -: 8] = out;
    end
endmodule
