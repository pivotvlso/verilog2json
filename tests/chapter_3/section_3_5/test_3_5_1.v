module test_3_5_1();
    wire [7:0] a = 8'b1010_0101;
    wire signed [31:0] b = 32'hDEAD_BEEF;
    wire [15:0] c = 16'd1234;
    wire d = 1'bz;
    wire e = 1'bx;

    // Multi-dimensional Packed
    wire [3:0][7:0] f = 32'h12345678;
    wire [1:0][3:0][7:0] g = 64'h1122334455667788;
    wire [1:0][1:0][3:0][7:0] h = 128'h112233445566778899AABBCCDDEEFF00;

    // Multi-dimensional Unpacked
    wire unpacked_2d [0:1][0:1] = '{ '{1'b0, 1'b1}, '{1'b1, 1'b0} };
    wire unpacked_3d [0:1][0:1][0:1] = '{ '{ '{1'b0, 1'b1}, '{1'b1, 1'b0} }, '{ '{1'b1, 1'b1}, '{1'b0, 1'b0} } };
    wire unpacked_4d [0:1][0:1][0:1][0:1] = '{ '{ '{ '{1'b0, 1'b1}, '{1'b1, 1'b0} }, '{ '{1'b1, 1'b1}, '{1'b0, 1'b0} } }, '{ '{ '{1'b0, 1'b1}, '{1'b1, 1'b0} }, '{ '{1'b1, 1'b1}, '{1'b0, 1'b0} } } };

    // Mixed Packed and Unpacked
    wire [7:0] mixed_2d [0:1] = '{ 8'hAA, 8'hBB };
    wire [1:0][7:0] mixed_2d_2d [0:1][0:2] = '{ '{16'hA, 16'hB, 16'hC}, '{16'hD, 16'hE, 16'hF} };

    // Syntax 3-1: Octal Numbers
    wire [11:0] octal_val = 12'o1234;



    // Syntax 3-1: Unsized Based Numbers
    wire [31:0] unsized_hex = 'hF;

    integer my_int = 32'd100;
    logic [7:0] my_logic = 8'hFF;
    logic my_logic_bit;

    wire [31:0] unsized_dec = 'd12;
    wire [31:0] unsized_bin = 'b1010;
    
    // Syntax 3-1: Underscores in numbers
    wire [31:0] hex_with_underscore = 'h6_d;

    // Syntax 3-1: Simple Decimals
    wire [31:0] simple_dec = 1234;
    wire [31:0] zero_dec = 0;

    // Syntax 3-1: Signed Constants
    wire [7:0] signed_dec = 8'sd12;
    wire [7:0] signed_hex = 8'shF;

    // Syntax 3-1: Unary Minus (Negative numbers)
    wire [7:0] neg_dec = -8'd6;

    // Syntax 3-1: Padding with x or z
    wire [7:0] pad_x = 8'bx_1010;
    wire [7:0] pad_z = 8'bZ;

    // Syntax 3-1: The ? wildcard (Alternative for z)
    wire [3:0] wildcard_num = 4'b10??;
endmodule
