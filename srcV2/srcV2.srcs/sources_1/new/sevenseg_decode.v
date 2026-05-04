`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// sevenseg_decode.v
// -----------------------------------------------------------------------------
// Converts a 16-bit display code from the CPU/MMIO register into active-high
// seven-segment data.
//
// Segment bit order used here:
//     seg_active_high = {A, B, C, D, E, F, G}
//
// The Nexys A7 display pins are active-low, so sevenseg_scan.v inverts this
// active-high value before driving CA-CG.
//
// Why the input is 16 bits:
//   The ROM/program writes full display codes such as 0x0080 for blank,
//   0x0040 for dash, and 0x00FF for all segments on. If we only used the low
//   nibble, those special display values would be displayed incorrectly.
// -----------------------------------------------------------------------------

module sevenseg_decode(
    input  [15:0] code,             // Display code written by the CPU
    output reg [6:0] seg_active_high // Active-high {A,B,C,D,E,F,G}
);
    always @(*) begin
        case (code)
            // Special display codes used by the ROM/program.
            16'h0080: seg_active_high = 7'b0000000; // Blank/off
            16'h0040: seg_active_high = 7'b0000001; // Dash: segment G only
            16'h00FF: seg_active_high = 7'b1111111; // All segments on

            // Letter-like display codes used by the PASS/FAIL program states.
            16'h0067: seg_active_high = 7'b1100111; // P approximation
            16'h0047: seg_active_high = 7'b1000111; // F approximation

            default: begin
                // Otherwise, display the low nibble as a hexadecimal digit.
                case (code[3:0])
                    4'h0: seg_active_high = 7'b1111110;
                    4'h1: seg_active_high = 7'b0110000;
                    4'h2: seg_active_high = 7'b1101101;
                    4'h3: seg_active_high = 7'b1111001;
                    4'h4: seg_active_high = 7'b0110011;
                    4'h5: seg_active_high = 7'b1011011;
                    4'h6: seg_active_high = 7'b1011111;
                    4'h7: seg_active_high = 7'b1110000;
                    4'h8: seg_active_high = 7'b1111111;
                    4'h9: seg_active_high = 7'b1111011;
                    4'hA: seg_active_high = 7'b1110111;
                    4'hB: seg_active_high = 7'b0011111;
                    4'hC: seg_active_high = 7'b1001110;
                    4'hD: seg_active_high = 7'b0111101;
                    4'hE: seg_active_high = 7'b1001111;
                    4'hF: seg_active_high = 7'b1000111;
                    default: seg_active_high = 7'b0000000;
                endcase
            end
        endcase
    end
endmodule