# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


from cocotb_uart import uart


import random


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

    NUM_BYTES = 32
    data = bytes(random.getrandbits(8) for _ in range(NUM_BYTES))

    print(f"sending bytes {data}")
    cocotb.start_soon(uart_tx.send_bytes(data))
    recv = await uart_rx.recv_bytes(len(data))
    print(f"received bytes {recv}")
    assert recv == data
