`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 02:27:19 PM
// Design Name: 
// Module Name: mmio
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

// Opcode map reconstructed from the uploaded .circ ROM/program usage.
`define OP_LDI   4'h0
`define OP_LD    4'h1
`define OP_ST    4'h2
`define OP_ADD   4'h3
`define OP_SUB   4'h4
`define OP_AND   4'h5
`define OP_OR    4'h6
`define OP_CMP   4'h7
`define OP_JMP   4'h8
`define OP_JZ    4'h9
`define OP_JNZ   4'hA
`define OP_JN    4'hB
`define OP_NOP   4'hC
`define OP_HALT  4'hD
`define OP_XOR   4'hE
`define OP_PASS  4'hF

// Low MMIO addresses used by the extracted Logisim circuit/program.
`define ADDR_BT   9'h034
`define ADDR_SW   9'h035
`define ADDR_LED  9'h036
`define ADDR_RGB  9'h037
`define ADDR_SEG7 9'h038
`define ADDR_SEG6 9'h039
`define ADDR_SEG5 9'h03A
`define ADDR_SEG4 9'h03B
`define ADDR_SEG3 9'h03C
`define ADDR_SEG2 9'h03D
`define ADDR_SEG1 9'h03E
`define ADDR_SEG0 9'h03F

module mmio(
    input         clk,
    input         reset,
    input         ce,
    input         we,
    input  [8:0]  addr,
    input  [15:0] wdata,
    input  [15:0] switches,
    input  [4:0]  buttons,
    output reg [15:0] rdata,
    output reg        hit,
    output reg [15:0] led,
    output reg [2:0]  rgb,
    output reg [15:0] seg0,
    output reg [15:0] seg1,
    output reg [15:0] seg2,
    output reg [15:0] seg3,
    output reg [15:0] seg4,
    output reg [15:0] seg5,
    output reg [15:0] seg6,
    output reg [15:0] seg7
);
    wire [15:0] button_word;
    assign button_word = {11'b00000000000, buttons};

    always @(*) begin
        hit   = 1'b1;
        rdata = 16'h0000;
        case (addr)
            `ADDR_BT:   rdata = button_word;
            `ADDR_SW:   rdata = switches;
            `ADDR_LED:  rdata = led;
            `ADDR_RGB:  rdata = {13'b0000000000000, rgb};
            `ADDR_SEG7: rdata = seg7;
            `ADDR_SEG6: rdata = seg6;
            `ADDR_SEG5: rdata = seg5;
            `ADDR_SEG4: rdata = seg4;
            `ADDR_SEG3: rdata = seg3;
            `ADDR_SEG2: rdata = seg2;
            `ADDR_SEG1: rdata = seg1;
            `ADDR_SEG0: rdata = seg0;
            default: begin
                hit   = 1'b0;
                rdata = 16'h0000;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            led  <= 16'h0000;
            rgb  <= 3'b000;
            seg0 <= 16'h0000;
            seg1 <= 16'h0000;
            seg2 <= 16'h0000;
            seg3 <= 16'h0000;
            seg4 <= 16'h0000;
            seg5 <= 16'h0000;
            seg6 <= 16'h0000;
            seg7 <= 16'h0000;
        end else if (ce && we) begin
            case (addr)
                `ADDR_LED:  led  <= wdata;
                `ADDR_RGB:  rgb  <= wdata[2:0];
                `ADDR_SEG7: seg7 <= wdata;
                `ADDR_SEG6: seg6 <= wdata;
                `ADDR_SEG5: seg5 <= wdata;
                `ADDR_SEG4: seg4 <= wdata;
                `ADDR_SEG3: seg3 <= wdata;
                `ADDR_SEG2: seg2 <= wdata;
                `ADDR_SEG1: seg1 <= wdata;
                `ADDR_SEG0: seg0 <= wdata;
                default: begin
                    led <= led;
                end
            endcase
        end
    end
endmodule
