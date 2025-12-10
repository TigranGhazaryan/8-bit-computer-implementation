`include "register8bit.v"

module ram16byte #(parameter RAM_SIZE = 16) (data, ram_in, address, ram_out, clk, Qram, Qramout);

// data input
input [7:0] data;

// address is the output control (selects the RAM cells)
input [(RAM_SIZE - 1) : 0] address;

// ram_in is the load signal
input ram_in;

// clk is clock
input clk;

// ram_out is a control out signal that helps us decide to output or not
input ram_out;

// Qram, Qramout are the standard Flip FLop outputs for a given 8bit cell
output [7:0] Qram, Qramout;


// Qram_array is the output array for all the RAM_SIZE bytes or Ram cells (each 8bit long)
wire [7:0] Qram_array [(RAM_SIZE - 1) : 0];
// Qramout_array is the output array (similarly) but controlled by the ram_out signal
wire [7:0] Qramout_array [(RAM_SIZE - 1) : 0];


wire conditional_out;



// create a RAM_SIZE byte RAM 
genvar i;
generate 
    for(i = 0; i < RAM_SIZE; i = i + 1) begin: ram_array
        // checks for ram_in signal and allows a load into that address only
        wire conditional_load = address[i] & ram_in;
        register8bit r(data, conditional_load, address[i], clk, Qram_array[i], Qramout_array[i]);

    end
endgenerate


// select output Qram and Qramout after the initialization of the data
reg [7:0] Qram_selected;
reg [7:0] Qramout_selected;


integer j;
// Use procedural block to assign Qram and Qramout based on address and ram_in signal
always @* begin
    Qram_selected = 8'b0;      // Default value
    Qramout_selected = 8'b0;   // Default value
    for (j = 0; j < RAM_SIZE; j = j + 1) begin
        if (address[j]) begin
            Qram_selected = Qram_array[j];
            if (ram_out) 
            Qramout_selected = Qramout_array[j];
        end
    end
end

assign Qram = Qram_selected;
assign Qramout = Qramout_selected;


endmodule