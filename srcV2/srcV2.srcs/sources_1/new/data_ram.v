`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// data_ram.v
// -----------------------------------------------------------------------------
// Small data memory for the RISC CPU.
//
// Behavior:
//   - Synchronous reset clears all locations to 0
//   - Synchronous write: data is stored on a rising clock edge when ce and we
//     are both high
//   - Combinational read: rdata immediately reflects ram[addr]
//
// In this project, ADDR_WIDTH = 8 gives 256 locations, and DATA_WIDTH = 16
// matches the CPU register width.
// -----------------------------------------------------------------------------

module data_ram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16
)(
    input                       clk,    // System clock
    input                       reset,  // Active-high synchronous reset
    input                       ce,     // CPU clock enable
    input                       we,     // Write enable
    input  [ADDR_WIDTH-1:0]     addr,   // RAM address
    input  [DATA_WIDTH-1:0]     wdata,  // Data to write
    output [DATA_WIDTH-1:0]     rdata   // Data read from current address
);
    // Memory array: 2^ADDR_WIDTH words, DATA_WIDTH bits each.
    reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            // Clear RAM on reset so the lock program starts from known values.
            for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
                ram[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (ce && we) begin
            // Writes occur only on CPU-enabled cycles.
            ram[addr] <= wdata;
        end
    end

    // Combinational read. This keeps LOAD instructions simple because the CPU
    // can see the selected memory value during the same enabled instruction.
    assign rdata = ram[addr];
endmodule
