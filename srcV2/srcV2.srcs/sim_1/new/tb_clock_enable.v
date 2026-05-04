`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_clock_enable
//
// Purpose:
//   Verifies the clock_enable module used to slow down the CPU instruction rate.
//   The real design uses a large DIVISOR such as 50000, but this testbench uses
//   DIVISOR=4 so the enable pulse can be checked quickly in simulation.
//
// What is checked:
//   1. reset forces ce low
//   2. ce pulses once every DIVISOR clock cycles
//   3. ce returns low between pulses
//////////////////////////////////////////////////////////////////////////////////

module tb_clock_enable;
    // Inputs driven by the testbench
    reg clk;
    reg reset;

    // Output observed from the design under test
    wire ce;

    // Bookkeeping variables
    integer errors;
    integer cycle;

    // Use a small divisor for simulation so the test completes quickly.
    clock_enable #(.DIVISOR(4)) dut (
        .clk   (clk),
        .reset (reset),
        .ce    (ce)
    );

    // 100 MHz-style simulation clock: 10 ns period.
    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Check ce after one rising clock edge.
    task expect_ce;
        input expected;
        begin
            @(posedge clk);
            #1; // allow nonblocking assignments to settle

            if (ce !== expected) begin
                $display("FAIL cycle=%0d expected ce=%b got=%b", cycle, expected, ce);
                errors = errors + 1;
            end else begin
                $display("PASS cycle=%0d ce=%b", cycle, ce);
            end

            cycle = cycle + 1;
        end
    endtask

    initial begin
        $display("\n--- Starting tb_clock_enable ---");

        errors = 0;
        cycle  = 0;
        reset  = 1'b1;

        // Hold reset for two clock edges.
        repeat (2) @(posedge clk);
        #1;

        if (ce !== 1'b0) begin
            $display("FAIL reset should force ce=0");
            errors = errors + 1;
        end else begin
            $display("PASS reset forced ce=0");
        end

        reset = 1'b0;

        // For DIVISOR=4, ce should pulse on every 4th enabled cycle.
        expect_ce(1'b0);
        expect_ce(1'b0);
        expect_ce(1'b0);
        expect_ce(1'b1);
        expect_ce(1'b0);
        expect_ce(1'b0);
        expect_ce(1'b0);
        expect_ce(1'b1);

        if (errors == 0) begin
            $display("tb_clock_enable PASSED");
        end else begin
            $display("tb_clock_enable FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
