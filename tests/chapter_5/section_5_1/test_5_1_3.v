module test_5_1_3;
    wire a;
    wire b;
    reg c;
    always @* begin
        c = a <<< b;
    end
endmodule
