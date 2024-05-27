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
  wire [7:0]  data_in;
  wire [7:0]  data_out      = io_out[31:24];
  wire [7:0]  data_oe       =~io_oeb[31:24];
  assign io_in [35:32] = controls_in;
  assign io_in [31:24] = data_in;
  
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
