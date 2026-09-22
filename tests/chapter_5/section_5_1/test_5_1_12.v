module test_5_1_12;
    reg [7:0] vect;
    reg [31:0] addr;
    reg out_bit;
    reg [3:0] out_part1;
    reg [4:0] out_part2;
    reg out_bit_x;
    reg out_bit_z;

    always @* begin
        vect = 4;
        addr = 2;
        
        // Bit select
        out_bit = vect[addr];
        
        // Standard Part selects
        out_part1 = vect[3:0];
        out_part2 = vect[5:1];
        
        // Bit select with unknown/high-Z expressions
        out_bit_x = vect[1'bx];
        out_bit_z = vect[1'bz];
    end
endmodule
