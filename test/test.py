# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


from cocotb_uart import uart


def build_packet(wr: bool, addr: int, data: int):
    p = bytearray(1)

    if wr:
        p[0] = 1 << 7
    else:
        p[0] = 0

    p[0] |= (addr & 0x7) << 4
    p[0] |= data & 0xF

    return bytes(p)

def build_rd_packet(addr: int):
    return build_packet(False, addr, 0)

def build_wr_packet(addr: int, data: int):
    return build_packet(True, addr, data)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 15, unit="ns")
    cocotb.start_soon(clock.start())

    uart_tx = uart.UartTx(dut.uart_rx, baud=115200)
    uart_rx = uart.UartRx(dut.uart_tx, baud=115200)

    dut._log.info("Reset")
    dut.ena.value = 1
    dut.tthbif_rx.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    for i in range(16):
        dut.tthbif_rx.value = i
        await ClockCycles(dut.clk, 1)
        print(f"tx={dut.tthbif_tx.value}");

    #NUM_BYTES = 32
    #data = bytes(random.getrandbits(8) for _ in range(NUM_BYTES))

    #print(f"sending bytes {data}")
    #cocotb.start_soon(uart_tx.send_bytes(data))
    #recv = await uart_rx.recv_bytes(len(data))
    #print(f"received bytes {recv}")
    #assert recv == data

    NUM_ADDR = 8
    data = bytes(random.getrandbits(4) for _ in range(NUM_ADDR))

    # read every address out of reset and assert it to be 0
    for i in range(NUM_ADDR):
        dut._log.info(f"rd   rf[{i}]")
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(i)))
        recv = await uart_rx.recv_bytes(1)
        dut._log.info(f"recv rf[{i}]={hex(recv[0])}")

        assert recv == bytes([0])

    # write every address
    for i in range(NUM_ADDR):
        dut._log.info(f"wr   rf[{i}] = {hex(data[i])}")
        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(i, data[i])))
        recv = await uart_rx.recv_bytes(1)
        dut._log.info(f"recv rf[{i}]={hex(recv[0])}")

        assert recv == bytes([0])

    # read every address back
    for i in range(NUM_ADDR):
        dut._log.info(f"rd   rf[{i}]")
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(i)))
        recv = await uart_rx.recv_bytes(1)
        dut._log.info(f"recv rf[{i}]={hex(recv[0])}")

        assert recv == bytes([data[i] & 0xf])
