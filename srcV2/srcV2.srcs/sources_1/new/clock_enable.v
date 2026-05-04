`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// clock_enable.v
// -----------------------------------------------------------------------------
// Creates a one-clock-cycle enable pulse every DIVISOR input clock cycles.
//
// This does NOT create a new clock. Instead, the CPU still uses CLK100MHZ, but
// only updates when ce = 1. This is the safer FPGA style because it avoids
// creating extra clock domains.
//
// Example for the Nexys A7:
//   clk = 100 MHz, DIVISOR = 50000
//   ce pulses at 100,000,000 / 50,000 = 2,000 pulses per second

module clock_enable #(parameter DIVISOR = 500000)(
    input  clk,        // Source clock, normally 100 MHz on Nexys A7
    input  reset,      // Active-high synchronous reset
    output reg ce      // One-clock pulse used to step slower logic
);
    // 32 bits is more than enough for the divisors used in this project.
    reg [31:0] ctr;

    always @(posedge clk) begin
        if (reset) begin
            // Start counting from zero and keep enable low after reset.
            ctr <= 32'd0;
            ce  <= 1'b0;
        end else if (DIVISOR <= 1) begin
            // Special case for simulation/debugging: a divisor of 1 means the
            // enable is asserted every clock cycle.
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else if (ctr == (DIVISOR - 1)) begin
            // End of count: pulse ce high for one clock and restart counter.
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else begin
            // Normal counting state: ce remains low.
            ctr <= ctr + 32'd1;
            ce  <= 1'b0;
        end
    end
endmodule
