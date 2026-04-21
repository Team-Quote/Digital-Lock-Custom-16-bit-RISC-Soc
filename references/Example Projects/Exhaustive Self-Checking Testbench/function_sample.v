`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Amin Rezaei
// Create Date: 09/30/2020 03:51:18 PM
// Design Name: 361 Sample 4
// Module Name: function_sample
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module function_sample(
    input a,
    input b,
    input c,
    output out
    );
    assign out = (~a & b) | (~b & c);
endmodule
