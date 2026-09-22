module test_4_9_3_1;
    reg [7:0] mema[0:255];
    reg arrayb[7:0][0:255];
    wire w_array[7:0][5:0];
    integer inta[1:64];
    time chng_hist[1:1000];
    integer t_index;
    
    initial begin
        mema[1] = 0;
        arrayb[1][0] = 0;
        inta[4] = 33559;
        chng_hist[t_index] = $time;
    end
endmodule
