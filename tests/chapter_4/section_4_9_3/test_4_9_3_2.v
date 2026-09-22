module test_4_9_3_2;
    reg [7:0] mema[0:255];
    initial begin
        mema = 0; // Illegal syntax- Attempt to write to entire array
    end
endmodule
