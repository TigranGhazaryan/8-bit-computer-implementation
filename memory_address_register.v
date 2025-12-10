//`include "1bit_register.v"

module memory_address_register #(parameter RAM_ADDRESS_BITS = 4) (address, load, outctrl, clk, Q, Qout);

    input [(RAM_ADDRESS_BITS - 1) :0] address;
    input load, outctrl, clk;
    output [(RAM_ADDRESS_BITS - 1) : 0] Q, Qout;

    // create a memory address register from 4 1bit registers
    // the load signal controls input loading or keeping the content
    // clk is clock
    // Q and Qout are the output and output invert of the flip flops
    genvar i;
    generate
        for(i = 0; i < RAM_ADDRESS_BITS; i = i + 1) begin : register_array
            register r(address[i], load, outctrl, clk, Q[i], Qout[i]);

        end
        endgenerate

endmodule