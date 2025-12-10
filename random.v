task initialize_memory;
    input [6:0] address_init;      // 7-bit address (e.g., EEPROM index)
    input [7:0] value1;       // 8-bit value for EEPROM1
    input [7:0] value2;       // 8-bit value for EEPROM2
    begin
        // Drive the address and load signals to initialize the memory
        address <= address_init;
        microcode[7:0] <= value1;
        address <= address_init;
        microcode[15:8] <= value2;

        // Enable the write signal temporarily
        eeprom_in <= 1'b1;
        #1; // Wait for 1 time unit to simulate writing

        // Disable write signals after initialization
        eeprom_in <= 1'b0;
    end
endtask

initial begin
    // Call task to initialize EEPROM
    initialize_memory(7'd0, 8'b01000000, 8'b00000100); // Address 0: MI, CO
    initialize_memory(7'd1, 8'b00010100, 8'b00000100); // Address 1: RO, II
    initialize_memory(7'd2, 8'b01001000, 8'b00000000); // Address 2: MI, IO
    initialize_memory(7'd3, 8'b00010010, 8'b00000100); // Address 3: RO, AI
    initialize_memory(7'd4, 8'b00000000, 8'b00000000); // Address 4: NOP, NOP
    initialize_memory(7'd5, 8'b00000000, 8'b00000000); // Address 5: NOP, NOP
end




initial begin
    EEPROM1.EEPROM.ram_array[0] = 8'b01000000; // MI
    EEPROM2.EEPROM.ram_array[0] = 8'b00000100;// CO

    EEPROM1.EEPROM.ram_array[1] = 8'b00010100; // RO, II
    EEPROM2.EEPROM.ram_array[1] = 8'b00000100; // CE

    // LDA instruction
    EEPROM1.EEPROM.ram_array[2] = 8'b01001000; // MI, IO
    EEPROM2.EEPROM.ram_array[2] = 8'b00000000; // 

    EEPROM1.EEPROM.ram_array[3] = 8'b00010010; // RO, AI
    EEPROM2.EEPROM.ram_array[3] = 8'b00000100; // 

    EEPROM1.EEPROM.ram_array[4] = 8'b00000000; // NOP
    EEPROM2.EEPROM.ram_array[4] = 8'b00000000; // NOP

    EEPROM1.EEPROM.ram_array[5] = 8'b00000000; // NOP
    EEPROM2.EEPROM.ram_array[5] = 8'b00000000; // NOP

end