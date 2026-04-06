`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:28:48 PM
// Design Name: 
// Module Name: cpu_core
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


module cpu_core (
    input  wire        clk,
    input  wire        reset,

    output reg         mem_read,
    output reg         mem_write,
    output reg  [15:0] addr,
    output reg  [15:0] write_data,
    input  wire [15:0] read_data
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_read   <= 1'b0;
            mem_write  <= 1'b0;
            addr       <= 16'h0000;
            write_data <= 16'h0000;
        end else begin
            // Placeholder CPU behavior
            // Replace with real instruction fetch/execute later
            mem_read   <= 1'b1;
            mem_write  <= 1'b0;
            addr       <= 16'h8000; // read switches
            write_data <= 16'h0000;
        end
    end

endmodule
