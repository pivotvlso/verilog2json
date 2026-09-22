module test_5_1_7;
    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
    reg [31:0] e;
    always @* begin
        a = 12;
        b = 'd12;
        c = 'sd12;
        d = 16'd12;
        e = 16'sd12;
        
        a = 'hFf_AA_xX_zZ;
    end
endmodule
