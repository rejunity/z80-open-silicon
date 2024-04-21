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
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // We have to multiplex the 16 bits of (A) address bus and 8 control signals into
    // the 8 output pins that are available in TinyTapeout.
    //
    // 1) TinyTapeout clock has to be divided by 4 to get the Z80 clock and
    // 2) Output pins see the following sequence:
    //   1st cycle --- control signals {m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n}
    //   2nd cycle --- {A0 - A7}
    //   3rd cycle --- repeated control signals
    //   4th cycle --- {A8 - A15}

    reg [1:0] clk_counter;
    always @(posedge clk)
        clk_counter <= (rst_n) ? clk_counter + 1 : 0;
    wire z80_clk = (rst_n) ? clk_counter[1:0] == 0: clk; // Z80 clock is pulsed once every 4 TinyTapeout clock cycles

    wire  [7:0] ctrl_signals;
    wire [15:0] addr_bus;
    assign uo_out = (clk_counter[0] == 0) ? ctrl_signals :
                    (clk_counter[1] == 0) ? addr_bus[7:0] :
                                            addr_bus[15:8];
    // always @(*) begin
    //     case(clk_counter[1:0])
    //         2'd0:  assign uo_out = ctrl_signals;
    //         2'd1:  assign uo_out = addr_bus[7:0];
    //         2'd2:  assign uo_out = ctrl_signals;
    //         2'd3:  assign uo_out = addr_bus[15:8];
    //     endcase
    // end
    
    wire wr = ~ctrl_signals[4];
    assign uio_oe  = {8{wr}}; // (active high: 0=input, 1=output)

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
        .A       (addr_bus),
        .m1_n    (ctrl_signals[0]),
        .mreq_n  (ctrl_signals[1]),
        .iorq_n  (ctrl_signals[2]),
        .rd_n    (ctrl_signals[3]),
        .wr_n    (ctrl_signals[4]),
        .rfsh_n  (ctrl_signals[5]),
        .halt_n  (ctrl_signals[6]),
        .busak_n (ctrl_signals[7])
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

    output wire [15:0]  A,
    output wire         m1_n,
    output wire         mreq_n,
    output wire         iorq_n,
    output wire         rd_n,
    output wire         wr_n,
    output wire         rfsh_n,
    output wire         halt_n,
    output wire         busak_n
);

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
        .mreq_n (mreq_n),
        .iorq_n (iorq_n),
        .rd_n (rd_n),
        .wr_n (wr_n),
        .rfsh_n (rfsh_n),
        .halt_n (halt_n),
        .busak_n (busak_n),
        .A (A),
        .di (di),
        .dout (dout)
    );

endmodule