`include "full_adder.v"

module fulladd8(a, b, carry_in, fa_sum, fa8_carry_out);
    input [7:0] a,b;
    input carry_in;
    output [7:0] fa_sum;
    output fa8_carry_out;


    wire [9:0] fa_cout_list;
    assign fa_cout_list[0] = carry_in;

    // create 8 full adders and initialize them
    genvar i;
    generate 
        for(i = 0; i < 8; i = i + 1) begin : full_adder_array
            full_adder fa_inst(a[i], b[i], fa_cout_list[i], fa_sum[i], fa_cout_list[i+1]); 
        end
    endgenerate
    
    assign fa8_carry_out = fa_cout_list[8];

endmodule