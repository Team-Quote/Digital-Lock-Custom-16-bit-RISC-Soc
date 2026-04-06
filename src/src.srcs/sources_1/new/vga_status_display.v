`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:28:48 PM
// Design Name: 
// Module Name: vga_status_display
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


module vga_status_display (
    input  wire       video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [2:0] status,
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

    always @(*) begin
        if (!video_on) begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end else begin
            case (status)
                3'd0: begin // LOCKED
                    red   = 4'h0;
                    green = 4'h0;
                    blue  = 4'hF;
                end

                3'd1: begin // ENTER CODE
                    red   = 4'hF;
                    green = 4'hF;
                    blue  = 4'h0;
                end

                3'd2: begin // ACCESS GRANTED
                    red   = 4'h0;
                    green = 4'hF;
                    blue  = 4'h0;
                end

                3'd3: begin // ACCESS DENIED
                    red   = 4'hF;
                    green = 4'h0;
                    blue  = 4'h0;
                end

                3'd4: begin // LOCKOUT
                    red   = 4'hF;
                    green = 4'h0;
                    blue  = 4'hF;
                end

                default: begin
                    red   = 4'h0;
                    green = 4'h0;
                    blue  = 4'h0;
                end
            endcase
        end
    end

endmodule
