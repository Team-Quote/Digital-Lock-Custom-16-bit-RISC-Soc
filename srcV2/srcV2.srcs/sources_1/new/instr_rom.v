`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// instr_rom.v
// -----------------------------------------------------------------------------
// Instruction ROM for the RISC CPU.
//
// The ROM is initialized from program.mem using $readmemh. Vivado will bake this
// file into the bitstream during synthesis/implementation, so the FPGA starts
// with the lock program already loaded.
//
// Important Vivado note:
//   Add program.mem to the project as a memory initialization/design source, and
//   keep the file name exactly program.mem unless this source is changed too.
// -----------------------------------------------------------------------------

module instr_rom #(parameter ROM_DEPTH = 1024)(
    input  [15:0] addr,   // Program counter address from CPU core
    output reg [15:0] instr  // Instruction word at that address
);
    // 16-bit instruction memory.
    reg [15:0] rom [0:ROM_DEPTH-1];

    integer i;

    initial begin
        // Default unused ROM addresses to HALT. If the PC ever runs past the
        // loaded program, the CPU stops safely instead of executing garbage.
        for (i = 0; i < ROM_DEPTH; i = i + 1) begin
            rom[i] = 16'hD000;
        end

        // Load program contents generated from the Logisim/.circ ROM.
        $readmemh("program.mem", rom);
    end

    always @(*) begin
        if (addr < ROM_DEPTH) begin
            instr = rom[addr];
        end else begin
            // Out-of-range addresses also return HALT.
            instr = 16'hD000;
        end
    end
endmodule
