`timescale 1ns / 1ps

module instr_rom #(parameter ROM_DEPTH = 1024)(
    input  [15:0] addr,
    output reg [15:0] instr
);
    reg [15:0] rom [0:ROM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < ROM_DEPTH; i = i + 1) begin
            rom[i] = 16'hD000; // HALT by default past the program.
        end
        $readmemh("program.mem", rom);
    end

    always @(*) begin
        if (addr < ROM_DEPTH) begin
            instr = rom[addr];
        end else begin
            instr = 16'hD000;
        end
    end
endmodule
