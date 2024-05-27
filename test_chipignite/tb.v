`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();
  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  wire [35:0] io_in;
  wire [35:0] io_out;
  wire [35:0] io_oeb;

  wire [3:0]  controls_in;
  wire [7:0]  controls_out  = io_out[7:0];
  wire [15:0] addr          = io_out[23:8];

  assign io_in [35:32] = controls_in;

  // Z80 has a peculiar order of the pins for the data bus
  //  <->     D4 | io[24]
  //  <->     D3 | io[25]
  //  <->     D5 | io[26]
  //  <->     D6 | io[27]
  //     VCC_5V0 |       
  //  <->     D2 | io[28]
  //  <->     D7 | io[29]
  //  <->     D0 | io[30]
  //  <->     D1 | io[31]

  wire [7:0]  data_in;
  wire [7:0]  data_out;
  wire [7:0]  data_oe;

  assign io_in [24] = data_in[4];
  assign io_in [25] = data_in[3];
  assign io_in [26] = data_in[5];
  assign io_in [27] = data_in[6];
  assign io_in [28] = data_in[2];
  assign io_in [29] = data_in[7];
  assign io_in [30] = data_in[0];
  assign io_in [31] = data_in[1];

  assign data_out[4] = io_out[24];
  assign data_out[3] = io_out[25];
  assign data_out[5] = io_out[26];
  assign data_out[6] = io_out[27];
  assign data_out[2] = io_out[28];
  assign data_out[7] = io_out[29];
  assign data_out[0] = io_out[30];
  assign data_out[1] = io_out[31];

  assign data_oe [4] = ~io_oeb[24];
  assign data_oe [3] = ~io_oeb[25];
  assign data_oe [5] = ~io_oeb[26];
  assign data_oe [6] = ~io_oeb[27];
  assign data_oe [2] = ~io_oeb[28];
  assign data_oe [7] = ~io_oeb[29];
  assign data_oe [0] = ~io_oeb[30];
  assign data_oe [1] = ~io_oeb[31];

  // Replace tt_um_example with your module name:
  ci2406_z80 user_project (
      // Include power ports for the Gate Level test:
`ifdef USE_POWER_PINS
      .vccd1  (1'b1),
      .vssd1  (1'b0),
`endif
      .wb_clk_i(clk),     // clock
      .rst_n  (rst_n),    // not reset
      .io_in  (io_in),
      .io_out (io_out),
      .io_oeb (io_oeb)
  );

endmodule
