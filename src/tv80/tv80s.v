//
// TV80 8-Bit Microprocessor Core
// Based on the VHDL T80 core by Daniel Wallner (jesus@opencores.org)
//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

`define TV80_REFRESH 1

module tv80s (/*AUTOARG*/
  // Outputs
  m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n, A, dout, write,
  early_mreq_n, early_iorq_n, early_rd_n, early_wr_n, 
  // Inputs
  reset_n, clk, wait_n, int_n, nmi_n, busrq_n, di, cen
  );

  parameter Mode = 0;    // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter T2Write = 1; // 0 => wr_n active in T3, /=0 => wr_n active in T2
  parameter IOWait  = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle


  input         reset_n;
  input         clk;
  input         cen;
  input         wait_n;
  input         int_n;
  input         nmi_n;
  input         busrq_n;
  output        m1_n;
  output        mreq_n;
  output        iorq_n;
  output        rd_n;
  output        wr_n;

  output        early_mreq_n;
  output        early_iorq_n;
  output        early_rd_n;
  output        early_wr_n;

  output        rfsh_n;
  output        halt_n;
  output        busak_n;
  output [15:0] A;
  input [7:0]   di;
  output [7:0]  dout;

  reg           mreq_n;
  reg           iorq_n;
  reg           rd_n;
  reg           wr_n;

  reg           early_mreq_n;
  reg           early_iorq_n;
  reg           early_rd_n;
  reg           early_wr_n;

  wire          intcycle_n;
  wire          no_read;
  output wire   write;
  wire          iorq;
  reg [7:0]     di_reg;
  wire [6:0]    mcycle;
  wire [6:0]    tstate;


  tv80_core #(Mode, IOWait) i_tv80_core
    (
     .cen (cen),
     .m1_n (m1_n),
     .iorq (iorq),
     .no_read (no_read),
     .write (write),
     .rfsh_n (rfsh_n),
     .halt_n (halt_n),
     .wait_n (wait_n),
     .int_n (int_n),
     .nmi_n (nmi_n),
     .reset_n (reset_n),
     .busrq_n (busrq_n),
     .busak_n (busak_n),
     .clk (clk),
     .IntE (),
     .stop (),
     .A (A),
     .dinst (di),
     .di (di_reg),
     .dout (dout),
     .mc (mcycle),
     .ts (tstate),
     .intcycle_n (intcycle_n)
     );

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          rd_n   <= 1'b1;
          wr_n   <= 1'b1;
          iorq_n <= 1'b1;
          mreq_n <= 1'b1;
          di_reg <= 0;
        end
      else if(cen)
        begin
          rd_n <= 1'b1;
          wr_n <= 1'b1;
          iorq_n <= 1'b1;
          mreq_n <= 1'b1;
          if (mcycle[0])
            begin
              if (tstate[1] || (tstate[2] && wait_n == 1'b0))
                begin
                  rd_n <= ~ intcycle_n;
                  mreq_n <= ~ intcycle_n;
                  iorq_n <= intcycle_n;
                end
            `ifdef TV80_REFRESH
              if (tstate[3])
            mreq_n <= 1'b0;
            `endif
            end // if (mcycle[0])
          else
            begin
              if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && no_read == 1'b0 && write == 1'b0)
                begin
                  rd_n <= 1'b0;
                  iorq_n <= ~ iorq;
                  mreq_n <= iorq;
                end
              if (T2Write == 0)
                begin
                  if (tstate[2] && write == 1'b1)
                    begin
                      wr_n <= 1'b0;
                      iorq_n <= ~ iorq;
                      mreq_n <= iorq;
                    end
                end
              else
                begin
                  if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && write == 1'b1)
                    begin
                      wr_n <= 1'b0;
                      iorq_n <= ~ iorq;
                      mreq_n <= iorq;
                  end
                end // else: !if(T2write == 0)

            end // else: !if(mcycle[0])

          if (tstate[2] && wait_n == 1'b1)
            di_reg <= di;
        end // else: !if(!reset_n)
    end // always @ (posedge clk or negedge reset_n)

  always @(negedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          early_rd_n   <= 1'b1;
          early_wr_n   <= 1'b1;
          early_iorq_n <= 1'b1;
          early_mreq_n <= 1'b1;
        end
      else if(cen)
        begin
          early_rd_n <= 1'b1;
          early_wr_n <= 1'b1;
          early_iorq_n <= 1'b1;
          early_mreq_n <= 1'b1;
          if (mcycle[0])
            begin
              if (tstate[1] || (tstate[2] && wait_n == 1'b0))
                begin
                  early_rd_n <= ~ intcycle_n;
                  early_mreq_n <= ~ intcycle_n;
                  early_iorq_n <= intcycle_n;
                end
            `ifdef TV80_REFRESH
              if (tstate[3])
                early_mreq_n <= 1'b0;
            `endif
            end // if (mcycle[0])
          else
            begin
              if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && no_read == 1'b0 && write == 1'b0)
                begin
                  early_rd_n <= 1'b0;
                  early_iorq_n <= ~ iorq;
                  early_mreq_n <= iorq;
                end
              if (T2Write == 0)
                begin
                  if (tstate[2] && write == 1'b1)
                    begin
                      early_wr_n <= 1'b0;
                      early_iorq_n <= ~ iorq;
                      early_mreq_n <= iorq;
                    end
                end
              else
                begin
                  if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && write == 1'b1)
                    begin
                      early_wr_n <= 1'b0;
                      early_iorq_n <= ~ iorq;
                      early_mreq_n <= iorq;
                  end
                end // else: !if(T2write == 0)

            end // else: !if(mcycle[0])
        end // else: !if(!reset_n)
    end // always @ (posedge clk or negedge reset_n)

endmodule // t80s

