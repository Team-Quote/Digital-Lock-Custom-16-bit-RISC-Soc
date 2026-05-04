`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Instruction opcode map
// Instruction format used by this project:
//     [15:12] opcode
//     [11:9]  Rd
//     [8:6]   Rs
//     [8:0]   immediate / load-store address
//     [11:0]  jump address
// -----------------------------------------------------------------------------
`define OP_LDI   4'h0  // Load immediate value into Rd
`define OP_LD    4'h1  // Load memory/MMIO value into Rd
`define OP_ST    4'h2  // Store Rd value into memory/MMIO
`define OP_ADD   4'h3  // Rd = Rd + Rs
`define OP_SUB   4'h4  // Rd = Rd - Rs
`define OP_AND   4'h5  // Rd = Rd & Rs
`define OP_OR    4'h6  // Rd = Rd | Rs
`define OP_CMP   4'h7  // Set flags from Rd - Rs, discard result
`define OP_JMP   4'h8  // Unconditional jump
`define OP_JZ    4'h9  // Jump if Z flag is 1
`define OP_JNZ   4'hA  // Jump if Z flag is 0
`define OP_JN    4'hB  // Jump if N flag is 1
`define OP_NOP   4'hC  // No operation
`define OP_HALT  4'hD  // Stop CPU until reset
`define OP_XOR   4'hE  // Rd = Rd ^ Rs
`define OP_PASS  4'hF  // Rd = Rs passthrough operation

// -----------------------------------------------------------------------------
// Memory-mapped I/O address map
// These are the low MMIO addresses used by the ROM/program.
// -----------------------------------------------------------------------------
`define ADDR_BT   9'h034  // Read buttons
`define ADDR_SW   9'h035  // Read switches
`define ADDR_LED  9'h036  // Write/read LEDs
`define ADDR_RGB  9'h037  // Write/read RGB LED bits
`define ADDR_SEG7 9'h038  // Leftmost seven-seg digit
`define ADDR_SEG6 9'h039
`define ADDR_SEG5 9'h03A
`define ADDR_SEG4 9'h03B
`define ADDR_SEG3 9'h03C
`define ADDR_SEG2 9'h03D
`define ADDR_SEG1 9'h03E
`define ADDR_SEG0 9'h03F  // Rightmost seven-seg digit

// -----------------------------------------------------------------------------
// mmio.v
// -----------------------------------------------------------------------------
// Memory-Mapped I/O block for the RISC CPU.
//
// The CPU uses normal LOAD and STORE instructions to communicate with board
// peripherals. This module decides whether an address belongs to a peripheral,
// returns read data for LOAD, and updates output registers for STORE.
//
// Address map:
//   0x034  buttons, read-only
//   0x035  switches, read-only
//   0x036  LEDs, read/write
//   0x037  RGB LED, read/write low 3 bits
//   0x038-0x03F seven-segment display registers, read/write
//
// The hit output tells the CPU whether the address was handled by MMIO. If hit
// is 0, the CPU treats the access as normal data RAM.
// -----------------------------------------------------------------------------

module mmio(
    input         clk,       // System clock
    input         reset,     // Active-high synchronous reset
    input         ce,        // CPU clock enable
    input         we,        // MMIO write enable from CPU core
    input  [8:0]  addr,      // 9-bit load/store address from instruction
    input  [15:0] wdata,     // Register value being stored
    input  [15:0] switches,  // Synchronized board switches
    input  [4:0]  buttons,   // Synchronized button word
    output reg [15:0] rdata, // Data returned to CPU on LOAD
    output reg        hit,   // 1 when addr belongs to this MMIO block
    output reg [15:0] led,   // LED output register
    output reg [2:0]  rgb,   // RGB output register: {red, green, blue}
    output reg [15:0] seg0,  // Seven-seg digit 0, rightmost
    output reg [15:0] seg1,
    output reg [15:0] seg2,
    output reg [15:0] seg3,
    output reg [15:0] seg4,
    output reg [15:0] seg5,
    output reg [15:0] seg6,
    output reg [15:0] seg7   // Seven-seg digit 7, leftmost
);
    // Expand 5 button bits into the CPU's 16-bit data width.
    wire [15:0] button_word;
    assign button_word = {11'b00000000000, buttons};

    // -------------------------------------------------------------------------
    // MMIO read decoder
    // -------------------------------------------------------------------------
    // This block is combinational. It returns the current peripheral value and
    // tells the CPU whether this address is an MMIO address.
    always @(*) begin
        hit   = 1'b1;
        rdata = 16'h0000;

        case (addr)
            `ADDR_BT:   rdata = button_word;
            `ADDR_SW:   rdata = switches;
            `ADDR_LED:  rdata = led;
            `ADDR_RGB:  rdata = {13'b0000000000000, rgb};
            `ADDR_SEG7: rdata = seg7;
            `ADDR_SEG6: rdata = seg6;
            `ADDR_SEG5: rdata = seg5;
            `ADDR_SEG4: rdata = seg4;
            `ADDR_SEG3: rdata = seg3;
            `ADDR_SEG2: rdata = seg2;
            `ADDR_SEG1: rdata = seg1;
            `ADDR_SEG0: rdata = seg0;
            default: begin
                // Not an MMIO address. The CPU should use data RAM instead.
                hit   = 1'b0;
                rdata = 16'h0000;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // MMIO write registers
    // -------------------------------------------------------------------------
    // Writes happen only on CPU-enabled cycles. Button and switch addresses are
    // read-only, so STORE instructions to those addresses have no effect.
    always @(posedge clk) begin
        if (reset) begin
            led  <= 16'h0000;
            rgb  <= 3'b000;
            seg0 <= 16'h0000;
            seg1 <= 16'h0000;
            seg2 <= 16'h0000;
            seg3 <= 16'h0000;
            seg4 <= 16'h0000;
            seg5 <= 16'h0000;
            seg6 <= 16'h0000;
            seg7 <= 16'h0000;
        end else if (ce && we) begin
            case (addr)
                `ADDR_LED:  led  <= wdata;
                `ADDR_RGB:  rgb  <= wdata[2:0];
                `ADDR_SEG7: seg7 <= wdata;
                `ADDR_SEG6: seg6 <= wdata;
                `ADDR_SEG5: seg5 <= wdata;
                `ADDR_SEG4: seg4 <= wdata;
                `ADDR_SEG3: seg3 <= wdata;
                `ADDR_SEG2: seg2 <= wdata;
                `ADDR_SEG1: seg1 <= wdata;
                `ADDR_SEG0: seg0 <= wdata;
                default: begin
                    // Invalid or read-only MMIO write. Hold all registers.
                end
            endcase
        end
    end
endmodule
