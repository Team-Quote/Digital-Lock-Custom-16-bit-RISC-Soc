`timescale 1ns / 1ps

module sevenseg_scan #(parameter CLK_HZ = 100000000, parameter REFRESH_HZ = 1000)(
    input         clk,
    input         reset,
    input  [15:0] seg0,
    input  [15:0] seg1,
    input  [15:0] seg2,
    input  [15:0] seg3,
    input  [15:0] seg4,
    input  [15:0] seg5,
    input  [15:0] seg6,
    input  [15:0] seg7,
    output reg [7:0] an,
    output reg [6:0] seg,
    output reg       dp
);
    localparam TICKS_PER_DIGIT = CLK_HZ / (REFRESH_HZ * 8);
    localparam REFRESH_MAX = TICKS_PER_DIGIT - 1;

    reg [31:0] refresh_ctr;
    reg [2:0] digit_sel;
    reg [15:0] digit_code;
    wire [6:0] seg_active_high;

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
            default: digit_code = 16'h0080;
        endcase
    end

    sevenseg_decode u_dec(
        .code(digit_code),
        .seg_active_high(seg_active_high)
    );

    always @(*) begin
        // Nexys A7 anodes and cathodes are active-low.
        an  = ~(8'b00000001 << digit_sel);
        seg = ~seg_active_high;
        dp  = 1'b1;
    end
endmodule
