`timescale 1ns / 1ps

module sync_2ff #(parameter WIDTH = 1)(
    input              clk,
    input  [WIDTH-1:0] async_in,
    output [WIDTH-1:0] sync_out
);
    reg [WIDTH-1:0] meta_reg;
    reg [WIDTH-1:0] sync_reg;

    always @(posedge clk) begin
        meta_reg <= async_in;
        sync_reg <= meta_reg;
    end

    assign sync_out = sync_reg;
endmodule
