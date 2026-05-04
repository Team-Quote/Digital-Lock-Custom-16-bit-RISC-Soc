`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// RISC_CPU_top.v
// -----------------------------------------------------------------------------
// Board-level top module for the Nexys A7-100T demo.
//
// This module connects the physical board inputs/outputs to the internal RISC
// CPU system:
//   - Synchronizes switches and push buttons into the 100 MHz clock domain
//   - Generates a slower CPU clock-enable pulse
//   - Instantiates the CPU core
//   - Scans the eight seven-segment digits
//   - Maps the internal RGB bits to the Nexys A7 RGB LED pins
//
// The module name stays RISC_CPU so the existing NexysA7-100T.xdc constraints
// file can still use the same top-level port names.
// -----------------------------------------------------------------------------

module RISC_CPU(
    input         CLK100MHZ,    // Nexys A7 100 MHz system clock
    input         CPU_RESETN,   // Active-low CPU reset push button
    input  [15:0] SW,           // Board switches
    input         BTNC,         // Center push button
    input         BTNU,         // Up push button
    input         BTND,         // Down push button
    input         BTNL,         // Left push button
    input         BTNR,         // Right push button
    output [15:0] LED,          // Board LEDs
    output        LED16_B,      // RGB LED blue channel
    output        LED16_G,      // RGB LED green channel
    output        LED16_R,      // RGB LED red channel
    output [7:0]  AN,           // Seven-seg anode enables, active-low
    output        CA,           // Seven-seg cathode A, active-low
    output        CB,           // Seven-seg cathode B, active-low
    output        CC,           // Seven-seg cathode C, active-low
    output        CD,           // Seven-seg cathode D, active-low
    output        CE,           // Seven-seg cathode E, active-low
    output        CF,           // Seven-seg cathode F, active-low
    output        CG,           // Seven-seg cathode G, active-low
    output        DP            // Seven-seg decimal point, active-low
);
    // Internal reset is active-high, but the Nexys CPU reset button is active-low.
    wire reset;

    // ce_cpu is a single-clock pulse used to step the CPU at a visible speed.
    wire ce_cpu;

    // Synchronized input versions. Push buttons and switches come from the
    // outside world, so they are passed through two flip-flop synchronizers.
    wire [15:0] sw_sync;
    wire [4:0]  btn_sync;
    wire [4:0]  btn_async;

    // Peripheral wires from the CPU core to board output drivers.
    wire [2:0]  rgb;
    wire [6:0]  seg_bus;
    wire [15:0] seg0;
    wire [15:0] seg1;
    wire [15:0] seg2;
    wire [15:0] seg3;
    wire [15:0] seg4;
    wire [15:0] seg5;
    wire [15:0] seg6;
    wire [15:0] seg7;

    // Debug outputs exist on the CPU core for simulation. They are unused on
    // the physical board, so they are tied to local wires here.
    wire        halted_unused;
    wire [15:0] debug_pc_unused;
    wire [15:0] debug_instr_unused;
    wire        debug_z_unused;
    wire        debug_n_unused;

    // Convert active-low board reset to active-high internal reset.
    assign reset = ~CPU_RESETN;

    // Button bit order expected by the ROM/program:
    //   bit0 = Right
    //   bit1 = Down
    //   bit2 = Left
    //   bit3 = Up
    //   bit4 = Center/Enter
    // The order below places each physical button into the expected bit.
    assign btn_async = {BTNC, BTNU, BTNL, BTND, BTNR};

    // Synchronize switches into the 100 MHz clock domain.
    sync_2ff #(.WIDTH(16)) u_sw_sync(
        .clk(CLK100MHZ),
        .async_in(SW),
        .sync_out(sw_sync)
    );

    // Synchronize buttons into the 100 MHz clock domain.
    sync_2ff #(.WIDTH(5)) u_btn_sync(
        .clk(CLK100MHZ),
        .async_in(btn_async),
        .sync_out(btn_sync)
    );

    // Generate a CPU step enable.
    // 100 MHz / 50000 = 2000 CPU instructions per second.
    // Increase DIVISOR for slower visible debugging; decrease it for faster
    // button response or faster simulation on the board.
    clock_enable #(.DIVISOR(50000)) u_cpu_ce(
        .clk(CLK100MHZ),
        .reset(reset),
        .ce(ce_cpu)
    );

    // Main processor system. The program is stored in instr_rom.v and loaded
    // from program.mem.
    risc_cpu_core u_cpu(
        .clk(CLK100MHZ),
        .reset(reset),
        .ce(ce_cpu),
        .switches(sw_sync),
        .buttons(btn_sync),
        .led(LED),
        .rgb(rgb),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .halted(halted_unused),
        .debug_pc(debug_pc_unused),
        .debug_instr(debug_instr_unused),
        .debug_z(debug_z_unused),
        .debug_n(debug_n_unused)
    );

    // Multiplex the eight seven-segment digits fast enough that they appear
    // continuously lit to the human eye.
    sevenseg_scan u_sevenseg(
        .clk(CLK100MHZ),
        .reset(reset),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .an(AN),
        .seg(seg_bus),
        .dp(DP)
    );

    // Break the 7-bit segment bus out to the Nexys A7 cathode pins.
    // seg_bus order is {A, B, C, D, E, F, G}; outputs are active-low.
    assign {CA, CB, CC, CD, CE, CF, CG} = seg_bus;

    // RGB bit convention from the MMIO register:
    //   rgb[0] = blue
    //   rgb[1] = green
    //   rgb[2] = red
    assign LED16_B = rgb[0];
    assign LED16_G = rgb[1];
    assign LED16_R = rgb[2];
endmodule

