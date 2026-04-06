`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 03:28:48 PM
// Design Name: 
// Module Name: memory_mapped_input_output
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


module memory_mapped_input_output(
    input  wire        clk,
    input  wire        reset,

    // CPU bus interface
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [15:0] addr,
    input  wire [15:0] write_data,
    output reg  [15:0] read_data,

    // Physical board inputs
    input  wire [15:0] switches,
    input  wire [4:0]  buttons,

    // Physical board outputs
    output reg  [15:0] leds,
    output reg  [15:0] sevenseg_value,
    output reg  [2:0]  vga_status
);

    // ----------------------------
    // Memory map
    // ----------------------------
    localparam ADDR_SWITCHES   = 16'h8000;
    localparam ADDR_BUTTONS    = 16'h8001;
    localparam ADDR_LEDS       = 16'h8002;
    localparam ADDR_7SEG       = 16'h8003;
    localparam ADDR_VGA_STATUS = 16'h8004;

    // ----------------------------
    // Write logic
    // ----------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            leds          <= 16'h0000;
            sevenseg_value <= 16'h0000;
            vga_status    <= 3'b000;
        end else if (mem_write) begin
            case (addr)
                ADDR_LEDS: begin
                    leds <= write_data;
                end

                ADDR_7SEG: begin
                    sevenseg_value <= write_data;
                end

                ADDR_VGA_STATUS: begin
                    vga_status <= write_data[2:0];
                end

                default: begin
                    // no write action
                end
            endcase
        end
    end

    // ----------------------------
    // Read logic
    // ----------------------------
    always @(*) begin
        read_data = 16'h0000;

        if (mem_read) begin
            case (addr)
                ADDR_SWITCHES: begin
                    read_data = switches;
                end

                ADDR_BUTTONS: begin
                    read_data = {11'b0, buttons};
                end

                ADDR_LEDS: begin
                    read_data = leds;
                end

                ADDR_7SEG: begin
                    read_data = sevenseg_value;
                end

                ADDR_VGA_STATUS: begin
                    read_data = {13'b0, vga_status};
                end

                default: begin
                    read_data = 16'h0000;
                end
            endcase
        end
    end

endmodule
