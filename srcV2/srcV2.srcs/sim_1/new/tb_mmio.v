`timescale 1ns / 1ps
`include "risc_defs.vh"
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_mmio
//
// Purpose:
//   Verifies the memory-mapped I/O block used by the CPU.
//
// What is checked:
//   1. reset clears writable peripheral registers
//   2. button and switch registers read current physical inputs
//   3. LED, RGB, and seven-segment registers store written values
//   4. invalid addresses report hit=0
//
// Notes:
//   MMIO reads are combinational.
//   MMIO writes occur on the clock edge when ce=1 and we=1.
//////////////////////////////////////////////////////////////////////////////////

module tb_mmio;
    // Inputs driven by the testbench
    reg clk;
    reg reset;
    reg ce;
    reg we;
    reg [8:0] addr;
    reg [15:0] wdata;
    reg [15:0] switches;
    reg [4:0] buttons;

    // Outputs observed from the MMIO module
    wire [15:0] rdata;
    wire hit;
    wire [15:0] led;
    wire [2:0] rgb;
    wire [15:0] seg0;
    wire [15:0] seg1;
    wire [15:0] seg2;
    wire [15:0] seg3;
    wire [15:0] seg4;
    wire [15:0] seg5;
    wire [15:0] seg6;
    wire [15:0] seg7;

    integer errors;

    mmio dut (
        .clk      (clk),
        .reset    (reset),
        .ce       (ce),
        .we       (we),
        .addr     (addr),
        .wdata    (wdata),
        .switches (switches),
        .buttons  (buttons),
        .rdata    (rdata),
        .hit      (hit),
        .led      (led),
        .rgb      (rgb),
        .seg0     (seg0),
        .seg1     (seg1),
        .seg2     (seg2),
        .seg3     (seg3),
        .seg4     (seg4),
        .seg5     (seg5),
        .seg6     (seg6),
        .seg7     (seg7)
    );

    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Check a combinational MMIO read.
    task expect_read;
        input [8:0] in_addr;
        input expected_hit;
        input [15:0] expected_data;
        begin
            addr = in_addr;
            #1;

            if (hit !== expected_hit || rdata !== expected_data) begin
                $display("FAIL mmio read addr=%h expected hit=%b data=%h got hit=%b data=%h",
                         in_addr, expected_hit, expected_data, hit, rdata);
                errors = errors + 1;
            end else begin
                $display("PASS mmio read addr=%h hit=%b data=%h", in_addr, hit, rdata);
            end
        end
    endtask

    // Perform a synchronous MMIO write.
    task write_addr;
        input [8:0] in_addr;
        input [15:0] in_data;
        begin
            addr  = in_addr;
            wdata = in_data;
            we    = 1'b1;
            ce    = 1'b1;

            @(posedge clk);
            #1;

            we = 1'b0;
        end
    endtask

    // Generic 16-bit signal checker.
    task expect_signal;
        input [15:0] actual;
        input [15:0] expected;
        input [127:0] name;
        begin
            if (actual !== expected) begin
                $display("FAIL %0s expected=%h got=%h", name, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS %0s got=%h", name, actual);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_mmio ---");

        errors   = 0;
        reset    = 1'b1;
        ce       = 1'b0;
        we       = 1'b0;
        addr     = 9'h000;
        wdata    = 16'h0000;
        switches = 16'hA55A;
        buttons  = 5'b10101;

        repeat (2) @(posedge clk);
        reset = 1'b0;

        // Reset state of writable outputs.
        expect_signal(led,         16'h0000, "led reset");
        expect_signal({13'b0,rgb}, 16'h0000, "rgb reset");
        expect_signal(seg7,        16'h0000, "seg7 reset");

        // Read-only input registers.
        expect_read(`ADDR_SW, 1'b1, 16'hA55A);
        expect_read(`ADDR_BT, 1'b1, 16'h0015);

        // Invalid address should not be claimed by MMIO.
        expect_read(9'h000, 1'b0, 16'h0000);

        // LED register write/readback.
        write_addr(`ADDR_LED, 16'h00F0);
        expect_signal(led, 16'h00F0, "led write");
        expect_read(`ADDR_LED, 1'b1, 16'h00F0);

        // RGB uses only the lower 3 bits of wdata.
        write_addr(`ADDR_RGB, 16'h0005);
        expect_signal({13'b0,rgb}, 16'h0005, "rgb write lower 3 bits");
        expect_read(`ADDR_RGB, 1'b1, 16'h0005);

        // Seven-segment display registers.
        write_addr(`ADDR_SEG7, 16'h0040); // dash code
        write_addr(`ADDR_SEG0, 16'h0008); // digit 8
        expect_signal(seg7, 16'h0040, "seg7 write dash");
        expect_signal(seg0, 16'h0008, "seg0 write eight");
        expect_read(`ADDR_SEG7, 1'b1, 16'h0040);
        expect_read(`ADDR_SEG0, 1'b1, 16'h0008);

        if (errors == 0) begin
            $display("tb_mmio PASSED");
        end else begin
            $display("tb_mmio FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
