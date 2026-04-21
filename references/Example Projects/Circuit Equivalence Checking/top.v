`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 08:51:14 PM
// Design Name: 
// Module Name: top
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


module top(
    input A, B, C, D, E,
    output out1, out2, eq
    );
    Lab3 original(A, B, C, D, E, out1);
    Lab3_eq equivalent(A, B, C, D, E, out2);
    assign eq = out1 ^ out2;
endmodule
