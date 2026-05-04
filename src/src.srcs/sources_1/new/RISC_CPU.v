`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 01:09:12 PM
// Design Name: 
// Module Name: RISC_CPU
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

module RISC_CPU(
    input         CLK100MHZ,
    input         CPU_RESETN,
    input  [15:0] SW,
    input         BTNC,
    input         BTNU,
    input         BTND,
    input         BTNL,
    input         BTNR,
    output [15:0] LED,
    output        LED16_B,
    output        LED16_G,
    output        LED16_R,
    output [7:0]  AN,
    output        CA,
    output        CB,
    output        CC,
    output        CD,
    output        CE,
    output        CF,
    output        CG,
    output        DP
    );
    wire reset;
    wire ce_cpu;
    wire [15:0] sw_sync;
    wire [4:0] btn_sync;
    wire [4:0] btn_async;
    wire [2:0] rgb;
    wire [6:0] seg_bus;
    wire [15:0] seg0;
    wire [15:0] seg1;
    wire [15:0] seg2;
    wire [15:0] seg3;
    wire [15:0] seg4;
    wire [15:0] seg5;
    wire [15:0] seg6;
    wire [15:0] seg7;
    wire halted_unused;
    wire [15:0] debug_pc_unused;
    wire [15:0] debug_instr_unused;
    wire debug_z_unused;
    wire debug_n_unused;

    // Nexys A7 CPU_RESETN is active-low. Internal reset is active-high.
    assign reset = ~CPU_RESETN;

    // Button register bit order expected by the extracted ROM:
    // bit0=Right, bit1=Down, bit2=Left, bit3=Up, bit4=Center/Enter.
    assign btn_async = {BTNC, BTNU, BTNL, BTND, BTNR};

    sync_2ff #(.WIDTH(16)) u_sw_sync(
        .clk(CLK100MHZ),
        .async_in(SW),
        .sync_out(sw_sync)
    );

    sync_2ff #(.WIDTH(5)) u_btn_sync(
        .clk(CLK100MHZ),
        .async_in(btn_async),
        .sync_out(btn_sync)
    );

    // 100 MHz / 50000 = 2000 CPU instructions/second.
    // Lower DIVISOR for faster execution after debugging.
    clock_enable #(.DIVISOR(50000)) u_cpu_ce(
        .clk(CLK100MHZ),
        .reset(reset),
        .ce(ce_cpu)
    );

    risc_cpu_core u_cpu(
        .clk(CLK100MHZ),
        .reset(reset),
        .ce(ce_cpu),
        .switches(sw_sync),
        .buttons(btn_sync),
        .led(LED),
        .rgb(rgb),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .halted(halted_unused),
        .debug_pc(debug_pc_unused),
        .debug_instr(debug_instr_unused),
        .debug_z(debug_z_unused),
        .debug_n(debug_n_unused)
    );

    sevenseg_scan u_sevenseg(
        .clk(CLK100MHZ),
        .reset(reset),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .an(AN),
        .seg(seg_bus),
        .dp(DP)
    );

    assign {CA, CB, CC, CD, CE, CF, CG} = seg_bus;

    // rgb[0]=blue, rgb[1]=green, rgb[2]=red.
    assign LED16_B = rgb[0];
    assign LED16_G = rgb[1];
    assign LED16_R = rgb[2];
endmodule

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

module instr_rom #(parameter ROM_DEPTH = 1024)(
    input  [15:0] addr,
    output reg [15:0] instr
);
    reg [15:0] rom [0:ROM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < ROM_DEPTH; i = i + 1) begin
            rom[i] = 16'hD000; // HALT by default past the program.
        end
        $readmemh("program.mem", rom);
    end

    always @(*) begin
        if (addr < ROM_DEPTH) begin
            instr = rom[addr];
        end else begin
            instr = 16'hD000;
        end
    end
endmodule

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

module clock_enable #(parameter DIVISOR = 500000)(
    input  clk,
    input  reset,
    output reg ce
);
    reg [31:0] ctr;

    always @(posedge clk) begin
        if (reset) begin
            ctr <= 32'd0;
            ce  <= 1'b0;
        end else if (DIVISOR <= 1) begin
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else if (ctr == (DIVISOR - 1)) begin
            ctr <= 32'd0;
            ce  <= 1'b1;
        end else begin
            ctr <= ctr + 32'd1;
            ce  <= 1'b0;
        end
    end
endmodule

module sync_2ff #(parameter WIDTH = 1)(
    input              clk,
    input  [WIDTH-1:0] async_in,
    output [WIDTH-1:0] sync_out
);
    reg [WIDTH-1:0] meta_reg;
    reg [WIDTH-1:0] sync_reg;

    always @(posedge clk) begin
        meta_reg <= async_in;
        sync_reg <= meta_reg;
    end

    assign sync_out = sync_reg;
endmodule

module sevenseg_scan #(parameter CLK_HZ = 100000000, parameter REFRESH_HZ = 1000)(
    input         clk,
    input         reset,
    input  [15:0] seg0,
    input  [15:0] seg1,
    input  [15:0] seg2,
    input  [15:0] seg3,
    input  [15:0] seg4,
    input  [15:0] seg5,
    input  [15:0] seg6,
    input  [15:0] seg7,
    output reg [7:0] an,
    output reg [6:0] seg,
    output reg       dp
);
    localparam TICKS_PER_DIGIT = CLK_HZ / (REFRESH_HZ * 8);
    localparam REFRESH_MAX = TICKS_PER_DIGIT - 1;

    reg [31:0] refresh_ctr;
    reg [2:0] digit_sel;
    reg [15:0] digit_code;
    wire [6:0] seg_active_high;

    always @(posedge clk) begin
        if (reset) begin
            refresh_ctr <= 32'd0;
            digit_sel   <= 3'd0;
        end else begin
            if (refresh_ctr == REFRESH_MAX) begin
                refresh_ctr <= 32'd0;
                digit_sel   <= digit_sel + 3'd1;
            end else begin
                refresh_ctr <= refresh_ctr + 32'd1;
            end
        end
    end

    always @(*) begin
        case (digit_sel)
            3'd0: digit_code = seg0;
            3'd1: digit_code = seg1;
            3'd2: digit_code = seg2;
            3'd3: digit_code = seg3;
            3'd4: digit_code = seg4;
            3'd5: digit_code = seg5;
            3'd6: digit_code = seg6;
            3'd7: digit_code = seg7;
            default: digit_code = 16'h0080;
        endcase
    end

    sevenseg_decode u_dec(
        .code(digit_code),
        .seg_active_high(seg_active_high)
    );

    always @(*) begin
        // Nexys A7 anodes and cathodes are active-low.
        an  = ~(8'b00000001 << digit_sel);
        seg = ~seg_active_high;
        dp  = 1'b1;
    end
endmodule

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
