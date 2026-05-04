`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_data_ram
//
// Purpose:
//   Verifies the CPU data RAM module.
//
// What is checked:
//   1. reset clears memory to zero
//   2. writes occur only when ce=1 and we=1
//   3. read data changes combinationally with addr
//   4. stored values remain stable when we=0
//////////////////////////////////////////////////////////////////////////////////

module tb_data_ram;
    // Inputs driven by the testbench
    reg clk;
    reg reset;
    reg ce;
    reg we;
    reg [7:0] addr;
    reg [15:0] wdata;

    // Output observed from the RAM
    wire [15:0] rdata;

    // Error counter for self-checking testbench style
    integer errors;

    data_ram #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(16)
    ) dut (
        .clk   (clk),
        .reset (reset),
        .ce    (ce),
        .we    (we),
        .addr  (addr),
        .wdata (wdata),
        .rdata (rdata)
    );

    // 10 ns clock period.
    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Compare RAM read data with an expected value.
    task expect_rdata;
        input [15:0] expected;
        begin
            #1; // small delay for combinational read path

            if (rdata !== expected) begin
                $display("FAIL data_ram addr=%h expected=%h got=%h", addr, expected, rdata);
                errors = errors + 1;
            end else begin
                $display("PASS data_ram addr=%h got=%h", addr, rdata);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_data_ram ---");

        errors = 0;
        reset  = 1'b1;
        ce     = 1'b0;
        we     = 1'b0;
        addr   = 8'h00;
        wdata  = 16'h0000;

        // Reset clears the whole RAM.
        repeat (2) @(posedge clk);
        reset = 1'b0;

        // Confirm a random address reads back as zero after reset.
        addr = 8'h12;
        expect_rdata(16'h0000);

        // Attempted write with ce=0 should not update RAM.
        ce    = 1'b0;
        we    = 1'b1;
        wdata = 16'hAAAA;
        @(posedge clk);
        expect_rdata(16'h0000);

        // Valid write when ce=1 and we=1.
        ce    = 1'b1;
        we    = 1'b1;
        wdata = 16'h1234;
        @(posedge clk);
        expect_rdata(16'h1234);

        // Write another address and verify it separately.
        addr  = 8'h34;
        wdata = 16'hBEEF;
        @(posedge clk);
        expect_rdata(16'hBEEF);

        // Return to the first address and verify it was preserved.
        addr = 8'h12;
        expect_rdata(16'h1234);

        // Disable write and confirm data does not change.
        we    = 1'b0;
        wdata = 16'hFFFF;
        @(posedge clk);
        expect_rdata(16'h1234);

        if (errors == 0) begin
            $display("tb_data_ram PASSED");
        end else begin
            $display("tb_data_ram FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
