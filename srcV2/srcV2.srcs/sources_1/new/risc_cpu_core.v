`timescale 1ns / 1ps

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

module risc_cpu_core(
    input         clk,
    input         reset,
    input         ce,
    input  [15:0] switches,
    input  [4:0]  buttons,
    output [15:0] led,
    output [2:0]  rgb,
    output [15:0] seg0,
    output [15:0] seg1,
    output [15:0] seg2,
    output [15:0] seg3,
    output [15:0] seg4,
    output [15:0] seg5,
    output [15:0] seg6,
    output [15:0] seg7,
    output reg    halted,
    output [15:0] debug_pc,
    output [15:0] debug_instr,
    output        debug_z,
    output        debug_n
);
    reg [15:0] pc;
    wire [15:0] instr;

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs;
    wire [8:0] imm9;
    wire [11:0] addr12;

    reg [15:0] regs [0:7];
    wire [15:0] rd_val;
    wire [15:0] rs_val;

    wire [15:0] ram_rdata;
    wire [15:0] mmio_rdata;
    wire        mmio_hit;
    wire        store_instr;
    wire        ram_we;
    wire        mmio_we;
    wire [15:0] load_data;

    reg z_flag;
    reg n_flag;
    reg [15:0] next_pc;
    reg        next_halted;
    reg        reg_we;
    reg [15:0] reg_wdata;
    reg        flags_we;
    reg [15:0] flags_value;

    integer i;

    instr_rom #(.ROM_DEPTH(1024)) u_rom(
        .addr(pc),
        .instr(instr)
    );

    assign opcode = instr[15:12];
    assign rd     = instr[11:9];
    assign rs     = instr[8:6];
    assign imm9   = instr[8:0];
    assign addr12 = instr[11:0];

    // R0 is treated as a constant zero register.
    assign rd_val = (rd == 3'd0) ? 16'h0000 : regs[rd];
    assign rs_val = (rs == 3'd0) ? 16'h0000 : regs[rs];

    assign store_instr = (opcode == `OP_ST) && !halted;
    assign ram_we      = ce && store_instr && !mmio_hit;
    assign mmio_we     = ce && store_instr &&  mmio_hit;

    data_ram #(.ADDR_WIDTH(8), .DATA_WIDTH(16)) u_data_ram(
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .we(ram_we),
        .addr(imm9[7:0]),
        .wdata(rd_val),
        .rdata(ram_rdata)
    );

    mmio u_mmio(
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .we(mmio_we),
        .addr(imm9),
        .wdata(rd_val),
        .switches(switches),
        .buttons(buttons),
        .rdata(mmio_rdata),
        .hit(mmio_hit),
        .led(led),
        .rgb(rgb),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7)
    );

    assign load_data = mmio_hit ? mmio_rdata : ram_rdata;

    always @(*) begin
        next_pc     = pc + 16'h0001;
        next_halted = halted;
        reg_we      = 1'b0;
        reg_wdata   = 16'h0000;
        flags_we    = 1'b0;
        flags_value = 16'h0000;

        case (opcode)
            `OP_LDI: begin
                reg_we      = 1'b1;
                reg_wdata   = {7'b0000000, imm9};
                flags_we    = 1'b1;
                flags_value = {7'b0000000, imm9};
            end

            `OP_LD: begin
                reg_we      = 1'b1;
                reg_wdata   = load_data;
                flags_we    = 1'b1;
                flags_value = load_data;
            end

            `OP_ST: begin
                // Store side effect occurs in data_ram or mmio on this clock edge.
            end

            `OP_ADD: begin
                reg_we      = 1'b1;
                reg_wdata   = rd_val + rs_val;
                flags_we    = 1'b1;
                flags_value = rd_val + rs_val;
            end

            `OP_SUB: begin
                reg_we      = 1'b1;
                reg_wdata   = rd_val - rs_val;
                flags_we    = 1'b1;
                flags_value = rd_val - rs_val;
            end

            `OP_AND: begin
                reg_we      = 1'b1;
                reg_wdata   = rd_val & rs_val;
                flags_we    = 1'b1;
                flags_value = rd_val & rs_val;
            end

            `OP_OR: begin
                reg_we      = 1'b1;
                reg_wdata   = rd_val | rs_val;
                flags_we    = 1'b1;
                flags_value = rd_val | rs_val;
            end

            `OP_CMP: begin
                flags_we    = 1'b1;
                flags_value = rd_val - rs_val;
            end

            `OP_JMP: begin
                next_pc = {4'b0000, addr12};
            end

            `OP_JZ: begin
                if (z_flag) begin
                    next_pc = {4'b0000, addr12};
                end
            end

            `OP_JNZ: begin
                if (!z_flag) begin
                    next_pc = {4'b0000, addr12};
                end
            end

            `OP_JN: begin
                if (n_flag) begin
                    next_pc = {4'b0000, addr12};
                end
            end

            `OP_NOP: begin
                // Intentional no operation.
            end

            `OP_HALT: begin
                next_halted = 1'b1;
                next_pc     = pc;
            end

            `OP_XOR: begin
                reg_we      = 1'b1;
                reg_wdata   = rd_val ^ rs_val;
                flags_we    = 1'b1;
                flags_value = rd_val ^ rs_val;
            end

            `OP_PASS: begin
                reg_we      = 1'b1;
                reg_wdata   = rs_val;
                flags_we    = 1'b1;
                flags_value = rs_val;
            end

            default: begin
                // Undefined opcodes act as NOP.
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            pc      <= 16'h0000;
            halted  <= 1'b0;
            z_flag  <= 1'b0;
            n_flag  <= 1'b0;
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 16'h0000;
            end
        end else if (ce && !halted) begin
            pc     <= next_pc;
            halted <= next_halted;

            if (reg_we && rd != 3'd0) begin
                regs[rd] <= reg_wdata;
            end
            regs[0] <= 16'h0000;

            if (flags_we) begin
                z_flag <= (flags_value == 16'h0000);
                n_flag <= flags_value[15];
            end
        end
    end

    assign debug_pc    = pc;
    assign debug_instr = instr;
    assign debug_z     = z_flag;
    assign debug_n     = n_flag;
endmodule
