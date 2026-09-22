module test_5_1_1;
    wire a;
    wire b;
    reg c;
    always @* begin
        c = (a === b) | (~&a) | (^~b) | (a !== 0);
    end
endmodule
