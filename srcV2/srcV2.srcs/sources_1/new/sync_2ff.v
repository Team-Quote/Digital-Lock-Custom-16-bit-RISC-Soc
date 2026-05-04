`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// sync_2ff.v
// -----------------------------------------------------------------------------
// Generic two-flip-flop synchronizer.
//
// Physical inputs such as push buttons and switches are asynchronous relative
// to the FPGA clock. Sampling them directly can cause metastability. Passing
// them through two flip-flops greatly reduces that risk before the CPU reads
// them through MMIO.
//
// WIDTH lets this same module synchronize a single bit or a bus.
// -----------------------------------------------------------------------------

module sync_2ff #(parameter WIDTH = 1)(
    input              clk,       // Destination clock domain
    input  [WIDTH-1:0] async_in,  // Asynchronous input signal(s)
    output [WIDTH-1:0] sync_out   // Synchronized output signal(s)
);
    reg [WIDTH-1:0] meta_reg;     // First stage, may briefly go metastable
    reg [WIDTH-1:0] sync_reg;     // Second stage, stable signal for logic

    always @(posedge clk) begin
        meta_reg <= async_in;
        sync_reg <= meta_reg;
    end

    assign sync_out = sync_reg;
endmodule
