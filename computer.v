`include "ram_module.v"
`include "memory_address_register.v"
`include "program_counter.v"
`include "alu.v"
`include "bus.v"
`include "control_unit.v"

module computer #(parameter RAM_ADDRESS_BITS = 8, RAM_SIZE = 256, MICROCODE_SIZE = 24,
                            EEPROM_ADDRESS_BITS = 10, EEPROM_SIZE = 1024)
                 (GLOBAL_BUS, microcode, IRBUSsignal, FLAGS_BUS_SIGNAL, eeprom_in, eeprom_out,
                 ram_in, mar_in, RESET_counter, RESETn, clk, out);


input [7:0] GLOBAL_BUS; // RAM code and EEPROM microcode initialization happens throug this
input clk;
input eeprom_in, eeprom_out, ram_in, mar_in, RESETn, RESET_counter, IRBUSsignal, FLAGS_BUS_SIGNAL;
input [MICROCODE_SIZE - 1 : 0] microcode;
wire [MICROCODE_SIZE - 1 : 0] control_signals;
output [7:0] out;
wire [7:0] BUS_out [7:0]; // Array of 8 BUS elements, each 8 bits wide
assign BUS_out[0] = GLOBAL_BUS;

// this controls Bus[i] Signals (one at a time can be outputed here)
reg [31:0] i;
always @(*) begin
    case ({control_signals[13], control_signals[3], control_signals[18],
           AO, BO, XO, control_signals[8]})
        7'b1000000: i = 1;  // Program Counter out (CO)
        7'b0100000: i = 2;  // RAM out (RO)
        7'b0010000: i = 3;  // Instruction Register Address out (IOA)
        7'b0001000: i = 4;  // A Register out (AO)
        7'b0000100: i = 5;  // B Register out (BO)
        7'b0000010: i = 6;  // X Register out (XO)
        7'b0000001: i = 7;  // ALU out (EO)
        default: i = 0;   // GLOBAL BUS out

    endcase
end


wire HLT;                       // ENDS the program
assign HLT = control_signals[0];





///////////////////////////////////////////// PROGRAM COUNTER //////////////////////////////////

wire CE; // Program Counter enable (increment) signal   
assign CE = control_signals[12];
wire DE; // Program Decrement signal
assign DE = 1'b0;
wire CO; // Program Counter out signal
assign CO = control_signals[13];
wire J; // Program Counter in signal
assign J = control_signals[14];    
//input RESETn; 

wire[(RAM_ADDRESS_BITS - 1) : 0] PC_out;
//program_counter_module #(RAM_ADDRESS_BITS)PC (BUS_out[i][(RAM_ADDRESS_BITS - 1) : 0], CO, J, clk, CE, DE, RESETn, PC_out);
program_counter_module #(RAM_ADDRESS_BITS)PC (BUS_out[i], CO, J, clk, CE, DE, RESETn, PC_out);
wire[7:0] PC_BUS_out;
//assign PC_BUS_out = (RAM_ADDRESS_BITS == 8) ? PC_out : {{(8 - RAM_ADDRESS_BITS){1'b0}}, PC_out};
assign PC_BUS_out = PC_out;
bus BUS1(GLOBAL_BUS, CO, clk, PC_BUS_out, BUS_out[1]); 






//////////////////////////////////////// INSTRUCTION REGISTER  /////////////////////////////

wire IO; // Instruction Register out/outctrl signal
assign IO = control_signals[4];
wire II; // Instruction Register write/load signal
assign II = (IRBUSsignal) ? IRBUSsignal : control_signals[5];

//wire [7:0] IR_data;
//assign IR_data = RAM_out[3:0];
wire [7:0] IR_OPCODE_out;
wire [7:0] IR_OPCODE_BUS_out;

register8bit InstructionRegisterOPCODE (BUS_out[i], II, IO, clk, IR_OPCODE_out, IR_OPCODE_BUS_out);


wire IOM; // Instruction Register Address out/outctrl signal
assign IOM = control_signals[16];
wire IIM; // Instruction Register write/load signal
assign IIM = (IRBUSsignal) ? IRBUSsignal : control_signals[17];
wire [7:0] IR_MODRM_out;
wire [7:0] IR_MODRM_BUS_out;

register8bit IRMODRM (BUS_out[i], IIM, IOM, clk, IR_MODRM_out, IR_MODRM_BUS_out);

wire [1:0] MOD; 
assign MOD = IR_MODRM_out[7:6];
wire [2:0] REG;
assign REG = IR_MODRM_out[5:3];
wire [2:0] RM;
assign RM = IR_MODRM_out[2:0];



wire IOA; // Instruction Register Address out/outctrl signal
assign IOA = control_signals[18];
wire IIA; // Instruction Register write/load signal
assign IIA = (IRBUSsignal) ? IRBUSsignal : control_signals[19];
wire [7:0] IR_DATA_out;
wire [7:0] IR_DATA_BUS_out;

