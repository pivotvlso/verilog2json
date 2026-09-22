module test_4_9_3_8;
    reg [7:0] mema[0:255];
    reg cond;
    always @* begin
        if (cond == 1) begin
            mema[1] = 0; // Legal
        end else begin
            mema = 0; // Illegal Syntax
        end
    end
endmodule
