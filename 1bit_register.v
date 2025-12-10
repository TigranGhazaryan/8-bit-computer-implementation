`include "Edge_triggered_Dflipflop.v"

module register(data, load, outctrl, clk, Q, Qout);
    input data, load, outctrl, clk;
    output Q, Qout;

    // invert load signal and keep it in notload
    // and the notload and flipflop output, to decide to keep the data, or update it 
    // (if load is on, the invert is 0, so the AND gate a1 returns 0, and lets us update)
    // a2 helps us load (load = 1) data into the register (and the or gate decides its data or 
    // previous load)


    wire notload, keep_or_load, data_and_load;
    wire flipflop_input, flipflop_outputQ, flipflop_outputQ_bar;

    not (notload, load);
    and a1(keep_or_load, notload, flipflop_outputQ);
    and a2(data_and_load, data, load);
    or o1(flipflop_input, keep_or_load, data_and_load);
    

    // the flipflop gets inputs, clk and has standard Q and Qbar outputs
    Edge_triggered_Dflipflop D1(flipflop_input, clk, flipflop_outputQ,flipflop_outputQ_bar);

    assign Q = flipflop_outputQ;
    bufif1 (Qout,flipflop_outputQ, outctrl);

endmodule