module test_4_9_3_5;
    reg [7:0] mema[0:255];
    always @* begin
        mema = 0; // Illegal syntax- Attempt to write to entire array
    end
endmodule
