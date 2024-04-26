<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

On April 15 of 2024 Zilog has [announced End-of-Life](https://www.mouser.com/PCN/Littelfuse_PCN_Z84C00.pdf) for Z80, one of the most famous 8-bit CPUs of all time. It is a time for open-source and hardware preservation community to step in with a Free and Open Source Silicon (FOSS) replacement for Zilog Z80.

The implementation is based around Guy Hutchison's [TV80](https://github.com/hutch31/tv80) Verilog core.

**The future work**
* Add thorough instruction (including 'illegal') execution tests [ZEXALL](https://mdfs.net/Software/Z80/Exerciser/) to testbench
* Compare different implementations: Verilog core [A-Z80](https://github.com/gdevic/A-Z80), Netlist based [Z80Explorer](https://github.com/gdevic/Z80Explorer)
* Create gate-level layouts that would resemble the original Z80 layout. Zilog designed Z80 by manually placing each transistor by hand.
* Tapeout QFN44 package
* Tapeout DIP40 package

**Z80 technical capabilities**
* nMOS original frequency 4MHz. CMOS frequency up to 20 MHz. This tapeout on 130 nm is expected to support frequency up to 50 MHz.
* 158 instructions including support for [Intel 8080A](https://en.wikipedia.org/wiki/Intel_8080) instruction set as a subset.
* Two sets of 6 general-purpose reigsters which may be used as either 8-bit or 16-bit register pairs.
* One maskable and one non-maskable interrupt.
* Instruction set derived from [Datapoint 2200](https://en.wikipedia.org/wiki/Datapoint_2200), [Intel 8008](https://en.wikipedia.org/wiki/Intel_8008) and [Intel 8080A](https://en.wikipedia.org/wiki/Intel_8080).

**Z80 registers**
* `AF`: 8-bit accumulator (A) and flag bits (F)
* `BC`: 16-bit data/address register or two 8-bit registers
* `DE`: 16-bit data/address register or two 8-bit registers
* `HL`: 16-bit accumulator/address register or two 8-bit registers
* `SP`: stack pointer, 16 bits
* `PC`: program counter, 16 bits
* `IX`: 16-bit index or base register for 8-bit immediate offsets
* `IY`: 16-bit index or base register for 8-bit immediate offsets
* `I`: interrupt vector base register, 8 bits
* `R`: DRAM refresh counter, 8 bits (msb does not count)
* `AF'`: alternate (or shadow) accumulator and flags (toggled in and out with `EX AF, AF'` )
* `BC'`, `DE'` and `HL'`: alternate (or shadow) registers (toggled in and out with `EXX`)

**Z80 Pinout**
```
                    ,---------.__.---------.
         <--    A11 |1                   40| A10    -->       
         <--    A12 |2                   39| A9     -->        
         <--    A13 |3       Z80 CPU     38| A8     -->        
         <--    A14 |4                   37| A7     -->        
         <--    A15 |5                   36| A6     -->
         -->    CLK |6                   35| A5     -->
         <->     D4 |7                   34| A4     -->
         <->     D3 |8                   33| A3     -->            
         <->     D5 |9                   32| A2     -->            
         <->     D6 |10                  31| A1     -->            
                VCC |11                  30| A0     -->           
         <->     D2 |12                  29| GND           
         <->     D7 |13                  28| /RFSH  -->          
         <->     D0 |14                  27| /M1    -->           
         <->     D1 |15                  26| /RESET <--      
         -->   /INT |16                  25| /BUSRQ <--      
         -->   /NMI |17                  24| /WAIT  <--      
         <--  /HALT |18                  23| /BUSAK -->     
         <--  /MREQ |19                  22| /WR    -->       
         <--  /IORQ |20                  21| /RD    -->       
                    `----------------------'
```

## How to test

Hold all `bidirectional` pins (**Data bus**) low to make CPU execute **NOP** instruction. **NOP** instruction opcode is 0.
Hold all `input` pins high to disable interrupts and signal that data bus is ready.

Every 4th cycle 8-bit value on `output` pins (**Address bus low 8-bit**) should monotonously increase.

```
     Timing diagram, input pins

      Z80CLK____      ____      ____      ____      ____      ____         
         __/    \____/    \____/    \____/    \____/    \____/    `____ ...
           |        |         |         |         |         |
           |        |         |         |         |         |

      /RESET___________________________________________________________
         __/
      /WAIT ___________________________________________________________
         __/
      /INT  ___________________________________________________________
         __/
      /NMI  ___________________________________________________________
         __/
      /BUSRQ___________________________________________________________
         __/

      D7..D0             NOP       NOP       NOP       NOP       NOP
         __ XXXXXXXXX ___#00___ ___#00___ ___#00___ ___#00___ ___#00___

      Expected signals on output pins
      /M1   _________                    ____________________
                     \__________________/                    \_________
      /MREQ ___________________          ______________________________
                               \________/ 
      /RD   ___________________          ______________________________
                               \________/
      A0..A7         
         __ XXXXXXXXX ___#00___ ___#00___ XXXXXXXXX XXXXXXXXX ___#01___
 
```

## External hardware

Bus de-multiplexor, external memory, 8-bit computer such as [ZX Spectrum](https://en.wikipedia.org/wiki/ZX_Spectrum).

Alternatively the RP2040 on the TinyTapeout test PCB can be used to simulate RAM and I/O.
