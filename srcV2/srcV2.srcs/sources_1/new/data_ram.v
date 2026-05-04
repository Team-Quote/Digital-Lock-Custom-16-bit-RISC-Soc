`timescale 1ns / 1ps

module data_ram #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 16)(
    input                       clk,
    input                       reset,
    input                       ce,
    input                       we,
    input  [ADDR_WIDTH-1:0]     addr,
    input  [DATA_WIDTH-1:0]     wdata,
    output [DATA_WIDTH-1:0]     rdata
);
    reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
                ram[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (ce && we) begin
            ram[addr] <= wdata;
        end
    end

    // Combinational read, synchronous write.
    assign rdata = ram[addr];
endmodule
