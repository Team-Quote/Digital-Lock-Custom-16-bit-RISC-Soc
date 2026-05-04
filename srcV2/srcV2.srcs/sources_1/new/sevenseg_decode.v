`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 02:23:21 PM
// Design Name: 
// Module Name: sevenseg_decode
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


module sevenseg_decode(
    input  [15:0] code,
    output reg [6:0] seg_active_high
);
    always @(*) begin
        case (code)
            // Special display codes used by the .circ / ROM program.
            16'h0080: seg_active_high = 7'b0000000; // blank/off
            16'h0040: seg_active_high = 7'b0000001; // dash
            16'h00FF: seg_active_high = 7'b1111111; // all segments on

            // Letter-ish codes used by the ROM.
            16'h0067: seg_active_high = 7'b1100111; // P
            16'h0047: seg_active_high = 7'b1000111; // F

            default: begin
                case (code[3:0])
                    4'h0: seg_active_high = 7'b1111110;
                    4'h1: seg_active_high = 7'b0110000;
                    4'h2: seg_active_high = 7'b1101101;
                    4'h3: seg_active_high = 7'b1111001;
                    4'h4: seg_active_high = 7'b0110011;
                    4'h5: seg_active_high = 7'b1011011;
                    4'h6: seg_active_high = 7'b1011111;
                    4'h7: seg_active_high = 7'b1110000;
                    4'h8: seg_active_high = 7'b1111111;
                    4'h9: seg_active_high = 7'b1111011;
                    4'hA: seg_active_high = 7'b1110111;
                    4'hB: seg_active_high = 7'b0011111;
                    4'hC: seg_active_high = 7'b1001110;
                    4'hD: seg_active_high = 7'b0111101;
                    4'hE: seg_active_high = 7'b1001111;
                    4'hF: seg_active_high = 7'b1000111;
                    default: seg_active_high = 7'b0000000;
                endcase
            end
        endcase
    end
endmodule