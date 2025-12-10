`include "Dflipflop.v"

module Edge_triggered_Dflipflop(data, clk, Q, Q_bar);

    input data, clk;
    output Q, Q_bar;

    wire not_data, not_clk;

    not n1(not_data, data);
    not n2(not_clk, clk);

    wire D1_out_Q, D1_out_Q_bar;

    // Master Flip flop
    Dflipflop D1(not_clk, data, not_data, D1_out_Q, D1_out_Q_bar);

    // Slave Flip flop
    Dflipflop D2(clk, D1_out_Q, D1_out_Q_bar, Q, Q_bar);

endmodule