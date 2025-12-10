//`include "SRlatch.v"

module master_slave_JK_flipflop(J, K, clk, RESETn, Q, Q_bar);

input J, K, clk, RESETn;
output Q, Q_bar;

wire J1;
wire K1;
wire masterSet;
wire masterReset;


// J, clk and Q_bar input AND-ed for master J1 -> SR_latch Set
and(J1, J, clk, Q_bar);

// K, clk and Q input AND-ed for master SR_latch Reset
and(K1, K, clk, Q);

assign masterSet = !RESETn ? 0 : J1;    // Upon reset force masterSet = 0
assign masterReset = !RESETn ? 1 : K1;  // Upon reset force masterReset = 1


// clk inverted
wire clk_invert;
//assign clk_invert = ~clk;
not(clk_invert, clk);

// masterQ and masterQ_bar are the outputs of the master SR_latch
wire masterQ;
wire masterQ_bar;

 
SRlatch master(masterSet, masterReset, masterQ, masterQ_bar);

// masterQ AND-ed with inverted clk is the Set input of the slave SR_latch 
wire slaveSet;
assign slaveSet = masterQ & clk_invert;

// masterQ_bar AND-ed with inverted clk is the Reset input of the slave SR_latch
wire slaveReset;
assign slaveReset = masterQ_bar & clk_invert;


// Slave latch gives us the final Q and Q_bar outputs
SRlatch slave(slaveSet, slaveReset, Q, Q_bar);

endmodule 