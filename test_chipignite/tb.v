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
  reg [31:0] custom_settings;
  wire [35:0] io_in;
  wire [35:0] io_out;
  wire [35:0] io_oeb;

  wire [3:0]  controls_in;
  wire [7:0]  controls_out  = {io_out[34:32], io_out[5], io_out[3:0]};
  wire [15:0] addr          = {io_out[21:11], io_out[6], io_out[7], io_out[8], io_out[10], io_out[9]};

  assign {io_in[35], io_in[31:30], io_in[4]} = controls_in;

  // Z80 has a peculiar order of the pins for the data bus
  // <->     D4 7 |io[22]
  // <->     D3 8 |io[23]
  // <->     D5 9 |io[24]
  // <->     D6 10|io[25]
  //    VCC_5V0 11|      
  // <->     D2 12|io[26]
  // <->     D7 13|io[27]
  // <->     D0 14|io[29]
  // <->     D1 15|io[28]

  wire [7:0]  data_in;
  wire [7:0]  data_out;
  wire [7:0]  data_oe;

  assign io_in [22] = data_in[4];
  assign io_in [23] = data_in[3];
  assign io_in [24] = data_in[5];
  assign io_in [25] = data_in[6];
  assign io_in [26] = data_in[2];
  assign io_in [27] = data_in[7];
  assign io_in [29] = data_in[0];
  assign io_in [28] = data_in[1];

  assign data_out[4] = io_out[22];
  assign data_out[3] = io_out[23];
  assign data_out[5] = io_out[24];
  assign data_out[6] = io_out[25];
  assign data_out[2] = io_out[26];
  assign data_out[7] = io_out[27];
  assign data_out[0] = io_out[29];
  assign data_out[1] = io_out[28];

  assign data_oe [4] = ~io_oeb[22];
  assign data_oe [3] = ~io_oeb[23];
  assign data_oe [5] = ~io_oeb[24];
  assign data_oe [6] = ~io_oeb[25];
  assign data_oe [2] = ~io_oeb[26];
  assign data_oe [7] = ~io_oeb[27];
  assign data_oe [0] = ~io_oeb[29];
  assign data_oe [1] = ~io_oeb[28];

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
      .io_oeb (io_oeb),

      .custom_settings(custom_settings)
  );

endmodule
