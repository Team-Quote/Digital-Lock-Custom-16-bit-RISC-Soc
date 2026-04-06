`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:28:48 PM
// Design Name: 
// Module Name: sevenseg_driver
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


module sevenseg_driver (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] value,
    output reg  [6:0]  seg,
    output reg  [7:0]  an
);

    reg [19:0] refresh_counter;
    reg [2:0]  digit_select;
    reg [3:0]  digit_value;

    always @(posedge clk or posedge reset) begin
        if (reset)
            refresh_counter <= 20'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    always @(*) begin
        digit_select = refresh_counter[19:17];
    end

    always @(*) begin
        an = 8'b11111111;
        case (digit_select)
            3'd0: begin an = 8'b11111110; digit_value = value[3:0];   end
            3'd1: begin an = 8'b11111101; digit_value = value[7:4];   end
            3'd2: begin an = 8'b11111011; digit_value = value[11:8];  end
            3'd3: begin an = 8'b11110111; digit_value = value[15:12]; end
            default: begin an = 8'b11111111; digit_value = 4'h0; end
        endcase
    end

    always @(*) begin
        case (digit_value)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

endmodule