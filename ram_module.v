`include "ram16byte.v"
`include "address_decoder.v"

// inputs: data, address, control signal (Ram in, or Ram out)
// outputs: data
module ram_module #(parameter RAM_INPUT_ADDR = 4,  RAM_SIZE = 16) 
                   (data, ram_in, address, ram_out, clk, Qram, Qramout);

input [7:0] data;
input ram_in, ram_out;
input clk;
input [(RAM_INPUT_ADDR - 1) : 0] address;
output [7:0] Qram, Qramout;

wire [(RAM_SIZE - 1) : 0] address_out;
wire enable = 1;
address_decoder #(RAM_INPUT_ADDR, RAM_SIZE) add_decode(address, enable, address_out);
ram16byte #(RAM_SIZE) RAM(data, ram_in, address_out, ram_out, clk, Qram, Qramout);


endmodule