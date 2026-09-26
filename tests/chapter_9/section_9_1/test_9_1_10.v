module test_9_1_10;
reg a;
reg b;
reg c;
reg d;
reg e;
reg f;

initial begin
    d <= #10 1; // d will be assigned 1 at time 10
    e <= #2 0;  // e will be assigned 0 at time 2
    f <= #4 1;  // f will be assigned 1 at time 4
end
endmodule
