#!/usr/bin/env python3
"""
Independent third-party CPU emulator verification for Quine Relay 284:
  - Step 268 (6502 asm, assembled by xa65 -> QR.o65):
      verified on Mike Naberezny's upstream `py65` (v1.2.0, py65.devices.mpu6502.MPU)
  - Step 270 (Z80 asm, assembled by z80asm -> QR.z80.bin):
      verified on upstream `z80` C-extension emulator (v1.2.0, z80.Z80Machine)

Usage:
  pip install py65 z80
  python3 audit/scripts/verify_6502_z80.py /path/to/QR.o65 /path/to/expected_arm64.s /path/to/QR.z80.bin /path/to/expected_rv.s
"""
import hashlib
import sys
import time
from pathlib import Path

from py65.devices.mpu6502 import MPU
from py65.memory import ObservableMemory
import z80


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def run_py65(rom: bytes) -> bytes:
    out = bytearray()
    mem = ObservableMemory()
    mem[0x0200 : 0x0200 + len(rom)] = list(rom)

    def putc(_addr: int, val: int) -> None:
        out.append(val & 0xFF)

    mem.subscribe_to_write([0xF001], putc)
    cpu = MPU(memory=mem, pc=0x0200)
    cpu.sp = 0xFF
    while mem[cpu.pc] != 0x00:  # stop on BRK (0x00), matching py65mon / run6502
        cpu.step()
    return bytes(out)


def run_z80_thirdparty(rom: bytes) -> bytes:
    out = bytearray()
    m = z80.Z80Machine()
    m.set_memory_block(0x0000, rom)
    m.pc = 0x0000
    m.sp = 0xFFFF

    def on_out(addr: int, val: int) -> None:
        if (addr & 0xFF) == 0x01:
            out.append(val & 0xFF)

    m.set_output_callback(on_out)
    while not m.halted:
        m.ticks_to_stop = 10_000_000
        m.run()
    return bytes(out)


def main() -> None:
    o65_path, exp65_path, z80_path, expz80_path = map(Path, sys.argv[1:5])

    rom65 = o65_path.read_bytes()
    exp65 = exp65_path.read_bytes()
    t0 = time.perf_counter()
    got65 = run_py65(rom65)
    dt65 = time.perf_counter() - t0
    assert got65 == exp65, f"6502 mismatch: got {len(got65)} B vs expected {len(exp65)} B"
    print(f"[PASS] 6502 (`py65` 1.2.0 MPU):   in={len(rom65):,} B -> out={len(got65):,} B  sha256={sha256(got65)}  ({dt65:.2f}s)")

    romz80 = z80_path.read_bytes()
    expz80 = expz80_path.read_bytes()
    t0 = time.perf_counter()
    gotz80 = run_z80_thirdparty(romz80)
    dtz80 = time.perf_counter() - t0
    assert gotz80 == expz80, f"Z80 mismatch: got {len(gotz80)} B vs expected {len(expz80)} B"
    print(f"[PASS] Z80  (`z80` 1.2.0 C core): in={len(romz80):,} B -> out={len(gotz80):,} B  sha256={sha256(gotz80)}  ({dtz80:.2f}s)")


if __name__ == "__main__":
    main()
