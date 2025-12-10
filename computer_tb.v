`include "computer.v"
module computer_tb;
parameter RAM_ADDRESS_BITS = 8, RAM_SIZE = 256, MICROCODE_SIZE = 24,
          EEPROM_ADDRESS_BITS = 10, EEPROM_SIZE = 1024;

reg[7:0] GLOBAL_BUS;
reg[(MICROCODE_SIZE - 1) : 0] MICROCODE;
reg RESETn, RESET_counter, eeprom_in, eeprom_out, ram_in, mar_in,  IRBUSsignal, FLAGS_BUS_SIGNAL;
reg clk;
wire[7:0] out;

computer #(RAM_ADDRESS_BITS, RAM_SIZE, MICROCODE_SIZE,
           EEPROM_ADDRESS_BITS, EEPROM_SIZE) 
           MyPC(GLOBAL_BUS, MICROCODE, IRBUSsignal, FLAGS_BUS_SIGNAL, eeprom_in,
           eeprom_out, ram_in, mar_in, RESET_counter, RESETn, clk, out);


// MICROCODE CONSTANTS FOR EEPROM
localparam [23:0] HlT   = 24'b000000000000000000000001;   // signal for Halting
localparam [23:0] MI    = 24'b000000000000000000000010;   // signal for Memory Address Register in
localparam [23:0] RI    = 24'b000000000000000000000100;   // signal for RAM in
localparam [23:0] RO    = 24'b000000000000000000001000;   // signal for RAM out
localparam [23:0] IO    = 24'b000000000000000000010000;   // signal for Instruction Register out
localparam [23:0] II    = 24'b000000000000000000100000;   // signal for Instruction Register in
localparam [23:0] RegI  = 24'b000000000000000001000000;   // signal for A Register in
localparam [23:0] RegO  = 24'b000000000000000010000000;   // signal for A Register out
localparam [23:0] EO    = 24'b000000000000000100000000;   // signal for ALU out
localparam [23:0] SU    = 24'b000000000000001000000000;   // signal for Subtract in ALU
localparam [23:0] BI    = 24'b000000000000010000000000;   // signal for B Register in
localparam [23:0] OI    = 24'b000000000000100000000000;   // signal for Output Register in
localparam [23:0] CE    = 24'b000000000001000000000000;   // signal for increment in Program Counter
localparam [23:0] CO    = 24'b000000000010000000000000;   // signal for Program Counter out
localparam [23:0] J     = 24'b000000000100000000000000;   // signal for Jump in Program Counter
localparam [23:0] FI    = 24'b000000001000000000000000;   // signal for FLAGS Register in
localparam [23:0] IOM   = 24'b000000010000000000000000;   // signal for Instruction Register DATA out
localparam [23:0] IIM   = 24'b000000100000000000000000;   // signal for Instruction Register DATA in
localparam [23:0] IOA   = 24'b000001000000000000000000;   // signal for MODRM out
localparam [23:0] IIA   = 24'b000010000000000000000000;   // signal for MODRM in
/*localparam [23:0] SPO   = 24'b000100000000000000000000;   // signal for Stack Pointer Out
localparam [23:0] SPJ   = 24'b001000000000000000000000;   // signal for Stack Pointer In (Jump)
localparam [23:0] BPI   = 24'b010000000000000000000000;   // signal for Base Pointer In 
localparam [23:0] BPO   = 24'b100000000000000000000000;   // signal for Base Pointer Out*/

localparam [23:0] XI    = 24'b000100000000000000000000;   
//localparam [23:0] AO    = 24'b001000000000000000000000;   




// OPCODES
localparam [7:0] NOP   = 8'b00000000;           // No Instruction
localparam [7:0] MOV   = 8'b00010000;           // MOV mod reg/rm (r to r, r to m, m to r)
localparam [7:0] ADD   = 8'b00100000;           // Add value from RAM [addr] to A register 
localparam [7:0] SUB   = 8'b00110000;           // Subtract value from RAM [addr] from A register
localparam [7:0] MOVI  = 8'b01000000;           // Load Immideate value into A register        
localparam [7:0] JMP   = 8'b01010000;           // Jump to address
localparam [7:0] JC    = 8'b01100000;           // Jump to address if Carry flag is set
localparam [7:0] JZ    = 8'b01110000;           // Jump to address if Zero flag is set
/*
localparam [7:0]       = 8'b10000000;           //  
localparam [7:0] PUSH   = 8'b10010000;          // Decrements the Stack Pointer, adds Address value on Stack
localparam [7:0] POP    = 8'b10100000;          // Increments the Stack Pointer, removes value from Stack to Address 
localparam [7:0] CALL   = 8'b10110000;          // Pushes Return address (ip / program counter value) on the Stack, 
                                                // Jumps to the function address
                                                // pushes BP on the stack
                                                // move value of SP to BP
                                                // (function convention: pushes local variables on the stack)
localparam [7:0] RET    = 8'b11000000;          // (function convention: pops the local variables of the stack)
                                                // Pops BP of the stack (moves BP value on stack to BP)
                                                //* Pops ip / program counter value (Jump) of the stak
                                                //* Jumps to the Return address on the Stack, Pops it off the stack
                                                // SP is Decremented to its original Value (BP)
localparam [7:0] PUSHA  = 8'b11010000;*/        // Pushes value of A register on the Stack
localparam [7:0] OUT    = 8'b11100000;
localparam [7:0] HLT    = 8'b11110000;

localparam [7:0] PADDING = 8'b00000000;
localparam [7:0] NULL    = 8'b00000000;
localparam [7:0] DATA    = 8'b00000000;
localparam [7:0] ADDRESS = 8'b00000000;


// MODS
localparam [7:0] MOD_REG_to_MEM_OFFSET = 8'b00000000;
localparam [7:0] MOD_MEM_to_REG        = 8'b01000000;
localparam [7:0] MOD_REG_to_MEM        = 8'b10000000;
localparam [7:0] MOD_REG_to_REG        = 8'b11000000;
localparam [7:0] MOD_IMM_to_REG        = 8'b11000000;


// REG
localparam [7:0] RegA_out  = 8'b00001000;
localparam [7:0] RegB_out  = 8'b00010000;
localparam [7:0] RegX_out  = 8'b00011000;
localparam [7:0] BP_out    = 8'b00110000;

// R/M ([REG])
localparam [7:0] RegA_in   = 8'b00000001;
localparam [7:0] RegB_in   = 8'b00000010;
localparam [7:0] RegX_in   = 8'b00000011;
localparam [7:0] BP_in     = 8'b00000111;


// INITIALIZING RAM WITH CODE AND DATA
// MOVI d15, A
// MOV  A, B
// MOVI d20, A
// MOV  B, [A]
// MOVI d0, B
// MOV  [A], B

// code and data sections
localparam [7:0] code0     = MOVI;    
localparam [7:0] code1     = MOD_IMM_to_REG | RegB_in;          
localparam [7:0] code2     = DATA | 8'd15; 
localparam [7:0] code3     = MOV;
localparam [7:0] code4     = MOD_REG_to_REG | RegB_out | RegA_in;  
localparam [7:0] code5     = NULL;         
localparam [7:0] code6     = MOVI; 
localparam [7:0] code7     = MOD_IMM_to_REG | RegB_in;            
localparam [7:0] code8     = ADDRESS | 8'd30;
localparam [7:0] code9     = MOV;                   
localparam [7:0] code10    = MOD_REG_to_MEM | RegA_out | RegB_in;
localparam [7:0] code11    = NULL;
localparam [7:0] code12    = MOVI;
localparam [7:0] code13    = MOD_IMM_to_REG | RegA_in; 
localparam [7:0] code14    = DATA | 8'd55;
localparam [7:0] code15    = MOV;
localparam [7:0] code16    = MOD_MEM_to_REG | RegB_out | RegA_in;
localparam [7:0] code17    = NULL;
localparam [7:0] code18    = ADD;
localparam [7:0] code19    = MOD_REG_to_REG | RegB_in;
localparam [7:0] code20    = DATA | 8'd42;
localparam [7:0] code21    = OUT;
localparam [7:0] code22    = MOD_REG_to_REG | RegB_out;
localparam [7:0] code23    = NULL;







/////////////////////////////////////// START PROCESS ////////////////////////////////////////////

always begin
        clk = 0; #5;
        clk = 1; #5;
        
end
initial begin eeprom_out = 1'b0; end

task Reset;
    begin
    GLOBAL_BUS = 8'b01000000;
    MICROCODE = {MICROCODE_SIZE{1'b0}};
    IRBUSsignal = 1'b1;
    FLAGS_BUS_SIGNAL = 1'b1;
    RESET_counter = 1'b0;
    eeprom_in = 1'b0;
    eeprom_out = 1'b0;
    ram_in = 1'b0;
    mar_in = 1'b0;
    RESETn = 1'b0;
    #20;
    end
endtask

task Set;
    begin
    GLOBAL_BUS = 8'b00000000;
    MICROCODE = {MICROCODE_SIZE{1'b0}};
    IRBUSsignal = 1'b0;
    FLAGS_BUS_SIGNAL = 1'b0;
    RESET_counter = 1'b1;
    eeprom_in = 1'b0;
    eeprom_out = 1'b1;
    ram_in = 1'b0;
    mar_in = 1'b0;
    RESETn = 1'b1;
    #20;
    end
endtask

task fetch_cycle;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        // FETCH INSTRUCTION
        // CO MI
        GLOBAL_BUS = global_bus_value;
        MICROCODE =  CO | MI;
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask

task decode_cycle1;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        // DECODE INSTRUCTION
        // RO II CE
        GLOBAL_BUS = global_bus_value;
        MICROCODE = RO | II | CE;
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask


task decode_cycle2;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        // DECODE INSTRUCTION
        // RO IIM CE
        GLOBAL_BUS = global_bus_value;
        MICROCODE = RO | IIM | CE;
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask

task decode_cycle3;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        // DECODE INSTRUCTION
        // RO IIA CE
        GLOBAL_BUS = global_bus_value;
        MICROCODE = RO | IIA | CE;
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask

task nop;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin

        // 0-out the rest of the microcode
        GLOBAL_BUS = global_bus_value;
        MICROCODE = {MICROCODE_SIZE{1'b0}};
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask


task microcode;
    input [7:0] eeprom_address;       // Value for GLOBAL_BUS
    input [23:0] micro_code;         // Value for microcode
    begin
        // DECODE INSTRUCTION
        // RO II CE
        GLOBAL_BUS = eeprom_address;
        MICROCODE = micro_code;
        IRBUSsignal = 1'b1;
        FLAGS_BUS_SIGNAL = 1'b1;
        RESET_counter = 1'b1;
        eeprom_in = 1'b1;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b0;
        RESETn = 1'b1;

        // Simulate the delay
        #10;  // Wait 10 time units
    end
endtask


task MAR;
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        
        GLOBAL_BUS = global_bus_value;
        MICROCODE = {MICROCODE_SIZE{1'b0}};
        IRBUSsignal = 1'b0;
        FLAGS_BUS_SIGNAL = 1'b0;
        RESET_counter = 1'b0;
        eeprom_in = 1'b0;
        eeprom_out = 1'b0;
        ram_in = 1'b0;
        mar_in = 1'b1;
        RESETn = 1'b1;
        #10;
    end
endtask

task RAM; 
    input [7:0] global_bus_value;       // Value for GLOBAL_BUS     
    begin
        // DECODE INSTRUCTION
        // RO II CE
        GLOBAL_BUS = global_bus_value;
        MICROCODE = {MICROCODE_SIZE{1'b0}};
        IRBUSsignal = 1'b0;
        FLAGS_BUS_SIGNAL = 1'b0;
        RESET_counter = 1'b0;
        eeprom_in = 1'b0;
        eeprom_out = 1'b0;
        ram_in = 1'b1;
        mar_in = 1'b0;
        RESETn = 1'b1;
        #10;
    end
endtask

reg[7:0] CF, ZF;
reg[8:0] i;
initial
    begin
        $dumpfile("computer.vcd");
        $dumpvars(0, computer_tb);
        #10
       // Start
       // initialize
       Reset();
       
       for(i = 0; i < 4; i = i + 1) begin
            CF = i[7:0];      // assign LSB of i
            ZF = i[7:0];      // assign second LSB of i
       
            // SETUP EEPROM

            // NOP       : OPCODE 0000 0000
            fetch_cycle(NOP | CF | ZF);    decode_cycle1(NOP | CF | ZF);
            fetch_cycle(NOP | CF | ZF);    decode_cycle2(NOP | CF | ZF);
            fetch_cycle(NOP | CF | ZF);    decode_cycle3(NOP | CF | ZF);         
            nop(NOP | CF | ZF); #90;

            // MOV [addr] : OPCODE 0001 xxxx Address
            fetch_cycle(MOV | CF | ZF);   decode_cycle1(MOV | CF | ZF);
            fetch_cycle(MOV | CF | ZF);   decode_cycle2(MOV | CF | ZF);
            fetch_cycle(MOV | CF | ZF);   decode_cycle3(MOV | CF | ZF);  
            microcode(MOV | CF | ZF, IOA); 
            microcode(ADD | CF | ZF, EO | RegI | FI);
            microcode(MOV | CF | ZF, MI | RegO | RegI);
            microcode(MOV | CF | ZF, RO | RegI);
            microcode(MOV | CF | ZF, RI | RegO);
            nop(MOV | CF | ZF); #40;    

            // ADD [addr] : OPCODE 0010 xxxx Address
            fetch_cycle(ADD | CF | ZF);   decode_cycle1(ADD | CF | ZF);
            fetch_cycle(ADD | CF | ZF);   decode_cycle2(ADD | CF | ZF);
            fetch_cycle(ADD | CF | ZF);   decode_cycle3(ADD | CF | ZF);  
            microcode(ADD | CF | ZF, EO | RegI | FI);
            nop(ADD | CF | ZF); #80;

            // SUB [addr] : OPCODE 0011 xxxx Address
            fetch_cycle(SUB | CF | ZF);   decode_cycle1(SUB | CF | ZF);
            fetch_cycle(SUB | CF | ZF);   decode_cycle2(SUB | CF | ZF);
            fetch_cycle(SUB | CF | ZF);   decode_cycle3(SUB | CF | ZF); 
            microcode(SUB | CF | ZF, SU | EO | RegI | FI); 
            nop(SUB | CF | ZF); #80;

            
            // MOVI : OPCODE 0101 xxxx Immideate value
            fetch_cycle(MOVI | CF | ZF);   decode_cycle1(MOVI | CF | ZF);
            fetch_cycle(MOVI | CF | ZF);   decode_cycle2(MOVI | CF | ZF);
            fetch_cycle(MOVI | CF | ZF);   decode_cycle3(MOVI | CF | ZF); 
            microcode(MOVI | CF | ZF, IOM);
            microcode(MOVI | CF | ZF, IOA | RegI); 
            nop(MOVI | CF | ZF); #70;

            // JMP : OPCODE 0110 xxxx Address
            fetch_cycle(JMP | CF | ZF);   decode_cycle1(JMP | CF | ZF);
            fetch_cycle(JMP | CF | ZF);   decode_cycle2(JMP | CF | ZF);
            fetch_cycle(JMP | CF | ZF);   decode_cycle3(JMP | CF | ZF); 
            nop(JMP | CF | ZF); #60;
            microcode(JMP | CF | ZF, IOA | J);
            microcode(JMP | CF | ZF, IOA);
            nop(JMP | CF | ZF);
            
            // JC : OPCODE 0111 xxxx Address
            fetch_cycle(JC | CF | ZF);   decode_cycle1(JC | CF | ZF);
            fetch_cycle(JC | CF | ZF);   decode_cycle2(JC | CF | ZF); 
            fetch_cycle(JC | CF | ZF);   decode_cycle3(JC | CF | ZF);
            if(CF[0]) begin 
                nop(JC | CF | ZF); #60;
                microcode(JC | CF | ZF, IOA | J);
                microcode(JC | CF | ZF, IOA);
                nop(JC | CF | ZF);
            end else begin 
                nop(JC | CF | ZF); #90;
            end

            // JZ : OPCODE 1000 xxxx Address
            fetch_cycle(JZ | CF | ZF);   decode_cycle1(JZ | CF | ZF);
            fetch_cycle(JZ | CF | ZF);   decode_cycle2(JZ | CF | ZF); 
            fetch_cycle(JZ | CF | ZF);   decode_cycle3(JZ | CF | ZF);
            if(ZF[1]) begin 
                nop(JZ | CF | ZF); #60;
                microcode(JZ | CF | ZF, IOA | J);
                microcode(JZ | CF | ZF, IOA);
                nop(JZ | CF | ZF); 
            end else begin
                nop(JZ | CF | ZF); #90;
            end
            
            // OTHER OPCODES
            fetch_cycle(8'b10010000 | CF | ZF);   decode_cycle1(8'b10010000 | CF | ZF);
            fetch_cycle(8'b10010000 | CF | ZF);   decode_cycle2(8'b10010000 | CF | ZF);
            fetch_cycle(8'b10010000 | CF | ZF);   decode_cycle3(8'b10010000 | CF | ZF);  
            nop(8'b10010000 | CF | ZF); #90;

            fetch_cycle(8'b10100000 | CF | ZF);   decode_cycle1(8'b10100000 | CF | ZF);
            fetch_cycle(8'b10100000 | CF | ZF);   decode_cycle2(8'b10100000 | CF | ZF);
            fetch_cycle(8'b10100000 | CF | ZF);   decode_cycle3(8'b10100000 | CF | ZF);  
            nop(8'b10100000 | CF | ZF); #90;

            fetch_cycle(8'b10110000 | CF | ZF);   decode_cycle1(8'b10110000 | CF | ZF);
            fetch_cycle(8'b10110000 | CF | ZF);   decode_cycle2(8'b10110000 | CF | ZF);
            fetch_cycle(8'b10110000 | CF | ZF);   decode_cycle3(8'b10110000 | CF | ZF);  
            nop(8'b10110000 | CF | ZF); #90;

            fetch_cycle(8'b11000000 | CF | ZF);   decode_cycle1(8'b11000000 | CF | ZF);
            fetch_cycle(8'b11000000 | CF | ZF);   decode_cycle2(8'b11000000 | CF | ZF);
            fetch_cycle(8'b11000000 | CF | ZF);   decode_cycle3(8'b11000000 | CF | ZF);  
            nop(8'b11000000 | CF | ZF); #90;
            
            fetch_cycle(8'b11010000 | CF | ZF);   decode_cycle1(8'b11010000 | CF | ZF);
            fetch_cycle(8'b11010000 | CF | ZF);   decode_cycle2(8'b11010000 | CF | ZF);
            fetch_cycle(8'b11010000 | CF | ZF);   decode_cycle3(8'b11010000 | CF | ZF);  
            nop(8'b11010000 | CF | ZF); #90;
            
            // OUT [addr]  EEPROM addr 1110
            fetch_cycle(OUT | CF | ZF);   decode_cycle1(OUT | CF | ZF);
            fetch_cycle(OUT | CF | ZF);   decode_cycle2(OUT | CF | ZF);
            fetch_cycle(OUT | CF | ZF);   decode_cycle3(OUT | CF | ZF);
            microcode(OUT | CF | ZF, RegO | OI ); 
            nop(OUT | CF | ZF); #80;
            // HLT [addr]  EEPROM addr 1111
            fetch_cycle(HLT | CF | ZF);   decode_cycle1(HLT | CF | ZF);
            fetch_cycle(HLT | CF | ZF);   decode_cycle2(HLT | CF | ZF); 
            fetch_cycle(HLT | CF | ZF);   decode_cycle3(HLT | CF | ZF); 
            microcode(HLT | CF | ZF, HlT);
            nop(HLT | CF | ZF); #80;
        
        end 
        //Reset();
        //Set();
        // SETUP RAM
        MAR(8'd0);
        RAM(code0);
        MAR(8'd1);
        RAM(code1);
        MAR(8'd2);
        RAM(code2);
        MAR(8'd3);
        RAM(code3);
        MAR(8'd4);
        RAM(code4);
        MAR(8'd5);
        RAM(code5);
        MAR(8'd6);
        RAM(code6);
        MAR(8'd7);
        RAM(code7);
        MAR(8'd8);
        RAM(code8);
        MAR(8'd9);
        RAM(code9);
        MAR(8'd10);
        RAM(code10);
        MAR(8'd11);
        RAM(code11);
        MAR(8'd12);
        RAM(code12);
        MAR(8'd13);
        RAM(code13);
        MAR(8'd14);
        RAM(code14);
        MAR(8'd15);
        RAM(code15);
        MAR(8'd16);
        RAM(code16);
        MAR(8'd17);
        RAM(code17);
        MAR(8'd18);
        RAM(code18);
        MAR(8'd19);
        RAM(code19);
        MAR(8'd20);
        RAM(code20);
        MAR(8'd21);
        RAM(code21);
        MAR(8'd22);
        RAM(code22);
        MAR(8'd23);
        RAM(code23);
        Reset();
        Set();
        
        #2000
        $finish;
    end
endmodule