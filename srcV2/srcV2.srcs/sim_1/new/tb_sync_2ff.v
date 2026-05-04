`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_sync_2ff
//
// Purpose:
//   Verifies the two-flip-flop synchronizer used for switches and push buttons.
//
// What is checked:
//   A new async_in value should appear at sync_out after two rising clock edges.
//
// Note:
//   This testbench does not model metastability. It verifies the intended digital
//   delay/transfer behavior of the synchronizer module.
//////////////////////////////////////////////////////////////////////////////////

module tb_sync_2ff;
    reg clk;
    reg [4:0] async_in;
    wire [4:0] sync_out;

    integer errors;

    sync_2ff #(.WIDTH(5)) dut (
        .clk      (clk),
        .async_in (async_in),
        .sync_out (sync_out)
    );

    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Apply a value and check that it appears after two clock edges.
    task check_after_two_edges;
        input [4:0] value;
        begin
            async_in = value;

            @(posedge clk);
            @(posedge clk);
            #1;

            if (sync_out !== value) begin
                $display("FAIL sync_2ff expected=%b got=%b", value, sync_out);
                errors = errors + 1;
            end else begin
                $display("PASS sync_2ff value=%b", value);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_sync_2ff ---");

        errors   = 0;
        async_in = 5'b00000;

        repeat (3) @(posedge clk);

        // Internal button bit meanings used by the lock program:
        // bit0=Right, bit1=Down, bit2=Left, bit3=Up, bit4=Center.
        check_after_two_edges(5'b10000); // center
        check_after_two_edges(5'b01000); // up
        check_after_two_edges(5'b00010); // down
        check_after_two_edges(5'b00100); // left
        check_after_two_edges(5'b00001); // right
        check_after_two_edges(5'b11111); // all pressed
        check_after_two_edges(5'b00000); // none pressed

        if (errors == 0) begin
            $display("tb_sync_2ff PASSED");
        end else begin
            $display("tb_sync_2ff FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
