`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_sevenseg_decode
//
// Purpose:
//   Verifies the sevenseg_decode module, which converts ROM display codes into
//   active-high segment patterns before the scanner inverts them for the Nexys A7.
//
// What is checked:
//   1. special ROM codes: blank, dash, all-on, P, F
//   2. low-nibble hexadecimal display values 0 through F
//////////////////////////////////////////////////////////////////////////////////

module tb_sevenseg_decode;
    reg  [15:0] code;
    wire [6:0]  seg_active_high;

    integer errors;

    sevenseg_decode dut (
        .code            (code),
        .seg_active_high (seg_active_high)
    );

    // Apply a code and check the active-high segment pattern.
    task check;
        input [15:0] in_code;
        input [6:0] expected;
        begin
            code = in_code;
            #1;

            if (seg_active_high !== expected) begin
                $display("FAIL sevenseg_decode code=%h expected=%b got=%b",
                         in_code, expected, seg_active_high);
                errors = errors + 1;
            end else begin
                $display("PASS sevenseg_decode code=%h got=%b", in_code, seg_active_high);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_sevenseg_decode ---");

        errors = 0;

        // Special codes used by the ROM program.
        check(16'h0080, 7'b0000000); // blank/off
        check(16'h0040, 7'b0000001); // dash, segment G only
        check(16'h00FF, 7'b1111111); // all segments on
        check(16'h0067, 7'b1100111); // P-ish pattern
        check(16'h0047, 7'b1000111); // F-ish pattern

        // Hex digit decoding. The module uses code[3:0] for normal digits.
        check(16'h0000, 7'b1111110);
        check(16'h0001, 7'b0110000);
        check(16'h0002, 7'b1101101);
        check(16'h0003, 7'b1111001);
        check(16'h0004, 7'b0110011);
        check(16'h0005, 7'b1011011);
        check(16'h0006, 7'b1011111);
        check(16'h0007, 7'b1110000);
        check(16'h0008, 7'b1111111);
        check(16'h0009, 7'b1111011);
        check(16'h000A, 7'b1110111);
        check(16'h000B, 7'b0011111);
        check(16'h000C, 7'b1001110);
        check(16'h000D, 7'b0111101);
        check(16'h000E, 7'b1001111);
        check(16'h000F, 7'b1000111);

        if (errors == 0) begin
            $display("tb_sevenseg_decode PASSED");
        end else begin
            $display("tb_sevenseg_decode FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
