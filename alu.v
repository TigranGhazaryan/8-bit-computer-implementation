`include "fulladd8.v"

module alu(regA, regB, clk, sub, out_enable, carry_out, alu_out, bus_out);
    input [7:0] regA, regB;
    input clk, sub, out_enable;
    output carry_out;
    output [7:0] alu_out, bus_out;

    // 1's complement for regB
    wire [7:0] regB_compliment;
    genvar i;
    for(i = 0; i < 8; i = i + 1) begin
        xor(regB_compliment[i], regB[i], sub); 
    end
    
    // fulladd8 gets sub as input for carry_in (2's complement)
    fulladd8 alu(regA,regB_compliment, sub, alu_out, carry_out);

    for(i = 0; i < 8; i = i + 1) begin
        bufif1(bus_out[i], alu_out[i], out_enable);
    end
    
endmodule