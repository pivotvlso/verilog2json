module test_4_10_2;
    // Parameter types
    parameter integer PARAM1 = 32'd10;
    parameter real PARAM2 = 1; // Evaluated as integer 1 for now due to limitation
    parameter realtime PARAM3 = 2; // Evaluated as integer 2
    parameter time PARAM4 = 3;

    // Signedness and range combinations
    parameter signed [15:0] PARAM5 = 16'hFFFF;
    localparam integer PARAM6 = 10;
    localparam signed [31:0] PARAM7 = 32'hFFFFFFFF;
    
    // Default untyped
    parameter PARAM8 = 10;
    localparam PARAM9 = 20;

    // Unpacked dimensions (not usually used for parameters but let's test parser robustness)
    parameter [7:0] PARAM10 [0:3] = 0; // The parser limitation says comma separated is unsupported, but unpacked dimensions are just [] after name
endmodule
