`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// sevenseg_scan.v
// -----------------------------------------------------------------------------
// Multiplexing driver for the Nexys A7 eight-digit seven-segment display.
//
// The Nexys A7 display shares the seven cathode lines across all eight digits.
// Only one digit is enabled at a time using AN[7:0]. This module cycles through
// the digits quickly so the human eye sees all digits as continuously lit.
//
// Inputs seg0-seg7 are 16-bit display codes from MMIO. They are decoded by
// sevenseg_decode.v into segment patterns.
// -----------------------------------------------------------------------------

module sevenseg_scan #(
    parameter CLK_HZ = 100000000, // Board clock frequency
    parameter REFRESH_HZ = 1000   // Total display refresh rate
)(
    input         clk,
    input         reset,
    input  [15:0] seg0, // Rightmost digit
    input  [15:0] seg1,
    input  [15:0] seg2,
    input  [15:0] seg3,
    input  [15:0] seg4,
    input  [15:0] seg5,
    input  [15:0] seg6,
    input  [15:0] seg7, // Leftmost digit
    output reg [7:0] an,  // Active-low digit enable lines
    output reg [6:0] seg, // Active-low cathode lines {CA,CB,CC,CD,CE,CF,CG}
    output reg       dp   // Active-low decimal point
);
    // Number of input-clock ticks to hold each individual digit on.
    localparam TICKS_PER_DIGIT = CLK_HZ / (REFRESH_HZ * 8);
    localparam REFRESH_MAX = TICKS_PER_DIGIT - 1;

    reg [31:0] refresh_ctr;
    reg [2:0]  digit_sel;
    reg [15:0] digit_code;
    wire [6:0] seg_active_high;

    // -------------------------------------------------------------------------
    // Refresh counter and digit selector
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            refresh_ctr <= 32'd0;
            digit_sel   <= 3'd0;
        end else begin
            if (refresh_ctr == REFRESH_MAX) begin
                refresh_ctr <= 32'd0;
                digit_sel   <= digit_sel + 3'd1;
            end else begin
                refresh_ctr <= refresh_ctr + 32'd1;
            end
        end
    end

    // Select which CPU display register is currently being shown.
    always @(*) begin
        case (digit_sel)
            3'd0: digit_code = seg0;
            3'd1: digit_code = seg1;
            3'd2: digit_code = seg2;
            3'd3: digit_code = seg3;
            3'd4: digit_code = seg4;
            3'd5: digit_code = seg5;
            3'd6: digit_code = seg6;
            3'd7: digit_code = seg7;
            default: digit_code = 16'h0080; // Blank/off
        endcase
    end

    // Decode the selected 16-bit display code to active-high segment bits.
    sevenseg_decode u_dec(
        .code(digit_code),
        .seg_active_high(seg_active_high)
    );

    // Convert active-high internal segment data to active-low Nexys outputs.
    always @(*) begin
        // Enable exactly one digit. AN is active-low.
        an  = ~(8'b00000001 << digit_sel);

        // Cathodes are active-low, so invert the decoded active-high pattern.
        seg = ~seg_active_high;

        // Decimal point is not used in this project, so keep it off.
        dp  = 1'b1;
    end
endmodule
