`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_RISC_CPU_top_button_map
//
// Purpose:
//   Verifies the board-facing top module's button packing order.
//
// Why this matters:
//   The ROM lock program expects the MMIO button register to use this order:
//      bit0 = Right
//      bit1 = Down
//      bit2 = Left
//      bit3 = Up
//      bit4 = Center
//
//   The physical Nexys A7 button ports are named BTNC, BTNU, BTND, BTNL, BTNR.
//   This testbench checks that the top module converts those physical pins into
//   the internal button order expected by the CPU program.
//
// Note:
//   This is a small white-box testbench. It reads dut.btn_async directly because
//   btn_async is an internal wire in the top module.
//////////////////////////////////////////////////////////////////////////////////

module tb_RISC_CPU_top_button_map;
    // Board-level inputs
    reg CLK100MHZ;
    reg CPU_RESETN;
    reg [15:0] SW;
    reg BTNC;
    reg BTNU;
    reg BTND;
    reg BTNL;
    reg BTNR;

    // Board-level outputs
    wire [15:0] LED;
    wire LED16_B;
    wire LED16_G;
    wire LED16_R;
    wire [7:0] AN;
    wire CA;
    wire CB;
    wire CC;
    wire CD;
    wire CE;
    wire CF;
    wire CG;
    wire DP;

    integer errors;

    RISC_CPU dut (
        .CLK100MHZ (CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .SW        (SW),
        .BTNC      (BTNC),
        .BTNU      (BTNU),
        .BTND      (BTND),
        .BTNL      (BTNL),
        .BTNR      (BTNR),
        .LED       (LED),
        .LED16_B   (LED16_B),
        .LED16_G   (LED16_G),
        .LED16_R   (LED16_R),
        .AN        (AN),
        .CA        (CA),
        .CB        (CB),
        .CC        (CC),
        .CD        (CD),
        .CE        (CE),
        .CF        (CF),
        .CG        (CG),
        .DP        (DP)
    );

    // 100 MHz simulation clock.
    initial begin
        CLK100MHZ = 1'b0;
    end

    always begin
        #5 CLK100MHZ = ~CLK100MHZ;
    end

    // Apply physical button values and check the internal packed button bus.
    task check_btn_async;
        input center;
        input up;
        input down;
        input left;
        input right;
        input [4:0] expected;
        begin
            BTNC = center;
            BTNU = up;
            BTND = down;
            BTNL = left;
            BTNR = right;
            #1;

            if (dut.btn_async !== expected) begin
                $display("FAIL button map C/U/D/L/R=%b%b%b%b%b expected internal=%b got=%b",
                         center, up, down, left, right, expected, dut.btn_async);
                errors = errors + 1;
            end else begin
                $display("PASS button map C/U/D/L/R=%b%b%b%b%b -> internal=%b",
                         center, up, down, left, right, dut.btn_async);
            end
        end
    endtask

    initial begin
        $display("\n--- Starting tb_RISC_CPU_top_button_map ---");

        errors     = 0;
        CPU_RESETN = 1'b0;
        SW         = 16'h0000;
        BTNC       = 1'b0;
        BTNU       = 1'b0;
        BTND       = 1'b0;
        BTNL       = 1'b0;
        BTNR       = 1'b0;

        repeat (2) @(posedge CLK100MHZ);
        CPU_RESETN = 1'b1;

        // Expected internal ROM button order:
        // bit0=Right, bit1=Down, bit2=Left, bit3=Up, bit4=Center.
        check_btn_async(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 5'b00001); // right
        check_btn_async(1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 5'b00010); // down
        check_btn_async(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 5'b00100); // left
        check_btn_async(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b01000); // up
        check_btn_async(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 5'b10000); // center
        check_btn_async(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 5'b11111); // all buttons

        if (errors == 0) begin
            $display("tb_RISC_CPU_top_button_map PASSED");
        end else begin
            $display("tb_RISC_CPU_top_button_map FAILED with %0d error(s)", errors);
        end

        $finish;
    end
endmodule
