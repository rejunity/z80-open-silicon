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
    //   1) caravel mprj_io[0] is reset, mprj_io[3] can not be used, mprj_io[0..1] must be output
    //   2) Z80 data bus order is "scrambled"
    
    //  CI Caravel mprj_io mapping to multiplxer's "design" ports io_in/out/oebp[]:
    // assign io_out = {design_out[35:2], wb_counter[25], design_out[1:0], 1'b0};
    // assign io_oeb = {design_oeb[35:2], 1'b0, design_oeb[1:0], 1'b1};


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
    // 3rd revision:
    //                 ,----------------.___.----------------.
    //      <--    A11 |1  - io[19] 57         55 io[18] - 40| A10    -->
    //      <--    A12 |2  - io[20] 58         54 io[17] - 39| A9     -->
    //      <--    A13 |3  - io[21] 59         53 io[16] - 38| A8     -->
    //      <--    A14 |4  - io[22] 60         51 io[15] - 37| A7     -->
    //      <--    A15 |5  - io[23] 61         50 io[14] - 36| A6     -->
    //      -->    CLK |6  -  xclk  22--       48 io[13] - 35| A5     -->
    //      <->     D4 |7  - io[24] 62       * 42 io[8]  - 34| A4     -->
    //      <->     D3 |8  - io[25]  2       * 43 io[9]  - 33| A3     -->
    //      <->     D5 |9  - io[26]  3         44 io[10] - 32| A2     -->
    //      <->     D6 |10 - io[27]  4       * 46 io[12] - 31| A1     -->
    //         VCC_5V0 |11                   * 45 io[11] - 30| A0     -->
    //      <->     D2 |12 - io[28]  5                     29| GND
    //      <->     D7 |13 - io[29]  6         41 io[7]  - 28| /RFSH  -->
    //      <->     D0 |14 - io[31]  8 *     --33 io[2]  - 27| /M1    -->
    //      <->     D1 |15 - io[30]  7 *     --21  rst   - 26| /RESET <--
    //      -->   /INT |16 - io[33] 12 *     * 34 io[3]  - 25| /BUSRQ <--
    //      -->   /NMI |17 - io[32] 11 *     * 37 io[6]  - 24| /WAIT  <--
    //      <--  /HALT |18 - io[0]  31--     --32 io[1]  - 23| /BUSAK -->
    //      <--  /MREQ |19 - io[34] 13       * 36 io[5]  - 22| /WR    -->
    //      <--  /IORQ |20 - io[35] 14       * 35 io[4]  - 21| /RD    -->
    //                 `-------------------------------------'
    //
    // 4th revision:
    // c[]  - caravel mprj_io[] pin
    // io[] - multiplexer's io_in/out/oebp[] port
    //                   ,----------------.___.----------------.
    //      <--    A11 1 |io[17] c[19] 57       55 c[18] io[16]|40 A10    -->
    //      <--    A12 2 |io[18] c[20] 58       54 c[17] io[15]|39 A9     -->
    //      <--    A13 3 |io[29] c[21] 59       53 c[16] io[14]|38 A8     -->
    //      <--    A14 4 |io[20] c[22] 60       51 c[15] io[13]|37 A7     -->
    //      <--    A15 5 |io[21] c[23] 61       50 c[14] io[12]|36 A6     -->
    //      -->    CLK 6 |------ ocs_o 22       48 c[13] io[11]|35 A5     -->
    //      <->     D4 7 |io[22] c[24] 62       42 c[ 8] io[ 6]|34 A4     -->
    //      <->     D3 8 |io[23] c[25]  2       43 c[ 9] io[ 7]|33 A3     -->
    //      <->     D5 9 |io[24] c[26]  3       44 c[10] io[ 8]|32 A2     -->
    //      <->     D6 10|io[25] c[27]  4       46 c[12] io[10]|31 A1     -->
    //         VCC_5V0 11|                      45 c[11] io[ 9]|30 A0     -->
    //      <->     D2 12|io[26] c[28]  5                      |29 GND
    //      <->     D7 13|io[27] c[29]  6       41 c[ 7] io[ 5]|28 /RFSH  -->
    //      <->     D0 14|io[29] c[31]  8       33 c[ 2] io[*1]|27 /M1    -->
    //      <->     D1 15|io[28] c[30]  7 *-  * 31 c[ 0] ------|26 /RESET <--
    //      -->   /INT 16|io[31] c[33] 12     * 16 c[37] io[35]|25 /BUSRQ <--
    //      -->   /NMI 17|io[30] c[32] 11 *-    37 c[ 6] io[ 4]|24 /WAIT  <--
    //      <--  /HALT 18|io[34] c[36] 15 *     32 c[ 1] io[*0]|23 /BUSAK -->
    //      <--  /MREQ 19|io[32] c[34] 13       36 c[ 5] io[ 3]|22 /WR    -->
    //      <--  /IORQ 20|io[33] c[35] 14       35 c[ 4] io[ 2]|21 /RD    -->
    //                   `-------------------------------------'
    //     /BUSAK, /M1 --- io[cl-1]
    //     *           --- io[cl-2]

    //      output     --- io[0..3, 5..21, 32..34]
    //      input      --- io[4,30,31,35] (/WAIT, /NMI, /INT, /BUSRQ)
    //      bidir      --- io[22,23,24,25,26,27,28,29]

    // 5th revision:
    // c[]  - caravel mprj_io[] pin
    // io[] - multiplexer's io_in/out/oebp[] port
    //                   ,----------------.___.----------------.
    //      <--    A11 1 |io[17] c[19] 57       55 c[18] io[16]|40 A10    -->
    //      <--    A12 2 |io[18] c[20] 58       54 c[17] io[15]|39 A9     -->
    //      <--    A13 3 |io[29] c[21] 59       53 c[16] io[14]|38 A8     -->
    //      <--    A14 4 |io[20] c[22] 60       51 c[15] io[13]|37 A7     -->
    //      <--    A15 5 |io[21] c[23] 61       50 c[14] io[12]|36 A6     -->
    //      -->    CLK 6 |------ ocs_o 22       48 c[13] io[11]|35 A5     -->
    //      <->     D4 7 |io[22] c[24] 62       42 c[ 8] io[ 6]|34 A4     -->
    //      <->     D3 8 |io[23] c[25]  2       43 c[ 9] io[ 7]|33 A3     -->
    //      <->     D5 9 |io[24] c[26]  3       44 c[10] io[ 8]|32 A2     -->
    //      <->     D6 10|io[25] c[27]  4       46 c[12] io[10]|31 A1     -->
    //         VCC_5V0 11|                      45 c[11] io[ 9]|30 A0     -->
    //      <->     D2 12|io[26] c[28]  5                      |29 GND
    //      <->     D7 13|io[27] c[29]  6       41 c[ 7] io[ 5]|28 /RFSH  -->
    //      <->     D0 14|io[29] c[31]  8       33 c[ 2] io[*1]|27 /M1    -->
    //      <->     D1 15|io[28] c[30]  7       31 c[ 0] ------|26 /RESET <--
    //      -->   /INT 16|io[31] c[33] 12       16 c[37] io[35]|25 /BUSRQ <--
    //      -->   /NMI 17|io[30] c[32] 11       37 c[ 6] io[ 4]|24 /WAIT  <--
    //      <--  /HALT 18|io[32] c[34] 13 *     32 c[ 1] io[*0]|23 /BUSAK -->
    //      <--  /MREQ 19|io[33] c[35] 14 *     36 c[ 5] io[ 3]|22 /WR    -->
    //      <--  /IORQ 20|io[34] c[36] 15 *     35 c[ 4] io[ 2]|21 /RD    -->
    //                   `-------------------------------------'
    //     /BUSAK, /M1 --- io[cl-1]
    //     *           --- io[cl-2]

    //      output     --- io[0..3, 5, 32..34] (/BUSAK, /M1, /RD, /WR, /RFSH, /HALT, /MREQ, /IORQ)
    //      output A   --- io[6..21]
    //      input      --- io[4,30,31,35] (/WAIT, /NMI, /INT, /BUSRQ)
    //      bidir      --- io[22,23,24,25,26,27,28,29]

    //      GND     29 --- vss* [56,52,38,39,29,23,20,10,1]
    //     (GND?)   29 --- vdda1, vdda2 [47,40,30,9]
    //      VCC_5V0 11 --- vddio [64,17]
    //      VCC_1V8 xx --- vccd, vccd1, vccd2 [63,49,18]
    //    VCC_1V8_R xx --- io_3_csb [34]


    
    // @TODO: float A, D on reset
    // @TODO: float A, D, MREQ, RD, WR, IORQ pins on BUSAK (Figure 10 BUS Request/Acknowledge Cycle)

    // 8 output control pins
    assign {io_oeb[34:32], io_oeb[5], io_oeb[3:0]}
                                        = { 8{1'b0}};   // 0 = Output

    // 16 output address bus pins
    assign io_oeb[21:6]                 = {16{1'b0}};   // 0 = Output

    // 8 bidirectional data bus pins
    assign io_oeb[29:22]                = {8{~data_oe}};// 0 = Output | 1 = Input

    // 4 input control pins
    assign {io_oeb[35], io_oeb[31:30], io_oeb[4]} = {4{1'b1}};   // 1 = Input
    assign {io_oeb[35], io_out[31:30], io_out[4]} = {4{1'b0}};   // Initialize otherwise undriven pins to 0

    wire data_oe;
    z80 z80 (
        .clk     (z80_clk),
        .cen     (ena),
        .reset_n (rst_n),
        .wait_n  (io_in [ 4]),
        .int_n   (io_in [31]),
        .nmi_n   (io_in [30]),
        .busrq_n (io_in [35]),
        // Z80 has peculiar data bus pin order, keep it to minimize wire crossing on the DIP40 PCB
        // Also see: http://www.righto.com/2014/09/why-z-80s-data-pins-are-scrambled.html

        // D7 io[27]
        // D6 io[25]
        // D5 io[24]
        // D4 io[22]
        // D3 io[23]
        // D2 io[26]
        // D1 io[28]
        // D0 io[29]
        .di      ({io_in [27], io_in [25], io_in [24], io_in [22], io_in [23], io_in [26], io_in [28], io_in [29]}),
        .dout    ({io_out[27], io_out[25], io_out[24], io_out[22], io_out[23], io_out[26], io_out[28], io_out[29]}),
        .doe     (data_oe),

        // io[21] - A15
        // ...
        // io[11] - A5
        // io[6]  - A4
        // io[7]  - A3
        // io[8]  - A2
        // io[10] - A1
        // io[9]  - A0

        .A       ({io_out[21:11], io_out[6], io_out[7], io_out[8], io_out[10], io_out[9]}),

    //                                                 io[ 5]| /RFSH  -->
    //                                                 io[*1]| /M1    -->
    //                                                  ...
    //      <--  /HALT |io[32]                         io[*0]| /BUSAK -->
    //      <--  /MREQ |io[33]                         io[ 3]| /WR    -->
    //      <--  /IORQ |io[34]                         io[ 2]| /RD    -->
    //                 `-------------------------------------'

        .halt_n  (io_out[32]),
        .busak_n (io_out[ 0]),
        .m1_n    (io_out[ 1]),
        .mreq_n  (io_out[33]),
        .iorq_n  (io_out[34]),
        .rd_n    (io_out[ 2]),
        .wr_n    (io_out[ 3]),
        .rfsh_n  (io_out[ 5])
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