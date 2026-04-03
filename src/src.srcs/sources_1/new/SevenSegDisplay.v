`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 02:35:23 PM
// Design Name: 
// Module Name: SevenSegDisplay
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


module SevenSegDisplay(A1, B1, C1, D1, a, b, c, d, e, f, g, dp, enable);

    // Inputs and Outputs
    input A1, B1, C1, D1;
    output a, b, c, d, e, f, g, dp;
    output [3:0] enable;
    
    // Enable and decimal point control
    assign enable = 4'b1100;
    assign dp = 1'b1;
    
    // Inverted inputs
    wire A1_, B1_, C1_, D1_;
    
    // Intermediate signals for each segment
    
    
    
    // Generate inverated inputs
    not (A1_, A1),
        (B1_, B1),
        (C1_, C1),
        (D1_, D1);
        
    // Segment a
    
    // Segment b
    
    // Segment c
    
    // Segment d
    
    // Segment e
    
    // Segment f
    
    // Segment g
endmodule
