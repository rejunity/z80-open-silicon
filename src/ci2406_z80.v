/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ci2406_z80(
`ifdef USE_POWER_PINS
    inout wire          vccd1,	    // User area 1 1.8V supply
    inout wire          vssd1,	    // User area 1 digital ground
`endif
    input  wire         wb_clk_i,   // Clock input (you can also use an input pin as a custom clock pin and ignore this)
    input  wire         rst_n,      // Active low

                                    // Be careful with io_in/out/oeb[2:0] - these are assigned to the management controller on power-up
                                    // They may behave eratically until the firmware can assign them to your project
                                    // It is recommended to use them as outputs only
    input  wire [35:0]  io_in,
    output wire [35:0]  io_out,
    output wire [35:0]  io_oeb,     // Output Enable Bar ; 0 = Output, 1 = Input

                                    // Custom settings register, settable over mgmt controller firmware
    input  wire [31:0]  custom_settings
);
    wire z80_clk =  wb_clk_i;
    wire ena =      1'b1;

    // I took ChipIgnite "ASIC pinout" as a reference from the https://github.com/efabless/clear/tree/RTL-dev
    // Hope to map to Z80 pins with minimal wire crossing.

    // Also to double-check the ZX spectrum schematics might be useful:
    // https://spectrumforeveryone.com/wp-content/uploads/2017/08/ZXSpectrumIssue2-Schematics.gif

    // Assigning pins in Counter Clockwise order:
    //   Z80) starting roughly from a bottom left corner, pin 18 (/HALT).
    //   CI) starting from a bottom right corner, pin 31 (mprj_io[0]).
    // Also:
    //   1) need to use CI mprj_io[0..2] pins as output and preferrably for rarely used HALT, BUSAK, M1 signals
    //   2) Z80 data bus pin order is "scrambled"

    //                                 Z80 CPU
    // 1st attempt:
    //                 ,----------------.___.----------------.
    //      <--    A11 |1  - io[19] 57         55 io[18] - 40| A10    -->
    //      <--    A12 |2  - io[20] 58         54 io[17] - 39| A9     -->
    //      <--    A13 |3  - io[21] 59         53 io[16] - 38| A8     -->
    //      <--    A14 |4  - io[22] 60         51 io[15] - 37| A7     -->
    //      <--    A15 |5  - io[23] 61         50 io[14] - 36| A6     -->
    //      -->    CLK |6  -  xclk  22(?)      48 io[13] - 35| A5     -->
    //      <->     D4 |7  - io[24] 62         46 io[12] - 34| A4     -->
    //      <->     D3 |8  - io[25]  2         45 io[11] - 33| A3     -->
    //      <->     D5 |9  - io[26]  3         44 io[10] - 32| A2     -->
    //      <->     D6 |10 - io[27]  4         43 io[9]  - 31| A1     -->
    //         VCC_5V0 |11                     42 io[8]  - 30| A0     -->
    //      <->     D2 |12 - io[28]  5                     29| GND
    //      <->     D7 |13 - io[29]  6         41 io[7]  - 28| /RFSH  -->
    //      <->     D0 |14 - io[30]  7         33 io[2]  - 27| /M1    -->
    //      <->     D1 |15 - io[31]  8      (?)21  rst   - 26| /RESET <--
    //      -->   /INT |16 - io[32] 11         14 io[35] - 25| /BUSRQ <--
    //      -->   /NMI |17 - io[33] 12         13 io[34] - 24| /WAIT  <--
    //      <--  /HALT |18 - io[0]  31         32 io[1]  - 23| /BUSAK -->
    //      <--  /MREQ |19 - io[3]  34         37 io[6]  - 22| /WR    -->
    //      <--  /IORQ |20 - io[4]  35         36 io[5]  - 21| /RD    -->
    //                 `-------------------------------------'
    // 

    // 2nd revised:
    //                 ,----------------.___.----------------.
    //      <--    A11 |1  - io[19] 57         55 io[18] - 40| A10    -->
    //      <--    A12 |2  - io[20] 58         54 io[17] - 39| A9     -->
    //      <--    A13 |3  - io[21] 59         53 io[16] - 38| A8     -->
    //      <--    A14 |4  - io[22] 60         51 io[15] - 37| A7     -->
    //      <--    A15 |5  - io[23] 61        >50 io[14] - 36| A6     -->
    //      -->    CLK |6  -  xclk  22--      >48 io[13] - 35| A5     -->
    //      <->     D4 |7  - io[24] 62<        46 io[12] - 34| A4     -->
    //      <->     D3 |8  - io[25]  2<        45 io[11] - 33| A3     -->
    //      <->     D5 |9  - io[26]  3         44 io[10] - 32| A2     -->
    //      <->     D6 |10 - io[27]  4         43 io[9]  - 31| A1     -->
    //         VCC_5V0 |11                     42 io[8]  - 30| A0     -->
    //      <->     D2 |12 - io[28]  5                     29| GND
    //      <->     D7 |13 - io[29]  6         41 io[7]  - 28| /RFSH  -->
    //      <->     D0 |14 - io[30]  7       --33 io[2]  - 27| /M1    -->
    //      <->     D1 |15 - io[31]  8       --21  rst   - 26| /RESET <--
    //      -->   /INT |16 - io[32] 11       * 37 io[6]  - 25| /BUSRQ <--
    //      -->   /NMI |17 - io[33] 12       * 36 io[5]  - 24| /WAIT  <--
    //      <--  /HALT |18 - io[0]  31--     --32 io[1]  - 23| /BUSAK -->
    //      <--  /MREQ |19 - io[34] 13 *     * 35 io[4]  - 22| /WR    -->
    //      <--  /IORQ |20 - io[35] 14<*     * 34 io[3]  - 21| /RD    -->
    //                 `-------------------------------------'
    //
    //      GND     29 --- vss* [56,52,38,39,29,23,20,10,1]
    //      VCC_5V0 11 --- vddio [64,17]
    //      VCC_3V3 xx --- vdda1, vdda2 [47,40,30,9]
    //      VCC_1V8 xx --- vccd, vccd1, vccd2 [63,49,18]
    
    // @TODO: float A, D on reset
    // @TODO: float A, D, MREQ, RD, WR, IORQ pins on BUSAK (Figure 10 BUS Request/Acknowledge Cycle)

    // 8 output control pins
    assign {io_oeb[35:34], io_oeb[7], io_oeb[4:0]}
                                        = { 8{1'b0}};   // 0 = Output

    // 16 output address bus pins
    assign io_oeb[23:8]                 = {16{1'b0}};   // 0 = Output

    // 8 bidirectional data bus pins
    assign io_oeb[31:24]                = {8{~data_oe}};// 0 = Output | 1 = Input

    // 4 input control pins
    assign {io_oeb[33:32], io_oeb[6:5]} = { 4{1'b1}};   // 1 = Input
    assign {io_out[33:32], io_out[6:5]} = { 4{1'b0}};   // Initialize otherwise undriven pins to 0

    wire data_oe;
    z80 z80 (
        .clk     (z80_clk),
        .cen     (ena),
        .reset_n (rst_n),
        .wait_n  (io_in [ 5]),
        .int_n   (io_in [32]),
        .nmi_n   (io_in [33]),
        .busrq_n (io_in [ 6]),
        // Z80 has peculiar data bus pin order, keep it to minimize wire crossing on the DIP40 PCB
        // Also see: http://www.righto.com/2014/09/why-z-80s-data-pins-are-scrambled.html
        //  D7 - io[29]
        //  D6 - io[27]
        //  D5 - io[26]
        //  D4 - io[24]
        //  D3 - io[25]
        //  D2 - io[28]
        //  D1 - io[31]
        //  D0 - io[30]
        .di      ({io_in [29], io_in [27], io_in [26], io_in [24], io_in [25], io_in [28], io_in [31], io_in [30]}),
        .dout    ({io_out[29], io_out[27], io_out[26], io_out[24], io_out[25], io_out[28], io_out[31], io_out[30]}),
        .doe     (data_oe),
        .A       (io_out[23:8]),
        .halt_n  (io_out[ 0]),
        .busak_n (io_out[ 1]),
        .m1_n    (io_out[ 2]),
        .mreq_n  (io_out[34]),
        .iorq_n  (io_out[35]),
        .rd_n    (io_out[ 3]),
        .wr_n    (io_out[ 4]),
        .rfsh_n  (io_out[ 7])
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
        .dout (dout),
        .write (doe)
    );

endmodule