
module address_decoder #(parameter INPUT_ADDR = 4, OUTPUT_ADDR = 16) (ad_in, enable, ad_out);
    input [(INPUT_ADDR - 1) : 0] ad_in;
    input enable;
    output reg [(OUTPUT_ADDR - 1) : 0] ad_out;

    integer i;

    always @* begin
        // Initialize all outputs to 0
        ad_out = {OUTPUT_ADDR{1'b0}};
        
        // Set the corresponding ad_out bit based on ad_in and enable
        if (enable) begin
            for (i = 0; i < OUTPUT_ADDR; i = i + 1) begin
                if (ad_in == i[(INPUT_ADDR - 1 ) : 0]) begin
                    ad_out[i] = 1;
                end
            end
        end
    end
endmodule
