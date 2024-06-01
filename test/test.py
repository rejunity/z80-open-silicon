# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

BUS_READY = 0b0000_1111 # not WAIT, not INT, not NMI, not BUSRQ
OPCODE_NOP  = 0x00
OPCODE_LDHL = 0x21

@cocotb.test()
async def test__NOP(dut):
    await start_and_reset(dut)
    dut._log.info("Test NOP")

    # Set the input values you want to test
    dut.ui_in.value = BUS_READY
    dut.uio_in.value = OPCODE_NOP
    cycles_per_instr = 4
    
    # Wait for one clock cycle to see the output values
    z80_cycle = 0
    for i in range(32):
        controls, addr = await z80_step(dut, z80_cycle, verbose=True)

        if z80_cycle % cycles_per_instr == 0 or \
           z80_cycle % cycles_per_instr == 1:
            assert controls['m1'] == 1
        if z80_cycle % cycles_per_instr == 1:
            assert controls['mreq'] == 1
            assert controls['rd'] == 1
        assert controls['wr'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        if z80_cycle < cycles_per_instr-1:
            assert addr == z80_cycle // 4 # Running NOPs, every 4 cycles address increases
        z80_cycle += 1
               

@cocotb.test()
async def test__LD_HL2121(dut):
    await start_and_reset(dut)
    dut._log.info("Test LD HL, $2121")

    # Set the input values you want to test
    dut.ui_in.value = BUS_READY
    dut.uio_in.value = 0x21 # LD HL, $2121
    cycles_per_instr = 10
    
    # Wait for one clock cycle to see the output values
    z80_cycle = 0
    for i in range(32):
        controls, addr = await z80_step(dut, z80_cycle, verbose=True)

        if z80_cycle % cycles_per_instr == 0 or \
           z80_cycle % cycles_per_instr == 1:
            assert controls['m1'] == 1
        if z80_cycle % cycles_per_instr == 1 or \
           z80_cycle % cycles_per_instr == 5 or \
           z80_cycle % cycles_per_instr == 8:
            assert controls['mreq'] == 1
            assert controls['rd'] == 1
        assert controls['wr'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        z80_cycle += 1

async def start_and_reset(dut):
    dut._log.info("Start")

    # Set the clock period to ~62.5 ns (16 MHz = 4MHz Z80 clock)
    clock = Clock(dut.clk, 62, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 16)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

async def z80_step(z80, cycle, verbose=False):
    # 1st cycle --- control signals {m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n}
    # 2nd cycle --- {A0 - A7}
    # 3rd cycle --- repeated control signals
    # 4th cycle --- {A8 - A15}
    # z80.ena.value = 1
    # z80.ui_in.value = BUS_READY | 0b0000_0000
    # await ClockCycles(z80.clk, 1)
    # addr = z80.uo_out.value

    # z80.ena.value = 0
    # z80.ui_in.value = BUS_READY | 0b0100_0000
    # await ClockCycles(z80.clk, 1)
    # addr = addr | z80.uo_out.value << 8






    z80.ui_in.value = BUS_READY | 0b1000_0000
    await ClockCycles(z80.clk, 1)
    controls = z80.uo_out.value
    z80.ena.value = 0
    z80.ui_in.value = BUS_READY | 0b0000_0000
    await ClockCycles(z80.clk, 1)
    addr = z80.uo_out.value
    z80.ui_in.value = BUS_READY | 0b0100_0000
    await ClockCycles(z80.clk, 1)
    addr = addr | z80.uo_out.value << 8
    z80.ena.value = 1


    # z80.ui_in.value = BUS_READY | 0b0000_0000
    # await ClockCycles(z80.clk, 1)
    # addr = z80.uo_out.value
    # z80.ena.value = 0
    # z80.ui_in.value = BUS_READY | 0b1000_0000
    # await ClockCycles(z80.clk, 1)
    # controls = z80.uo_out.value
    # z80.ui_in.value = BUS_READY | 0b0100_0000
    # await ClockCycles(z80.clk, 1)
    # addr = addr | z80.uo_out.value << 8
    # z80.ena.value = 1






    # z80.ena.value = 1
    # z80.ui_in.value = BUS_READY | 0b0000_0000
    # await ClockCycles(z80.clk, 1)
    # addr = z80.uo_out.value

    # z80.ena.value = 0
    # z80.ui_in.value = BUS_READY | 0b0100_0000
    # await ClockCycles(z80.clk, 1)
    # addr = addr | z80.uo_out.value << 8

    # z80.ui_in.value = BUS_READY | 0b1000_0000
    # await ClockCycles(z80.clk, 1)
    # controls = z80.uo_out.value
    # controls = [int(not bit(controls, n)) for n in range(8)]
    # controls = dict(zip(['m1', 'mreq', 'ioreq', 'rd', 'wr', 'rfsh', 'halt', 'busak'], controls))
    # z80.ena.value = 1

    controls = [int(not bit(controls, n)) for n in range(8)]
    controls = dict(zip(['m1', 'mreq', 'ioreq', 'rd', 'wr', 'rfsh', 'halt', 'busak'], controls))

    if (verbose):
        print (f"clk: {cycle:3d}  {controls}  addr:0x{addr:04X}".replace("'", "") \
                                                                .replace("{", "") \
                                                                .replace("}", "") \
                                                                .replace(",", ""))
        if (controls['m1'] and controls['rd']):
            print(f"    OPCODE: {int(z80.uio_in.value):02X}")
        elif (controls['rd']):
            print(f"    READ DATA: {int(z80.uio_in.value):02X}")
        if (controls['wr']):
            print(f"    WRITE DATA: {int(z80.uio_in.value):02X}")
    return controls, addr

def bit(byte, n):
    return byte & (1<<n) != 0
