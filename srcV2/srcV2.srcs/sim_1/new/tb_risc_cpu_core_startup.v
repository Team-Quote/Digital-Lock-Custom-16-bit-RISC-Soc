`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_risc_cpu_core_startup
//
// Purpose:
//   Runs the CPU core far enough to prove that the ROM program executes, reaches
//   the READY state, accepts a CENTER press, and responds to an UP press.
//
// What is checked:
//   1. CPU is not halted after reset
//   2. startup writes dash codes to the left displays
//   3. READY state shows left dashes, right blanks, and attempt count 0
//   4. CENTER exits ready-wait mode
//   5. UP increments digit 3 and sets its "entered" flag in RAM
//
// Important simulation trick:
//   ce is tied to 1'b1, so the CPU executes one instruction per testbench clock.
//   This avoids waiting for the board-level clock_enable divider.
//
// Note:
//   This is a white-box CPU testbench. It checks internal RAM values through
//   dut.u_data_ram.ram[address]. That is useful for simulation/debugging and is
//   not part of the hardware's external port interface.
//////////////////////////////////////////////////////////////////////////////////

module tb_risc_cpu_core_startup;
    // CPU inputs
    reg clk;
    reg reset;
    reg ce;
    reg [15:0] switches;
    reg [4:0] buttons;

    // CPU outputs
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
    wire halted;
    wire [15:0] debug_pc;
    wire [15:0] debug_instr;
    wire debug_z;
    wire debug_n;

    integer errors;

    risc_cpu_core dut (
        .clk         (clk),
        .reset       (reset),
        .ce          (ce),
        .switches    (switches),
        .buttons     (buttons),
        .led         (led),
        .rgb         (rgb),
        .seg0        (seg0),
        .seg1        (seg1),
        .seg2        (seg2),
        .seg3        (seg3),
        .seg4        (seg4),
        .seg5        (seg5),
        .seg6        (seg6),
        .seg7        (seg7),
        .halted      (halted),
        .debug_pc    (debug_pc),
        .debug_instr (debug_instr),
        .debug_z     (debug_z),
        .debug_n     (debug_n)
    );

    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Advance the simulation by n clock cycles.
    task run_cycles;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(posedge clk);
            end
            #1;
        end
    endtask

    // Check a 16-bit output/register value.
    task expect16;
        input [15:0] actual;
        input [15:0] expected;
        input [127:0] name;
        begin
            if (actual !== expected) begin
                $display("FAIL %0s expected=%h got=%h at pc=%h instr=%h",
                         name, expected, actual, debug_pc, debug_instr);
                errors = errors + 1;
            end else begin
                $display("PASS %0s got=%h at pc=%h", name, actual, debug_pc);
            end
        end
    endtask

    // Check a RAM location inside the CPU core.
    task expect_ram;
        input [7:0] ram_addr;
        input [15:0] expected;
        input [127:0] name;
        begin
            if (dut.u_data_ram.ram[ram_addr] !== expected) begin
                $display("FAIL %0s RAM[%h] expected=%h got=%h at pc=%h",
                         name, ram_addr, expected, dut.u_data_ram.ram[ram_addr], debug_pc);
                errors = errors + 1;
            end else begin
                $display("PASS %0s RAM[%h]=%h", name, ram_addr, expected);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_risc_cpu_core_startup ---");

        errors   = 0;
        ce       = 1'b1;       // one CPU instruction per simulation clock
        switches = 16'h0000;
        buttons  = 5'b00000;
        reset    = 1'b1;

        run_cycles(3);
        reset = 1'b0;
        run_cycles(2);

        if (halted !== 1'b0) begin
            $display("FAIL CPU should not be halted after reset");
            errors = errors + 1;
        end else begin
            $display("PASS CPU not halted after reset");
        end

        // Early startup check: the program should be flashing dashes.
        run_cycles(40);
        expect16(seg7, 16'h0040, "startup seg7 dash");
        expect16(seg6, 16'h0040, "startup seg6 dash");
        expect16(seg5, 16'h0040, "startup seg5 dash");
        expect16(seg4, 16'h0040, "startup seg4 dash");

        // Let startup finish and reach READY_WAIT.
        run_cycles(700);
        expect16(seg7, 16'h0040, "ready seg7 dash");
        expect16(seg6, 16'h0040, "ready seg6 dash");
        expect16(seg5, 16'h0040, "ready seg5 dash");
        expect16(seg4, 16'h0040, "ready seg4 dash");
        expect16(seg3, 16'h0080, "ready seg3 blank");
        expect16(seg2, 16'h0080, "ready seg2 blank");
        expect16(seg1, 16'h0080, "ready seg1 blank");
        expect16(seg0, 16'h0000, "ready attempt count zero");

        // Press CENTER. Internal button bit4 = center.
        buttons = 5'b10000;
        run_cycles(30);
        buttons = 5'b00000;
        run_cycles(200);

        // Press UP. Internal button bit3 = up.
        // Hold it long enough for the CPU polling loop to catch it.
        buttons = 5'b01000;
        run_cycles(350);
        buttons = 5'b00000;
        run_cycles(200);

        // Digit 3 value is stored in RAM[0x02].
        // Digit 3 set flag is stored in RAM[0x06].
        expect_ram(8'h02, 16'h0001, "digit3 incremented by UP");
        expect_ram(8'h06, 16'h0001, "digit3 set flag after UP");

        if (errors == 0) begin
            $display("tb_risc_cpu_core_startup PASSED");
        end else begin
            $display("tb_risc_cpu_core_startup FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
