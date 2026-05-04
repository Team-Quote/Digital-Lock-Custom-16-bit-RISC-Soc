`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_instr_rom
//
// Purpose:
//   Verifies that the instruction ROM loads program.mem correctly and returns
//   HALT when the program counter is outside the ROM depth.
//
// Important:
//   If this test fails at address 0, 1, 2, or 3, Vivado probably did not find
//   program.mem. Add program.mem to the simulation/design sources and keep the
//   filename exactly as "program.mem".
//////////////////////////////////////////////////////////////////////////////////

module tb_instr_rom;
    // ROM address driven by the testbench
    reg [15:0] addr;

    // Instruction output from the ROM
    wire [15:0] instr;

    // Error counter
    integer errors;

    instr_rom #(.ROM_DEPTH(1024)) dut (
        .addr  (addr),
        .instr (instr)
    );

    // Read an address and compare against the expected instruction word.
    task check;
        input [15:0] in_addr;
        input [15:0] expected;
        begin
            addr = in_addr;
            #1; // ROM is combinational, so one delta/small delay is enough

            if (instr !== expected) begin
                $display("FAIL instr_rom addr=%h expected=%h got=%h", in_addr, expected, instr);
                errors = errors + 1;
            end else begin
                $display("PASS instr_rom addr=%h instr=%h", in_addr, instr);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_instr_rom ---");

        errors = 0;

        // First values from the current program.mem.
        // These prove $readmemh successfully found and loaded the ROM file.
        check(16'h0000, 16'h0000);
        check(16'h0001, 16'h0201);
        check(16'h0002, 16'h0A80);
        check(16'h0003, 16'h2A0B);

        // Address 1024 and beyond is outside ROM_DEPTH=1024.
        // The module intentionally returns HALT in that case.
        check(16'h0400, 16'hD000);
        check(16'hFFFF, 16'hD000);

        if (errors == 0) begin
            $display("tb_instr_rom PASSED");
        end else begin
            $display("tb_instr_rom FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
