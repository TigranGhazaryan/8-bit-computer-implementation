`include "master_slave_JK_flipflop.v"

module binary_counter (J, K, clk, RESETn, Q);
input J, K;
input clk, RESETn;
output Q;
wire Q_out;

master_slave_JK_flipflop msJK(J, K, clk, RESETn, Q, Q_bar);

endmodule

module program_counter #(parameter SIZE = 8)(JMP, CO, CI, clk, CE, DE, RESETn, out);
input CI;           // Control In: CI
input[(SIZE - 1) : 0] JMP;     // counter in address: JUMP 
input CO;           // control out buffer signal: CO
input clk;          // clock
input CE;           // counter enable: CE
input DE;           // decrement;
input RESETn;       // Reset signal (active low)
output[(SIZE - 1) : 0] out;     // counter output: CO

wire [(SIZE - 1) : 0] J;
assign J = ~(CI ^ CE) ? {SIZE{1'b0}} : JMP;
wire [(SIZE - 1) : 0] K;
assign K = {SIZE{1'b0}};
wire [(SIZE - 1) : 0] Q;

// IF CI = 0 & CE = 0, OR CI = 1 & CE = 1, dont do anything, else load CE value
binary_counter b0(J[0] | ((CI == CE) ? 1'b0 : CE), 
                  K[0] | ((CI == CE) ? 1'b0 : CE), clk, 
                  J[0] | ((CI == CE) ?  1'b1 & RESETn : ~CI & RESETn) , Q[0]);

genvar i;
generate 
    for(i = 1; i < SIZE; i = i + 1) begin : binary_counter_array
        binary_counter b(J[i] | ((CI == CE) ? 1'b0 : CE), 
                         K[i] | ((CI == CE) ? 1'b0 : CE),    
                         (~CI  || (CI == CE)) ? Q[i-1] : clk,
                         J[i] | ((CI == CE) ?  1'b1 & RESETn : ~CI & RESETn), Q[i]);
        
        bufif1(out[i-1], (DE ? ~Q[i-1] : Q[i-1]), CO);

    end
endgenerate

    bufif1(out[SIZE-1], (DE ? ~Q[SIZE-1] : Q[SIZE-1]), CO);

endmodule

module program_counter_module #(parameter SIZE = 8)(JMP, CO, CI, clk, CE, DE, RESETn, out);
input CI;           // Control In: CI
input[(SIZE - 1) : 0] JMP;     // counter in address: JUMP 
input CO;           // control out buffer signal: CO
input clk;          // clock
input CE;           // counter enable: CE
input DE;
input RESETn;       // Reset signal (active low)
output[(SIZE - 1) : 0] out;     // counter output: CO


// Safeguards agains buffered input (z) or undefined input (x)
wire COzx, CIzx, CEzx, DEzx;
wire[(SIZE - 1) : 0] JMPzx;

assign COzx = (CO === 1'bx) ? 1'b0 : (CO === 1'bz) ? 1'b0 : CO ? 1'b1 : 1'b0;
assign CIzx = (CI === 1'bx) ? 1'b0 : (CI === 1'bz) ? 1'b0 : CI ? 1'b1 : 1'b0;
assign CEzx = (CE === 1'bx) ? 1'b0 : (CE === 1'bz) ? 1'b0 : CE ? 1'b1 : 1'b0;
assign DEzx = (DE === 1'bx) ? 1'b0 : (DE === 1'bz) ? 1'b0 : DE ? 1'b1 : 1'b0;
assign JMPzx = (JMP === {SIZE{1'bx}}) ? {SIZE{1'b0}} : (JMP === {SIZE{1'bz}}) ? {SIZE{1'b0}} : JMP;

program_counter #(SIZE) p0(JMPzx, COzx, CIzx, clk, CEzx, DEzx, RESETn, out);

endmodule 


