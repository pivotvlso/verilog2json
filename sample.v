module abc_tb(a,b,c,d);

input reg a;
input reg b;
output reg c;
output reg d;
always @ (*) begin
 c=a&b;
 d=c&a;
end
endmodule
