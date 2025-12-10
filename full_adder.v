`include "half_adder.v"

module full_adder(a, b, carry_in, fa_sum, fa_carry_out);
    input a,b,carry_in;
    wire ha1_carry_out;
    wire ha1_sum;
    wire ha2_carry_out;
    wire ha2_sum;

    output fa_sum,fa_carry_out;
    half_adder h1(a,b, ha1_carry_out,ha1_sum);
    half_adder h2(ha1_sum, carry_in, ha2_carry_out, ha2_sum);
    assign fa_carry_out = ha1_carry_out | ha2_carry_out;
    assign fa_sum = ha2_sum;

endmodule