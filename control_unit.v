/*
OPCODES

Load from memory address to A reg              LDA ADDR = 0001 ADDR    E.G. LDA 14 = 0001 1110
Add from memory address to A reg               ADD ADDR = 0010 ADDR    E.G. ADD 15 = 0010 1111 
Output to the Output reg                       OUT = 1110 xxxx         E.G. OUT = 1110 0000                                         
*/

//`include "program_counter.v"
`include "eeprom.v"

module ControlUnit #(parameter INPUT_ADDR = 10, OUTPUT_ADDR = 1024, MICROCODE_SIZE = 24)
                    (clk, FLAGS_Register_out, IR_out, eeprom_in, eeprom_out, 
                                  RESET_counter, microcode, control_signals);

input clk;
input[1:0] FLAGS_Register_out;
input[3:0] IR_out;
input eeprom_in, eeprom_out, RESET_counter;
input[(MICROCODE_SIZE - 1) : 0] microcode;          // microcode initialization (control signals in)
output[(MICROCODE_SIZE - 1) : 0] control_signals;   // microcode out


wire[3:0] counter_out;
// (JMP, CO, CI, clk, CE, RESETn, out)
program_counter_module #(4) counterCU(4'b0000, RESET_counter, 1'b0, clk, 1'b1, 1'b0, RESET_counter, counter_out);


// Take the IR_out and the CU counter, and add them together to make an address for the eeprom
wire[(INPUT_ADDR - 1) : 0] address;
assign address[3:0] = counter_out[3:0];
assign address[7:4] = IR_out;
assign address[9:8] = FLAGS_Register_out;

wire[7:0] eeprom1Q_out;
wire[7:0] eeprom2Q_out;
wire[7:0] eeprom3Q_out;
wire[7:0] eeprom1BUS_out;
wire[7:0] eeprom2BUS_out;
wire[7:0] eeprom3BUS_out;


eeprom_module #(INPUT_ADDR, OUTPUT_ADDR) EEPROM1(microcode[7:0], eeprom_in, address, eeprom_out, clk, eeprom1Q_out, eeprom1BUS_out);
eeprom_module #(INPUT_ADDR, OUTPUT_ADDR) EEPROM2(microcode[15:8], eeprom_in, address, eeprom_out, clk, eeprom2Q_out, eeprom2BUS_out);
eeprom_module #(INPUT_ADDR, OUTPUT_ADDR) EEPROM3(microcode[23:16], eeprom_in, address, eeprom_out, clk, eeprom3Q_out, eeprom3BUS_out);


assign control_signals[7:0] = eeprom1BUS_out;
assign control_signals[15:8] = eeprom2BUS_out;
assign control_signals[23:16] = eeprom3BUS_out;


endmodule