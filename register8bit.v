`include "1bit_register.v"

module register8bit(data, load, outctrl, clk, Q, Qout);

    input [7:0] data;
    input load, outctrl, clk;
    output [7:0] Q, Qout;

    // create an 8bit register from 8 1bit registers
    // the load signal controls input loading or keeping the content
    // clk is clock
    // Q and Qout are the output and output invert of the flip flops
    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin : register_array
            register r(data[i], load, outctrl, clk, Q[i], Qout[i]);

        end
        endgenerate

endmodule