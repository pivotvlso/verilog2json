module test_9_1_2;
    reg [1:0] a;
    reg [1:0] b;

    initial begin
        a = 'b1;
        b = 'b0;
    end
    
    always begin
        #50 a = ~a;
    end
    
    always begin
        #100 b = ~b;
    end
endmodule
