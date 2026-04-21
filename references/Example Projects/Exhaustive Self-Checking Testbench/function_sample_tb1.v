`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Amin Rezaei
// Create Date: 09/30/2020 04:01:51 PM
// Design Name: 361 Sample 4
// Module Name: function_sample_tb2
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module function_sample_tb1(
    );
    // Create registers and wires
    reg a_tb, b_tb, c_tb;
    wire out_tb;
        
    // Duration for each bit
    localparam period = 20;
        
    // Instantiate the module
    function_sample uut(.a(a_tb), .b(b_tb), .c(c_tb), .out(out_tb));
        
    initial begin
        a_tb = 0; b_tb= 0; c_tb= 0; #period;
        $display("000 %s", (out_tb == 0) ? "passed." :"failed.");
        a_tb = 1; b_tb= 0; c_tb= 1; #period;
        $display("101 %s", (out_tb == 1) ? "passed." :"failed.");
        a_tb = 1; b_tb= 1; c_tb= 0; #period;
        $display("110 %s", (out_tb == 0) ? "passed." :"failed.");
        a_tb = 1; b_tb= 1; c_tb= 1;
        $display("111 %s", (out_tb == 0) ? "passed." :"failed.");
        $finish;
    end
endmodule
