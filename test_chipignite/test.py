# SPDX-FileCopyrightText: © 2024 ReJ aka Renaldsa Zioma
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge

                        #   io[4]    io[30]    io[31]   io[35]
BUS_READY = 0b1111      # not WAIT, not NMI, not INT, not BUSRQ
OPCODE_NOP      = 0x00
OPCODE_LDHL     = 0x21
OPCODE_LDNNA    = 0x32

@cocotb.test()
async def test__RESET(dut):
    await start(dut)

    dut._log.info("Test RESET sequence")
    dut._log.info("Reset")
    dut.io_in.value = 0
    dut.custom_settings.value = 0b00000
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    for z80_cycle in range(-4, 2):
        if (z80_cycle >= 0):
            dut.rst_n.value = 1
        controls_1st_half, _, _, _, _, _ = await z80_step(dut, z80_cycle, verbose=True)
        controls = controls_1st_half
        assert controls['mreq'] == 0
        assert controls['rd'] == 0
        assert controls['wr'] == 0
        assert controls['wr'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        assert controls['m1'] == (z80_cycle > 0)

@cocotb.test()
async def test__NOP(dut):
    await start_and_reset(dut)
    dut._log.info("Test NOP")

    dut.controls_in.value   = BUS_READY
    dut.data_in.value       = OPCODE_NOP
    cycles_per_instr = 4

    z80_cycle = 0
    for i in range(32):
        _, controls, addr, addr_, _, _ = await z80_step(dut, z80_cycle, verbose=True)

        assert addr == addr_
        if (z80_cycle-1) % cycles_per_instr == 0 or \
           (z80_cycle-1) % cycles_per_instr == 1:
            assert controls['m1'] == 1
        if (z80_cycle-1) % cycles_per_instr == 1:
            assert controls['mreq'] == 1
            assert controls['rd'] == 1
        assert controls['wr'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        if z80_cycle > 1:
            assert addr == (z80_cycle - 1) // cycles_per_instr # Running NOPs, every 4 cycles address increases
        z80_cycle += 1

@cocotb.test()
async def test__LD_HL2121(dut):
    await start_and_reset(dut)
    dut._log.info("Test LD HL, $2121")

    dut.controls_in.value   = BUS_READY
    dut.data_in.value       = OPCODE_LDHL # LD HL, $2121
    cycles_per_instr = 10
    
    z80_cycle = 0
    for i in range(32):
        _, controls, addr, addr_, _, _ = await z80_step(dut, z80_cycle, verbose=True)

        assert addr == addr_ # Address is set during the 1st half-cycle and is stable until the end of the cycle
        if (z80_cycle-1) % cycles_per_instr == 0 or \
           (z80_cycle-1) % cycles_per_instr == 1:
            assert controls['m1'] == 1
        if (z80_cycle-1) % cycles_per_instr == 1 or \
           (z80_cycle-1) % cycles_per_instr == 5 or \
           (z80_cycle-1) % cycles_per_instr == 8:
            assert controls['mreq'] == 1
            assert controls['rd'] == 1
        assert controls['wr'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        z80_cycle += 1

@cocotb.test()
async def test__LD_3232_A(dut):
    await start_and_reset(dut)
    dut._log.info("Test LD ($3232), A")

    # Set the input values you want to test
    dut.controls_in.value   = BUS_READY
    dut.data_in.value       = OPCODE_LDNNA # LD ($3232), A
    cycles_per_instr = 13
    
    # Wait for one clock cycle to see the output values
    z80_cycle = 0
    for i in range(32):
        _, controls, addr, addr_, data, data_ = await z80_step(dut, z80_cycle, verbose=True)

        assert addr == addr_ # Address is set during the 1st half-cycle and is stable until the end of the cycle
        if (z80_cycle-1) % cycles_per_instr == 0 or \
           (z80_cycle-1) % cycles_per_instr == 1:
            assert controls['m1'] == 1
        if (z80_cycle-1) % cycles_per_instr == 1 or \
           (z80_cycle-1) % cycles_per_instr == 5 or \
           (z80_cycle-1) % cycles_per_instr == 8:
            assert controls['mreq'] == 1
            assert controls['rd'] == 1
            assert controls['wr'] == 0
        if (z80_cycle-1) % cycles_per_instr == 11:
            assert addr == 0x3232
            assert data_ == 0xFF # A is set to 0xFF during RESET
            assert controls['mreq'] == 1
            assert controls['wr'] == 1
            assert controls['rd'] == 0
        if (z80_cycle-1) % cycles_per_instr == 12 and z80_cycle > 0:
            assert data == 0xFF # databus is stable after /WR goes high
        if (z80_cycle-1) % cycles_per_instr > 11:
            assert controls['wr'] == 0
            assert controls['rd'] == 0
        assert controls['ioreq'] == 0
        assert controls['halt'] == 0
        assert controls['busak'] == 0
        z80_cycle += 1

async def start(dut):
    dut._log.info("Start")

    # Set the clock period to ~62.5 ns (16 MHz = 4MHz Z80 clock)
    clock = Clock(dut.clk, 62, units="ns")
    cocotb.start_soon(clock.start())

async def start_and_reset(dut):
    await start(dut)

    # Reset
    dut._log.info("Reset")
    dut.io_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 8)
    dut.rst_n.value = 1

async def z80_step(z80, cycle, verbose=False):
    def read_controls():
        controls = [bit_n(z80.controls_out, n) for n in range(8)]


        #                                             io[ 5]| /RFSH  -->
        #                                             io[*1]| /M1    -->
        #                                             ...
        # <--  /HALT |io[32]                         io[*0]| /BUSAK -->
        # <--  /MREQ |io[33]                         io[ 3]| /WR    -->
        # <--  /IORQ |io[34]                         io[ 2]| /RD    -->
        #             `-------------------------------------'

        #                 io[0]  io[1] io[2] io[3]   io[5]  io[32]  io[33]   io[34]
        return dict(zip(['busak', 'm1', 'rd', 'wr', 'rfsh', 'halt', 'mreq', 'ioreq'], controls))

    def read_data():
        if z80.data_oe.value != 0b1111_1111:
            return 'ZZ'
        elif z80.data_out.value.is_resolvable:
            return int(z80.data_out.value.integer)
        else:
            return z80.data_out.value.binstr 
    await FallingEdge(z80.clk)
    controls_f = read_controls()
    addr_f = z80.addr.value.integer
    data_f = read_data()
    await RisingEdge(z80.clk)
    controls_r = read_controls()
    addr_r = z80.addr.value.integer
    data_r = read_data()

    controls = controls_f
    addr = addr_r
    data = data_f
    if (verbose):
        print (f"clk: {cycle:3d}  {controls}  addr:0x{addr:04X}".replace("'", "") \
                                                                .replace("{", "") \
                                                                .replace("}", "") \
                                                                .replace(",", ""))
        if (controls['m1'] and controls['rd']):
            print(f"    OPCODE: ${int(z80.data_in.value):02X}")
        elif (controls['rd']):
            print(f"    READ DATA: ${int(z80.data_in.value):02X}")
        if (controls['wr'] == 1):
            print(f"    WRITE DATA: ${data:02X}")
    return controls_f, controls_r, addr_f, addr_r, data_f, data_r

def bit_n(signals, n):
    if signals[n].value.is_resolvable:
        return 1-signals[n].value.integer
    else:
        return signals[n].value.binstr
