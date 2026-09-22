module test_6_1_1;
    reg a;
    reg [7:0] vec;
    reg [7:0] mem [0:15];

    initial begin
        a = 1;
        vec = 8'hFF;
        mem[0] = 8'hAA;
    end
endmodule
