This is a work-in-progress file for a computer implementation in 8-bit. 
The idea is to build all modern computer components from first principles, as much as my skills and understanding will allow.

Currently the files don't work, since I have started to work on Stack pointers and base pointers, and a single MOV instruction from memory to registers,
registers to memory, etc. The challenge will be to update the ALU, and the Control Unit and overall fetching process to include 3 cycles of fetching from the
Memory address register into the Control Unit signals.

The stack pointers and base pointers will have their own challenges so more updates to come. 

Once the file is ready to be run, and tested I will add the executable approach. Otherwise follow Icarus Verilog compiling process.
I use Gtkwave to simulate binary signals and see each bit and each signal in the final output.  
