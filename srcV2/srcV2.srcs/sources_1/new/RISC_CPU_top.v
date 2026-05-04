`timescale 1ns / 1ps

module RISC_CPU(
    input         CLK100MHZ,
    input         CPU_RESETN,
    input  [15:0] SW,
    input         BTNC,
    input         BTNU,
    input         BTND,
    input         BTNL,
    input         BTNR,
    output [15:0] LED,
    output        LED16_B,
    output        LED16_G,
    output        LED16_R,
    output [7:0]  AN,
    output        CA,
    output        CB,
    output        CC,
    output        CD,
    output        CE,
    output        CF,
    output        CG,
    output        DP
);
    wire reset;
    wire ce_cpu;
    wire [15:0] sw_sync;
    wire [4:0] btn_sync;
    wire [4:0] btn_async;
    wire [2:0] rgb;
    wire [6:0] seg_bus;
    wire [15:0] seg0;
    wire [15:0] seg1;
    wire [15:0] seg2;
    wire [15:0] seg3;
    wire [15:0] seg4;
    wire [15:0] seg5;
    wire [15:0] seg6;
    wire [15:0] seg7;
    wire halted_unused;
    wire [15:0] debug_pc_unused;
    wire [15:0] debug_instr_unused;
    wire debug_z_unused;
    wire debug_n_unused;

    // Nexys A7 CPU_RESETN is active-low. Internal reset is active-high.
    assign reset = ~CPU_RESETN;

    // Button register bit order expected by the ROM/program:
    // bit0=Right, bit1=Down, bit2=Left, bit3=Up, bit4=Center/Enter.
    assign btn_async = {BTNC, BTNU, BTNL, BTND, BTNR};

    sync_2ff #(.WIDTH(16)) u_sw_sync(
        .clk(CLK100MHZ),
        .async_in(SW),
        .sync_out(sw_sync)
    );

    sync_2ff #(.WIDTH(5)) u_btn_sync(
        .clk(CLK100MHZ),
        .async_in(btn_async),
        .sync_out(btn_sync)
    );

    // 100 MHz / 50000 = 2000 CPU instructions/second.
    // Increase DIVISOR for slower visible debugging; decrease for faster button response.
    clock_enable #(.DIVISOR(50000)) u_cpu_ce(
        .clk(CLK100MHZ),
        .reset(reset),
        .ce(ce_cpu)
    );

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

    assign {CA, CB, CC, CD, CE, CF, CG} = seg_bus;

    // rgb[0]=blue, rgb[1]=green, rgb[2]=red.
    assign LED16_B = rgb[0];
    assign LED16_G = rgb[1];
    assign LED16_R = rgb[2];
endmodule
