module control_signals (control_in, control_out);
input [15:0] control_in;
output [15:0] control_out;
wire HLT;    assign HLT = control_in[0];    assign  control_out[0]  = HLT;
wire MI;     assign MI = control_in[1];     assign  control_out[1]  = MI;
wire RI;     assign RI = control_in[2];     assign  control_out[2]  = RI;
wire RO;     assign RO = control_in[3];     assign  control_out[3]  = RO;
wire IO;     assign IO = control_in[4];     assign  control_out[4]  = IO;
wire II;     assign II = control_in[5];     assign  control_out[5]  = II;
wire RegI;   assign RegI = control_in[6];   assign  control_out[6]  = RegI;
wire RegO;   assign RegO = control_in[7];   assign  control_out[7]  = RegO;
wire EO;     assign EO = control_in[8];     assign  control_out[8]  = EO;
wire SU;     assign SU = control_in[9];     assign  control_out[9]  = SU;
wire BI;     assign BI = control_in[10];    assign  control_out[10] = BI;
wire OI;     assign OI = control_in[11];    assign  control_out[11] = OI;
wire CE;     assign CE = control_in[12];    assign  control_out[12] = CE;
wire CO;     assign CO = control_in[13];    assign  control_out[13] = CO;
wire J;      assign J = control_in[14];     assign  control_out[14] = J;
wire FI;     assign FI = control_in[15];    assign  control_out[15] = FI;
wire IOM;    assign IOM = control_in[16];   assign  control_out[16] = IOM;
wire IIM;    assign IIM = control_in[17];   assign  control_out[17] = IIM;
wire IOA;    assign IOA = control_in[18];   assign  control_out[18] = IOA;
wire IIA;    assign IIA = control_in[19];   assign  control_out[19] = IIA;
wire XI;     assign XI = control_in[20];    assign  control_out[20] = XI;
wire SPJ;    assign SPJ = control_in[21];   assign  control_out[21] = SPJ;
wire BPI;    assign BPI = control_in[22];   assign  control_out[22] = BPI;
wire BPO;    assign BPO = control_in[23];   assign  control_out[23] = BPO;

endmodule