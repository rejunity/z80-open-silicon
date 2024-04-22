![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

[https://www.mouser.com/PCN/Littelfuse_PCN_Z84C00.pdf]

# Zilog Z80 modern open-source silicon clone
On the path to become a silicon proven, pin compatible, open-source replacement for classic Zilog Z80!

The first iteration is made for [Tiny Tapeout 07](https://tinytapeout.com), fits in 4 tiles (0.064 mm^2) and is based on Guy Hutchison's [TV80](https://github.com/hutch31/tv80) Verilog core.

![](docs/2x2_tiles.png)

## TODO
* [ZEXALL](https://mdfs.net/Software/Z80/Exerciser/) in testbench

### Z80 pinout
```
                   ,---------.__,---------.
         <--   A11 |1                   40| A10    -->       
         <--   A12 |2                   39| A9     -->        
         <--   A13 |3       Z80 CPU     38| A8     -->        
         <--   A14 |4                   37| A7     -->        
         <--   A15 |5                   36| A6     -->
         -->   CLK |6                   35| A5     -->
         <->    D4 |7                   34| A4     -->
         <->    D3 |8                   33| A3     -->            
         <->    D5 |9                   32| A2     -->            
         <->    D6 |10                  31| A1     -->            
               VCC |11                  30| A0     -->           
         <->    D2 |12                  29| GND           
         <->    D7 |13                  28| /RFSH  -->          
         <->    D0 |14                  27| /M1    -->           
         <->    D1 |15                  26| /RESET <--      
         -->  /INT |16                  25| /BUSRQ <--      
         -->  /NMI |17                  24| /WAIT  <--      
         <-- /HALT |18                  23| /BUSAK -->     
         <-- /MREQ |19                  22| /WR    -->       
         <-- /IORQ |20                  21| /RD    -->       
                   `----------------------'
```

### Documentation
* [Zilog Data Book](http://cini.classiccmp.org//pdf/Zilog/Zilog%20Data%20Book.PDF)
* [All the information about Z80](http://www.z80.info)
* [Undocumented instructions](https://baltazarstudios.com/webshare/A-Z80/z80-documented-v0.91.pdf)
* [Opcode table](https://baltazarstudios.com/webshare/A-Z80/Z80-Opcode-Tables.pdf) and [timing](https://baltazarstudios.com/webshare/A-Z80/Z80-Instruction-List-with-T-states.pdf)

### Oral History of the Development of the Z80
[Oral History Panel on the Founding of the Company and the Development of the Z80 Microprocessor](http://archive.computerhistory.org/resources/text/Oral_History/Zilog_Z80/102658073.05.01.pdf)
[M. Shima on Demystifying Microprocessor Design](https://baltazarstudios.com/webshare/A-Z80/Library/Demystifying%20Microprocessor%20Design%20-%20M.%20Shima.pdf)

## Z80 Die shots
* [How to "read" die shots](https://downloads.reactivemicro.com/Electronics/Reverse%20Engineering/6502%20-%20Guideline%20to%20Reverse%20Engineering%20v1.0.pdf)
* [CMOS variant Z84C00](http://visual6502.org/images/pages/Zilog_Z84C00_die_shots.html)
* [Various CMOS variants](https://siliconpr0n.org/map/zilog/)
* Zeptobar’s images of various editions: [KR1858VM1](https://zeptobars.com/en/read/KR1858VM1-Z80-MME-Angstrem) (Soviet Z80), [Z80A](https://zeptobars.com/en/read/Zilog-Z80-Z80A), [Z0840004PSC](https://zeptobars.com/en/read/Zilog-Z80-Z0840004PSC), [T34VM1](https://zeptobars.com/en/read/t34vm1-z80-angstrem-mme)

![](http://visual6502.org/images/Z84C00/Z84C00_die_shot_20x_1b_1600w.jpg)

## Z80 Reverse Engineering
* [Z80 Instruction Register deciphered](https://baltazarstudios.com/z80-instruction-register-deciphered/)
* 
* [The instruction decode PLA in the Z80 microprocessor](http://static.righto.com/files/z80-pla-table.html)
* [Why the Z-80's data pins are scrambled](http://www.righto.com/2014/09/why-z-80s-data-pins-are-scrambled.html)
* [How the Z80's registers are implemented](http://www.righto.com/2014/10/how-z80s-registers-are-implemented-down.html)
* [The Z-80's 16-bit increment/decrement circuit reverse engineered](http://www.righto.com/2013/11/the-z-80s-16-bit-incrementdecrement.html)
* [The Z-80 has a 4-bit ALU](http://www.righto.com/2013/09/the-z-80-has-4-bit-alu-heres-how-it.html)
* [The silicon for two interesting gates explained](http://www.righto.com/2013/09/understanding-z-80-processor-one-gate.html)

## Existing Z80 implementations
* TV80 in Verilog https://github.com/hutch31/tv80
* TV80 in Verilog https://github.com/Obijuan/Z80-FPGA
* A-Z80 in Verilog https://github.com/gdevic/A-Z80 and its [overview](https://baltazarstudios.com/z80-ground/) and [details](https://baltazarstudios.com/z80-cpu/)
* Z80 net-list level emulator https://github.com/gdevic/Z80Explorer and its [overview](https://baltazarstudios.com/z80explorer/), [Users Guide](https://gdevic.github.io/Z80Explorer/)

# Tiny Tapeout

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://docs.google.com/document/d/1aUUZ1jthRpg4QURIIyzlOaPWlmQzr-jBn3wZipVUPt4)
