`timescale 1ns / 1ps

module clock_enable #(parameter DIVISOR = 500000)(
    input  clk,
    input  reset,
    output reg ce
);
    reg [31:0] ctr;

    always @(posedge clk) begin
        if (reset) begin
            ctr <= 32'd0;
            ce  <= 1'b0;
        end else if (DIVISOR <= 1) begin
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else if (ctr == (DIVISOR - 1)) begin
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else begin
            ctr <= ctr + 32'd1;
            ce  <= 1'b0;
        end
    end
endmodule