register8bit InstructionRegisterDATA (BUS_out[i], IIA, IOA, clk, IR_DATA_out, IR_DATA_BUS_out);
wire [7:0] IR_DATA_BUS_OUT;
assign IR_DATA_BUS_OUT = IR_DATA_BUS_out;
bus BUS3(GLOBAL_BUS, IOA, clk, IR_DATA_BUS_OUT, BUS_out[3]); 
// IR_out enters the CONTROL UNIT and gives signal_controls through code input (added later)



/////////////////////////////////////////////// CONTROL UNIT ///////////////////////////////////

wire eeprom_out_signal;
assign eeprom_out_signal = (~ eeprom_out) ? eeprom_out : 1'b1;   
wire [1:0] FLAGS;
assign FLAGS = FLAGS_BUS_out[1:0] === 2'bxx ? 2'b00 : 
               FLAGS_BUS_out[1:0] === 2'bzz ? 2'b00 :
               FLAGS_BUS_out[1:0] ? FLAGS_BUS_out[1:0] : 2'b00;
ControlUnit #(EEPROM_ADDRESS_BITS, EEPROM_SIZE, MICROCODE_SIZE) CU(clk, FLAGS, IR_OPCODE_out[7:4], 
              eeprom_in, eeprom_out_signal, RESET_counter, microcode, control_signals);





////////////////////////////////////////// MEMORY ADDRESS REGISTER //////////////////////////////////

wire MI;                        // Memory address register write/load signal
assign MI = mar_in ? 1'b1 : control_signals[1];

wire MO;                        // Memory address register out/outctrl signal
assign MO = 1'b0;

wire [(RAM_ADDRESS_BITS - 1) : 0] RAM_address;         // Memory address register output to RAM
wire [(RAM_ADDRESS_BITS - 1) : 0] BUS_address_out;     // Memory address register output to BUS

memory_address_register #(RAM_ADDRESS_BITS) MAR (BUS_out[i][(RAM_ADDRESS_BITS - 1) : 0], 
                             MI, MO, clk, RAM_address, BUS_address_out);




/////////////////////////////////////////// RAM ////////////////////////////////////////////////

wire RI; // RAM write signal
assign RI = ram_in ? ram_in : ((MOD == 2'b11 | MOD == 2'b01 | MOD == 2'b00) & (CE == 1'b0)) ? 1'b0 : control_signals[2];
wire RO; // RAM out signal
assign RO = ((MOD == 2'b11 | MOD == 2'b10 | MOD == 2'b00) & (CE == 1'b0)) ? 1'b0 : control_signals[3];
//assign RO = control_signals[3];
wire[7:0] RAM_out;
wire[7:0] RAM_BUS_out;

ram_module #(RAM_ADDRESS_BITS, RAM_SIZE) RAM(BUS_out[i], RI, RAM_address, RO, clk, RAM_out, RAM_BUS_out);
bus BUS2(GLOBAL_BUS, RO, clk, RAM_BUS_out, BUS_out[2]); 




wire RegI = control_signals[6];
wire RegO = control_signals[7];

////////////////////////////////////////////// REGISTER A /////////////////////////////////////

