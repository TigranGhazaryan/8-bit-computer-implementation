`include "SRlatch.v"

module  Dflipflop (clk, data1, data2, Q, Q_bar);
    input clk, data1, data2;
    output Q, Q_bar;

    wire data1_clk, data2_clk;

    and a1 (data1_clk,data1, clk);
    and a2 (data2_clk, data2, clk);

    SRlatch S1(data1_clk, data2_clk, Q, Q_bar);
    
endmodule