`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 10:09:27 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb();
reg a_tb, b_tb, c_tb, d_tb, e_tb;
wire out1_tb, out2_tb, eq_tb;
integer i;

top uut(.A(a_tb), .B(b_tb), .C(c_tb), .D(d_tb), .E(e_tb), .out1(out1_tb), .out2(out2_tb), .eq(eq_tb));

initial begin
    // You can either test all the cases one by one or find a better way using loops
    a_tb = 0;
    b_tb = 0; 
    c_tb = 0; 
    d_tb = 0; 
    e_tb = 0;
    
    
    for (i = 0; i < 32; i = i + 1) begin
    {a_tb, b_tb, c_tb, d_tb, e_tb} = i;
    #10;
    end
    $finish;
end
endmodule