wire AI; // Register A write/load signal
assign AI = ((MOD == 2'b00) & (RM == 3'b001 & RegO == 1'b0)) ? RegI : 
            ((MOD == 2'b01) & (RM == 3'b001 & RegO == 1'b0)) ? RegI : 
            ((MOD == 2'b11) & (RM == 3'b001 & (RegO == 1'b1  | IOA == 1'b1 | EO == 1'b1))) ? RegI : 1'b0;
             
wire AO; // Register A out/outctrl signal
assign AO = (MOD == 2'b01) & (REG == 3'b001) ? RegO : 
            (MOD == 2'b10) & ((RM == 3'b001 & RegI == 1'b1) | (REG == 3'b001 & RegI == 1'b0)) ? RegO : 
            ((MOD == 2'b11) & (REG == 3'b001)) ? RegO : 1'b0;


wire [7:0] A_out;
wire [7:0] A_BUS_out;
register8bit RegisterA (BUS_out[i], AI, AO, clk, A_out, A_BUS_out);

bus BUS4001(GLOBAL_BUS, AO, clk, A_BUS_out, BUS_out[4]); 



/////////////////////////////////////////////// REGISTER B ////////////////////////////////////////

wire BI; // Register B write/load signal
assign BI = ((MOD == 2'b00) & (RM == 3'b001 & RegO == 1'b0)) ? RegI : 
            ((MOD == 2'b01) & (RM == 3'b010 & RegO == 1'b0)) ? RegI : 
            ((MOD == 2'b11) & (RM == 3'b010 & (RegO == 1'b1 | IOA == 1'b1 | EO == 1'b1))) ? RegI : 1'b0;
wire BO; // Register B out/outctrl signal
assign BO = (MOD == 2'b01) & (REG == 3'b010) ? RegO : 
            (MOD == 2'b10) & ((RM == 3'b010 & RegI == 1'b1) | (REG == 3'b010 & RegI == 1'b0)) ? RegO : 
            ((MOD == 2'b11) & (REG == 3'b010)) ? RegO : 1'b0;

wire [7:0] B_out;
wire [7:0] B_BUS_out;
register8bit RegisterB (BUS_out[i], BI, BO, clk, B_out, B_BUS_out);
bus BUS4010(GLOBAL_BUS, BO, clk, B_BUS_out, BUS_out[5]); 


/////////////////////////////////////////////// REGISTER X ////////////////////////////////////////

wire XI; // Register X write/load signal
assign XI = control_signals[20];
wire XO; // Register X out/outctrl signal
assign XO = 1'b0;
wire [7:0] X_out;
wire [7:0] X_BUS_out;
register8bit RegisterX (BUS_out[i], XI, XO, clk, X_out, X_BUS_out);
//bus BUS4011(GLOBAL_BUS, XO, clk, X_BUS_out, BUS_out[6]); 



//////////////////////////////////////////////// ALU /////////////////////////////////////////////
wire[7:0] Operand1;
assign Operand1 = (MOD == 2'b11) & (REG == 3'b001) ? A_out : 
                  (REG == 3'b010) ? B_out : IR_DATA_out;

wire[7:0] Operand2;
assign Operand2 = (MOD == 2'b11) & (RM == 3'b001) ? A_out : 
                  (RM == 3'b010) ? B_out : IR_DATA_out;

wire EO; // ALU Sum out signal
assign EO = control_signals[8];
wire SU; // ALU Subtract signal
assign SU = control_signals[9];
wire CY; // ALU Carry bit output
wire [7:0] ALU_out;
wire [7:0] ALU_BUS_out;
alu ALU(Operand1, Operand2, clk, SU, EO, CY, ALU_out, ALU_BUS_out);

bus BUS5(GLOBAL_BUS, EO, clk, ALU_BUS_out, BUS_out[7]); 



/////////////////////////////////////////////// FLAGS REGISTER ////////////////////////////////////////

wire FI; // FLAGS Register write/load signal
assign FI = FLAGS_BUS_SIGNAL ? 1'b1 : control_signals[15];
wire FO; // FLAGS Register out/outctrl signal
assign FO = 1'b1;

wire[7:0] FLAGS_IN;
// carry bit CF
assign FLAGS_IN[0] = FLAGS_BUS_SIGNAL ? GLOBAL_BUS[0] : CY; 
// zero bit  ZF
// Takes ALU output and Ands each bit
assign FLAGS_IN[1] = FLAGS_BUS_SIGNAL ? GLOBAL_BUS[1] :
                   ~(BUS_out[5][0] | BUS_out[5][1] | BUS_out[5][2] |
                     BUS_out[5][3] | BUS_out[5][4] | BUS_out[5][5] |
                     BUS_out[5][6] | BUS_out[5][7]);

wire [7:0] FLAGS_out;
wire [7:0] FLAGS_BUS_out;

register8bit FLAGSRegister (FLAGS_IN, FI, FO, clk, FLAGS_out, FLAGS_BUS_out);



//////////////////////////////////////////////////// STACK ///////////////////////////////////////////
/*
/////////////////////////////////////////////// STACK POINTER ////////////////////////////////////////

wire SPI; // STACK POINTER Increment signal   
assign SPI = control_signals[18];
wire SPD; // STACK POINTER Decrement signal
assign SPD = control_signals[19];
wire SPO; // STACK POINTER out signal
assign SPO = control_signals[20];
wire SPJ; // STACK POINTER in (Jump) signal
assign SPJ = control_signals[21];    
//input RESETn; 

wire[(RAM_ADDRESS_BITS - 1) : 0] SP_out;
program_counter_module #(RAM_ADDRESS_BITS) STACK_POINTER (BUS_out[i], SPO, SPJ, clk, SPI, SPD, RESETn, SP_out);
wire[7:0] SP_BUS_out;
assign SP_BUS_out = SP_out;
bus BUS6(GLOBAL_BUS, SPO, clk, SP_BUS_out, BUS_out[6]); 



///////////////////////////////////////////////////// BASE POINTER ///////////////////////////////////

wire BPI; // BASE POINTER write/load signal
assign BPI = control_signals[22];
wire BPO; // BASE POINTER out/outctrl signal
assign BPO = control_signals[23];

wire [7:0] BP_out;
wire [7:0] BP_BUS_out;
register8bit BASE_POINTER (BUS_out[i], BPI, BPO, clk, BP_out, BP_BUS_out);

bus BUS7(GLOBAL_BUS, BPO, clk, BP_BUS_out, BUS_out[7]); 
*/
//////////////////////////////////////////////////// OUTPUT REGISTER /////////////////////////////////

wire OI; // Output Register write/load signal
assign OI = control_signals[11];
wire [7:0] OutReg_out;
wire [7:0] OutReg_BUS_out;
wire OutReg_outctrl; 
assign OutReg_outctrl = 1'b0;

register8bit OutputRegister (BUS_out[i], OI, OutReg_outctrl, clk, OutReg_out, OutReg_BUS_out);
assign out = OutReg_out;
endmodule