/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_rejunity_z80 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // We have to multiplex the 16 bits of (A) address bus and 8 control signals into
    // the 8 output pins that are available in TinyTapeout.
    wire  [7:0] ctrl_signals;
    wire [15:0] addr_bus;

    // Use mux_control to select between the address bus and control signals
    //   [00] --- {A0 - A7} 
    //   [01] --- {A8 - A15}
    //   [1?] --- control signals {m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n}

    wire z80_clk = clk;
    wire [1:0] mux_control = ui_in[7:6];
    assign uo_out = (mux_control[1] == 1) ? ctrl_signals :
                    (mux_control[0] == 0) ? addr_bus[7:0] :
                                            addr_bus[15:8];

    // Use early_signals_control to select half-cycle prolonged control signals
    //   [00] --- MREQ, IORQ, RD are short - 1 cycle
    //   [01] --- MREQ, IORQ, RD start 0.5 cycle earlier
    //   [10] --- MREQ, IORQ are 1.5 cycle long and start earlier
    //            RD is 1 cycle, but starts half cycle earlier
    //   [11] --- MREQ, IORQ, RD are 1.5 cycle long 
    //            and start 0.5 cycles earlier

    wire [1:0] early_signals_control = ui_in[5:4];
    
    wire doe; // Data Output Enable
    assign uio_oe  = {8{doe}}; // (active high: 0=input, 1=output)

    z80 z80 (
        .clk     (z80_clk),
        .cen     (ena),
        .reset_n (rst_n),
        .wait_n  (ui_in[0]),
        .int_n   (ui_in[1]),
        .nmi_n   (ui_in[2]),
        .busrq_n (ui_in[3]),
        .di      (uio_in),
        .dout    (uio_out),
        .doe     (doe),
        .A       (addr_bus),
        .m1_n    (ctrl_signals[0]),
        .mreq_n  (ctrl_signals[1]),
        .iorq_n  (ctrl_signals[2]),
        .rd_n    (ctrl_signals[3]),
        .wr_n    (ctrl_signals[4]),
        .rfsh_n  (ctrl_signals[5]),
        .halt_n  (ctrl_signals[6]),
        .busak_n (ctrl_signals[7]),

        .early_signals(early_signals_control)
    );
endmodule

module z80 (
    input  wire         clk,
    input  wire         cen,
    input  wire         reset_n,
    input  wire         wait_n,
    input  wire         int_n,
    input  wire         nmi_n,
    input  wire         busrq_n,

    input  wire [7:0]   di,
    output wire [7:0]   dout,
    output wire         doe,

    output wire [15:0]  A,
    output wire         m1_n,
    output wire         mreq_n,
    output wire         iorq_n,
    output wire         rd_n,
    output wire         wr_n,
    output wire         rfsh_n,
    output wire         halt_n,
    output wire         busak_n,

    input wire[1:0]     early_signals
);
    wire         normal_mreq_n;
    wire         normal_iorq_n;
    wire         normal_rd_n;
    wire         normal_wr_n;

    wire         early_mreq_n;
    wire         early_iorq_n;
    wire         early_rd_n;
    wire         early_wr_n;

    assign mreq_n = early_signals[1] ? (rfsh_n ? (early_mreq_n & normal_mreq_n) : early_mreq_n) :
                    early_signals[0] ?   early_mreq_n :
                                        normal_mreq_n;

    assign iorq_n = early_signals[1] ? (early_iorq_n & normal_iorq_n) :
                    early_signals[0] ?   early_iorq_n :
                                        normal_iorq_n;

    assign rd_n = (early_signals == 2'b00) ? normal_rd_n:
                  (early_signals == 2'b01) ?  early_rd_n:
                  (early_signals == 2'b10) ?  early_rd_n:
                              (early_rd_n & normal_rd_n);

    assign wr_n   =                     normal_wr_n;

    tv80s #(
        .Mode(0),   // Z80 mode
        .T2Write(1),// wr_n active in T2
        .IOWait(1)  // std I/O cycle
    ) tv80s (
        .reset_n (reset_n),
        .clk (clk),
        .cen (cen),
        .wait_n (wait_n),
        .int_n (int_n),
        .nmi_n (nmi_n),
        .busrq_n (busrq_n),
        .m1_n (m1_n),
        .mreq_n (normal_mreq_n),
        .iorq_n (normal_iorq_n),
        .rd_n (normal_rd_n),
        .wr_n (normal_wr_n),
        .early_mreq_n (early_mreq_n),
        .early_iorq_n (early_iorq_n),
        .early_rd_n (early_rd_n),
        .early_wr_n (early_wr_n),
        .rfsh_n (rfsh_n),
        .halt_n (halt_n),
        .busak_n (busak_n),
        .A (A),
        .di (di),
        .dout (dout),
        .write (doe) 
    );

endmodule