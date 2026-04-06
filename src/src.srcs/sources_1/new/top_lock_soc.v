`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 03:28:48 PM
// Design Name: 
// Module Name: top_lock_soc
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


module top_lock_soc (
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,

    input  wire [15:0] SW,
    input  wire [4:0]  BTN,

    output wire [15:0] LED,

    output wire [6:0]  SEG,
    output wire [7:0]  AN,

    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire [3:0]  VGA_R,
    output wire [3:0]  VGA_G,
    output wire [3:0]  VGA_B
);

    wire reset;
    assign reset = ~CPU_RESETN;

    // CPU bus wires
    wire        mem_read;
    wire        mem_write;
    wire [15:0] addr;
    wire [15:0] write_data;
    wire [15:0] read_data;

    // MMIO output wires
    wire [15:0] leds;
    wire [15:0] sevenseg_value;
    wire [2:0]  vga_status;

    // ----------------------------
    // CPU
    // ----------------------------
    cpu_core cpu_inst (
        .clk(clk_cpu),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // ----------------------------
    // MMIO
    // ----------------------------
    memory_mapped_input_output mmio_inst (
        .clk(clk_cpu),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data),
        .switches(SW),
        .buttons(BTN),
        .leds(leds),
        .sevenseg_value(sevenseg_value),
        .vga_status(vga_status)
    );

    assign LED = leds;

    // ----------------------------
    // 7-segment driver
    // ----------------------------
    sevenseg_driver sevenseg_inst (
        .clk(CLK100MHZ),
        .reset(reset),
        .value(sevenseg_value),
        .seg(SEG),
        .an(AN)
    );

    // ----------------------------
    // VGA path
    // ----------------------------
    wire clk_25mhz;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire video_on;

    pixel_clock_gen clkgen_inst (
        .clk_in(CLK100MHZ),
        .reset(reset),
        .clk_out(clk_25mhz),
        .clk_cpu(clk_cpu)
    );

    vga_controller vga_ctrl_inst (
        .clk(clk_25mhz),
        .reset(reset),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    vga_status_display vga_disp_inst (
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .status(vga_status),
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B)
    );

endmodule
