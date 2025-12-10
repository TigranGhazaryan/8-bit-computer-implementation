/*module bus(BUS_in, control_signals, clk, PC_BUS_out, RAM_BUS_out, IR_BUS_out, A_BUS_out, ALU_BUS_out, BUS_out);

input [7:0] BUS_in;
input [14:0] control_signals;
input clk;
input[7:0] PC_BUS_out, RAM_BUS_out, IR_BUS_out, A_BUS_out, ALU_BUS_out;
output [7:0] BUS_out;

//control_signals[3] // RO - RAM out
//control_signals[4] // IO - instruction register out
//control_signals[7] // AO - A register out
//control_signals[8] // EO - ALU out
//control_signals[13] // CO - program counter out

wire [7:0] BUS_select;
assign BUS_select =     (control_signals[3]) ? RAM_BUS_out : 
                        (control_signals[4]) ? IR_BUS_out :
                        (control_signals[7]) ? A_BUS_out :
                        (control_signals[8]) ? ALU_BUS_out :
                        (control_signals[9]) ? PC_BUS_out : BUS_in;

wire [4:0] active_signals = {control_signals[3], control_signals[4], control_signals[7], control_signals[8], control_signals[13]};
always @(active_signals) begin
    if (active_signals > 1) $display("Error: Multiple bus drivers active!");
end

assign BUS_out = BUS_in;


endmodule*/

module bus (BUS_in, control_signal, clk, data, BUS_out);
input [7:0] BUS_in, data;
input control_signal, clk;
output [7:0] BUS_out;

assign BUS_out = control_signal ? data : BUS_in;

endmodule