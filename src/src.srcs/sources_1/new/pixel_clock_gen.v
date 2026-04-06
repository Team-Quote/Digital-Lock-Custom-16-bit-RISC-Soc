`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:28:48 PM
// Design Name: 
// Module Name: pixel_clock_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pixel_clock_gen (
    input  wire clk_in,
    input  wire reset,
    output reg  clk_out,
    output reg  clk_cpu
);

    reg [1:0] div25;
    reg [15:0] divcpu;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            div25   <= 2'b00;
            clk_out <= 1'b0;
            divcpu  <= 16'd0;
            clk_cpu <= 1'b0;
        end else begin
            div25 <= div25 + 1'b1;
            if (div25 == 2'b01)
                clk_out <= ~clk_out;

            divcpu <= divcpu + 1'b1;
            if (divcpu == 16'd50000) begin
                clk_cpu <= ~clk_cpu;
                divcpu <= 16'd0;
            end
        end
    end

endmodule