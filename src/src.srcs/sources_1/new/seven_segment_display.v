`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2026 09:06:01 PM
// Design Name: 
// Module Name: seven_segment_display
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


module seven_segment_display(A1, B1, C1, D1, a, b, c, d, e, f, g, dp, enable);

    // Inputs and Outputs
    input A1, B1, C1, D1;               // 4-bit BCD number A1, B1, C1, D1
    output a, b, c, d, e, f, g, dp;     // 7-segment control and decimal point (ACTIVE LOW)
    output [3:0] enable;                // Enable for 4 display digits
    
    
    // enable and decimal point control
    assign enable = 4'b1100;            // Always enable the least significant digit (ACTIVE LOW)
    assign dp = 1'b1;                   // turn off decimal point (ACTIVE LOW)
    
    // Inverted inputs
    wire A1_, B1_, C1_, D1_;
    
    // Intermediate signals for each segment
    wire B1C1, A1D1_, A1_C1, B1_D1_, A1_B1D1, A1B1_C1_;
    wire A1_B1_, B1_D1_, A1D1C1_, A1_C1D1, A1_C1_D1_;
    wire A1B1_, A1_B1, A1_D1, D1C1_, A1_C1_;
    wire A1C1_, B1C1D1_, B1D1C1_, C1D1B1_, A1_B1_D1_;
    wire A1B1, A1C1, C1D1_, B1_D1_;
    wire A1C1, A1B1_, B1D1_, C1_D1_, A1_B1C1_;
    wire A1D1, A1B1_, C1B1_, C1D1_, A1_B1C1_;
    
    // Generate inverted inputs
    not (A1_, A1),
        (B1_, B1),
        (C1_, C1),
        (D1_, D1);
     
    // Segment a
    and (B1C1, B1, C1),
        (A1D1_, A1, D1_),
        (A1_C1, A1_, C1),
        (B1_D1_, B1_, D1_),
        (A1_B1D1, A1_, B1, D1),
        (A1B1_C1_, A1, B1_, C1_);
    
    nor (a, B1C1, A1D1_, A1_C1, B1_D1_, A1_B1D1, A1B1_C1_);
    
    // Segment b
    and (A1_B1_, A1_, B1_),
        (B1_D1_, B1_, D1_),
        (A1D1C1_, A1, D1, C1_),
        (A1_C1D1, A1_, C1, D1),
        (A1_C1_D1_, A1_, C1_, D1_);
    nor (b, A1_B1_, B1_D1_, A1D1C1_, A1_C1D1, A1_C1_D1_);
    
    // Segment c
    and (A1B1_, A1, B1_),
        (A1_B1, A1_, B1),
        (A1_D1, A1_, D1),
        (D1C1_, D1, C1_),
        (A1_C1_, A1_, C1_);
    nor (c, A1B1_, A1_B1, A1_D1, D1C1_, A1_C1_);
   
    // Segment d
    and (A1C1_, A1, C1_),
        (B1C1D1_, B1, C1, D1_),
        (B1D1C1_, B1, D1, C1_),
        (C1D1B1_, C1, D1, B1_),
        (A1_B1_D1_, A1_, D1_, D1_);
    nor (d, A1C1_, B1C1D1_, B1D1C1_, C1D1B1_, A1_B1_D1_);
    
    // Segment e
    and (A1B1, A1, B1),
        (A1C1, A1, C1),
        (C1D1_, C1, D1_),
        (B1_D1_, B1_,D1_);
    nor (e, A1B1, A1C1, C1D1_, B1_D1_);
    
    // Segment f
    and (A1C1, A1, C1),
        (A1B1_, A1, B1_),
        (B1D1_, B1, D1_),
        (C1_D1_, C1_, D1_),
        (A1_B1C1_, A1_, B1, C1_);
    nor (f, A1C1, A1B1_, B1D1_, C1_D1_, A1_B1C1_);
    
    // Segment g
    and (A1D1, A1, D1),
        (A1B1_, A1, B1_),
        (C1B1_, C1, B1_),
        (C1D1_, C1, D1_),
        (A1_B1C1_, A1_, B1, C1_);
    nor (g, A1D1, A1B1_, C1B1_, C1D1_, A1_B1C1_);
    
endmodule
