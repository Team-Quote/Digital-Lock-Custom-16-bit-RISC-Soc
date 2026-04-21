`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Amin Rezaei
// Create Date: 09/30/2020 05:10:12 PM
// Design Name: 361 Sample 4
// Module Name: function_sample_tb2
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module function_sample_tb2(
    );
    // Create registers and wires and variables
    reg a_tb, b_tb, c_tb, result;
    wire out_tb;
    integer i;
   
    // Duration for each bit        
    localparam period = 20;
            
    // Instantiate the module
    function_sample uut(.a(a_tb), .b(b_tb), .c(c_tb), .out(out_tb));
    
    initial begin        
        for(i = 0; i < 8; i = i + 1) begin
            {a_tb, b_tb, c_tb} = i;
            result = (~a_tb & b_tb) | (~b_tb & c_tb);
            #period;
            if(result == out_tb) begin
                $display(a_tb, b_tb, c_tb, " passed.");
            end else begin
                $display(a_tb, b_tb, c_tb, " failed.");
            end
        end
        $finish;
    end
endmodule
