`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 08:54:06 PM
// Design Name: 
// Module Name: Lab3_eq
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


module Lab3_eq(
    input A, B, C, D, E,
    output reg Out
    );
    
    // Write the code for the simplified Boolean equation
    always@(*) begin
        Out = (!B & !C & !E) | (!A & B & C & !D) | (A & B & C & !E);
    end
endmodule
