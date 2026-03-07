# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer


from cocotb_uart import uart


def build_packet(wr: bool, addr: int, data: int):
    p = bytearray(2)

    if wr:
        p[0] = 1 << 7
    else:
        p[0] = 0

    p[0] |= addr & 0x3F
    p[1] |= data & 0xF

    return bytes(p)

def build_rd_packet(addr: int):
    return build_packet(False, addr, 0)

def build_wr_packet(addr: int, data: int):
    return build_packet(True, addr, data)

TTHBIF_PREAMBLE = bytes([0xA5] * 4)
TTHBIF_FRAME_LEN = 1024

def build_tthbif_frame(data: bytes):
    if len(data) > TTHBIF_FRAME_LEN:
        raise ValueError(f"tthbif fram must be less than or equal to 64B long, got {len(data)}")

    frame = TTHBIF_PREAMBLE + data + bytes([0] * (TTHBIF_FRAME_LEN - len(data)))

    return frame

@cocotb.test()
async def test_rf(dut):
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

    NUM_ADDR = 32
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

        if i > 25:
            assert recv == bytes([0])
        else:
            assert recv == bytes([data[i] & 0xf])

@cocotb.test()
async def test_tthbif(dut):
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

    async def set_rx_enable(lane: int, enable: bool):
        dut._log.info(f"set rx{lane} enable={enable}")
        addr = 2*lane + 1
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        if enable:
            recv = recv[0] | 0x4
        else:
            recv = recv[0] & (~0x4)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def set_tx_enable(lane: int, enable: bool):
        dut._log.info(f"set tx{lane} enable={enable}")
        addr = 2*lane + 1 + 0x8
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        if enable:
            recv = recv[0] | 0x4
        else:
            recv = recv[0] & (~0x4)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def set_rx_p_comb_tap(lane: int, n: int):
        dut._log.info(f"set rx{lane} p_comb_tap={n}")
        addr = 2*lane
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        recv = recv[0] | (n & 0x3)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def set_rx_n_comb_tap(lane: int, n: int):
        dut._log.info(f"set rx{lane} n_comb_tap={n}")
        addr = 2*lane
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        recv = recv[0] | ((n & 0x3) << 2)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def set_rx_p_flop_tap(lane: int, n: int):
        dut._log.info(f"set rx{lane} p_flop_tap={n}")
        addr = 2*lane + 1
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        recv = recv[0] | (n & 0x1)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def set_rx_n_flop_tap(lane: int, n: int):
        dut._log.info(f"set rx{lane} n_flop_tap={n}")
        addr = 2*lane + 1
        cocotb.start_soon(uart_tx.send_bytes(build_rd_packet(addr)))
        recv = await uart_rx.recv_bytes(1)
        recv = recv[0] | ((n & 0x1) << 1)

        cocotb.start_soon(uart_tx.send_bytes(build_wr_packet(addr, recv)))
        recv = await uart_rx.recv_bytes(1)

    async def tthbif_send_bytes(b: bytes, posedge_start: bool):
        posedge = posedge_start

        for i in range(len(b)):
            for j in range(2):
                if j == 0:
                    v = b[i] & 0xf
                else:
                    v = (b[i] >> 4) & 0xf

                if posedge:
                    await RisingEdge(dut.clk)
                else:
                    await FallingEdge(dut.clk)

                dut.tthbif_rx.value = v
                posedge = not posedge

    async def tthbif_recv_bytes(n: int):
        num_frames = int((n + TTHBIF_FRAME_LEN - 1) / TTHBIF_FRAME_LEN)

        posedge = True

        expected_preamble = []
        payload = []

        for b in TTHBIF_PREAMBLE:
            expected_preamble.append(b & 0xf)
            expected_preamble.append((b >> 4) & 0xf)

        for i in range(num_frames):
            preamble = [0] * len(expected_preamble)

            while preamble != expected_preamble:
                if posedge:
                    await RisingEdge(dut.clk)
                else:
                    await FallingEdge(dut.clk)
                posedge = not posedge

                preamble.pop(0)
                preamble.append(dut.tthbif_tx.value)

            for i in range(2*TTHBIF_FRAME_LEN):
                if posedge:
                    await RisingEdge(dut.clk)
                else:
                    await FallingEdge(dut.clk)
                posedge = not posedge

                payload.append(dut.tthbif_tx.value)

        r = bytearray(n)

        for i in range(len(r)):
            r[i] = int(payload[2*i]) & 0xf
            r[i] = r[i] | ((int(payload[2*i+1]) & 0xf) << 4)

        return bytes(r)


    #NUM_BYTES = 16
    #data = bytes((((i+1) << 4) | (i & 0xf)) & 0xff for i in range(0, NUM_BYTES, 2))

    rx_flop_tap = random.randint(0, 1)

    dut._log.info(f"Configure TTHBIF")
    for i in range(4):
        rx_comb_tap = random.randint(0, 1)
        await set_rx_p_comb_tap(i, rx_comb_tap)
        await set_rx_n_comb_tap(i, rx_comb_tap)
        await set_rx_p_flop_tap(i, rx_flop_tap)
        await set_rx_n_flop_tap(i, rx_flop_tap)
        await set_rx_enable(i, True)
        await set_tx_enable(i, True)


    dut.tthbif_rx.value = 0
    await ClockCycles(dut.clk, 10)

    NUM_TEST = 100

    dut._log.info(f"Test TTHBIF")
    for test in range(NUM_TEST):
        data = bytes(random.getrandbits(8) for _ in range(random.randint(1, TTHBIF_FRAME_LEN)))
        dut._log.info(f"test {test+1}/{NUM_TEST}:")
        dut._log.info(f"sending ({len(data)}): {data}")
        cocotb.start_soon(tthbif_send_bytes(build_tthbif_frame(data), random.choice([True, False])))
        recv = await tthbif_recv_bytes(len(data))
        dut._log.info(f"received ({len(recv)}): {recv}")
        assert recv == data
        dut.tthbif_rx.value = 0
        await ClockCycles(dut.clk, random.randint(1, 10))

    await ClockCycles(dut.clk, 10)

