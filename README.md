![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# Announcement
On April 15 of 2024 Zilog has [announced End-of-Life](https://www.mouser.com/PCN/Littelfuse_PCN_Z84C00.pdf) for Z80 - of one of the most famous 8-bit CPUs of all time.

It is a time for open-source and hardware preservation community to step in with a Free and Open Source Silicon (FOSS) replacement for Zilog Z80!

# Zilog Z80 modern open source silicon clone
On the path to become a silicon proven, pin compatible, open-source replacement for classic Zilog Z80.

The first iteration is made for [Tiny Tapeout 07](https://tinytapeout.com), fits in 4 tiles (0.064 mm^2) and is based on Guy Hutchison's [TV80](https://github.com/hutch31/tv80) Verilog core.

[Read documentation for Tiny Tapeout 07 version](docs/info.md)

![](docs/2x2_tiles.png)

## Further Plan / ToDo
* Add thorough instruction (including 'illegal') execution tests [ZEXALL](https://mdfs.net/Software/Z80/Exerciser/) to testbench
* Compare different implementations: Verilog core [A-Z80](https://github.com/gdevic/A-Z80), Netlist based [Z80Explorer](https://github.com/gdevic/Z80Explorer)
* Tapeout with ChipIgnite in QFN44 package
* Tapeout with DIP40 package
* Create gate-level layouts that would resemble the original Z80 layout, see the original [chip dies](#Z80-Die-shots) below. Zilog designed Z80 by manually placing each transistor by hand.

# Z80

## Pinout
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

## Documentation
* [Z80 Users Manual](https://baltazarstudios.com/webshare/A-Z80/Z80_CPU_Users_Manual_2004.pdf)
* [Z80 Users Manual from Mostek](https://baltazarstudios.com/webshare/A-Z80/z80-mostek.pdf)
* [Zilog Data Book](http://cini.classiccmp.org//pdf/Zilog/Zilog%20Data%20Book.PDF)
* [All the information about Z80](http://www.z80.info)
* [Undocumented instructions](https://baltazarstudios.com/webshare/A-Z80/z80-documented-v0.91.pdf)
* [Opcode table](https://baltazarstudios.com/webshare/A-Z80/Z80-Opcode-Tables.pdf) and [timing](https://baltazarstudios.com/webshare/A-Z80/Z80-Instruction-List-with-T-states.pdf)

## Oral History of the Development of the Z80
[Oral History Panel on the Founding of the Company and the Development of the Z80 Microprocessor](http://archive.computerhistory.org/resources/text/Oral_History/Zilog_Z80/102658073.05.01.pdf)

[M. Shima on Demystifying Microprocessor Design](https://baltazarstudios.com/webshare/A-Z80/Library/Demystifying%20Microprocessor%20Design%20-%20M.%20Shima.pdf)

## Z80 Patents
* **(expired)** Patent [US4605980](https://patents.google.com/patent/US4605980) -- input voltage spike protection
* **(expired)** Patent [US4332008A](https://patents.google.com/patent/US4332008A) -- ???
* **(expired)** Patent [US4486827A](https://patents.google.com/patent/US4486827A) -- reset circuitry

## Z80 Die shots
* [How to "read" die shots](https://downloads.reactivemicro.com/Electronics/Reverse%20Engineering/6502%20-%20Guideline%20to%20Reverse%20Engineering%20v1.0.pdf)
* nMOS variant [Z8400 with 'Zilog 75'](https://siliconpr0n.org/map/zilog/z8400aps-z80acpu/bercovici_mz/) marking and [Zilog Z8400 with 'DC'](https://siliconpr0n.org/map/zilog/z0840008/marmontel_mz_ms20x/) letter marking
* CMOS variants [Zilog Z84C00](http://visual6502.org/images/pages/Zilog_Z84C00_die_shots.html) and its [8MHz version](https://siliconpr0n.org/map/zilog/z84c0008fec/marmontel_mz_ms20x/)
* Nintendo Z80 variant from Super Game Boy [SGB-CPU 01](https://siliconpr0n.org/map/nintendo/sgb-cpu-01/mcmaster_mz_mit20x/) produced in 1994
* Pauli Rautakorpi images of Z80 clones: [National Semiconductor NSC800](https://commons.wikimedia.org/wiki/User:Birdman86#/media/File:NS_NSC800_die.jpg), [Mostek MK3880](https://commons.wikimedia.org/wiki/User:Birdman86#/media/File:Mostek_MK3880_die.jpg), [MME9201 with 'U880/5'](https://commons.wikimedia.org/wiki/User:Birdman86#/media/File:MME_80A-CPU_die.JPG) markings 
* Zeptobar’s images of [Zilog Z0840004PSC](https://zeptobars.com/en/read/Zilog-Z80-Z0840004PSC) from 1990, [Soviet KR1858VM3](https://happytrees.org/dieshots/Soviet_-_KR1858VM3#/media/File:KR1858VM3-HD.jpg) with an uncommon layout, [MME Z80A](https://zeptobars.com/en/read/Zilog-Z80-Z80A) a clone on a 5um technology larger than the original Zilog chip, [Soviet KR1858VM1](https://zeptobars.com/en/read/KR1858VM1-Z80-MME-Angstrem) a clone of U880/6 which is in turn a clone of Z80, [Soviet T34VM1](https://zeptobars.com/en/read/t34vm1-z80-angstrem-mme) based on U880/5

![](http://visual6502.org/images/Z84C00/Z84C00_die_shot_20x_1b_1600w.jpg)

## Z80 Reverse Engineering
* [Z80 Instruction Register deciphered](https://baltazarstudios.com/z80-instruction-register-deciphered/)
* [Z80 Tri-stated Data & Address bus gates](https://baltazarstudios.com/anatomy-z80-gate/)
* [Z80 (un)documented behavior](https://baltazarstudios.com/zilog-z80-undocumented-behavior/)
* [The instruction decode PLA in the Z80 microprocessor](http://static.righto.com/files/z80-pla-table.html)
* [Why the Z-80's data pins are scrambled](http://www.righto.com/2014/09/why-z-80s-data-pins-are-scrambled.html)
* [How the Z80's registers are implemented](http://www.righto.com/2014/10/how-z80s-registers-are-implemented-down.html)
* [The Z-80's 16-bit increment/decrement circuit reverse engineered](http://www.righto.com/2013/11/the-z-80s-16-bit-incrementdecrement.html)
* [The Z-80 has a 4-bit ALU](http://www.righto.com/2013/09/the-z-80-has-4-bit-alu-heres-how-it.html)
* [XOR, the silicon for two interesting gates explained](http://www.righto.com/2013/09/understanding-z-80-processor-one-gate.html)
* [WZ aka MEMPTR, esoteric register of the Z80](https://baltazarstudios.com/webshare/A-Z80/memptr_eng.txt)

## Existing Z80 implementations
* TV80 in Verilog https://github.com/hutch31/tv80
* TV80 in Verilog https://github.com/Obijuan/Z80-FPGA
* A-Z80 in Verilog https://github.com/gdevic/A-Z80 its [overview](https://baltazarstudios.com/z80-ground/) and [details](https://baltazarstudios.com/z80-cpu/)
* Z80 net-list level emulator https://github.com/gdevic/Z80Explorer and its [overview](https://baltazarstudios.com/z80explorer/) and [Users Guide](https://gdevic.github.io/Z80Explorer/)

# What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://docs.google.com/document/d/1aUUZ1jthRpg4QURIIyzlOaPWlmQzr-jBn3wZipVUPt4)
