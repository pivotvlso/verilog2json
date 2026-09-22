module test_5_1_6;
    // Chapter 3: Lexical Conventions & Keywords
    parameter integer CONST_VAL = 32;
    localparam real PI = 3.14159;
    localparam time DELAY = 10;
    
    // Chapter 4: Data Types, Nets, Vectors, Arrays
    wire clk;
    wire rst;
    reg signed [31:0] accumulator;
    logic [7:0] data_bus;
    reg [7:0] memory_array [0:255];
    
    // Chapter 5: Expressions & Operators
    reg out_flag;
    always @* begin
        // Mix of unary, binary, equality, logical, relational, shift, and bitwise
        out_flag = (~&data_bus) | (^~accumulator[7:0]) & (accumulator === 0);
        accumulator = accumulator + (CONST_VAL << 2) - 1;
        
        if (accumulator > 100 && out_flag != 1) begin
            memory_array[0] = data_bus ^ 8'hFF;
        end
    end
endmodule
