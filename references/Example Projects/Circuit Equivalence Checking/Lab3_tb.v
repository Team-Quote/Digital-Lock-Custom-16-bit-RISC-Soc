`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2026 08:34:58 AM
// Design Name: 
// Module Name: Lab3_tb
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


module Lab3_tb();
reg a_tb,b_tb,c_tb,d_tb,e_tb;
wire out_tb;
integer i;

Lab3 uut (.A(a_tb), .B(b_tb), .C(c_tb), .D(d_tb), .E(e_tb), .Out(out_tb));

initial begin
    // test all cases one by one or better use of loops
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
