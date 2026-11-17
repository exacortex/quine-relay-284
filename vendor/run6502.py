#!/usr/bin/env python3
# MOS 6502 CLI emulator for Quine Relay B18 (loads flat binary at $0200, putc at $F001, stops on BRK).
import sys

def run(rom: bytes):
    mem = bytearray(65536)
    mem[0x0200:0x0200 + len(rom)] = rom
    pc = 0x0200
    a = x = y = 0
    sp = 0xFF
    c_flag = 0
    z_flag = 0
    out = bytearray()

    def set_nz(val):
        nonlocal z_flag
        val &= 0xFF
        z_flag = 1 if val == 0 else 0
        return val

    def rel(offset):
        return offset - 256 if offset >= 128 else offset

    while True:
        op = mem[pc]
        pc = (pc + 1) & 0xFFFF
        if op == 0x00:  # BRK
            break
        elif op == 0xA9:  # LDA #imm
            a = set_nz(mem[pc]); pc += 1
        elif op == 0xA2:  # LDX #imm
            x = set_nz(mem[pc]); pc += 1
        elif op == 0xA0:  # LDY #imm
            y = set_nz(mem[pc]); pc += 1
        elif op == 0x85:  # STA zp
            mem[mem[pc]] = a; pc += 1
        elif op == 0xA5:  # LDA zp
            a = set_nz(mem[pc]); pc += 1
        elif op == 0xB1:  # LDA (zp),Y
            zp = mem[pc]; pc += 1
            addr = (mem[zp] | (mem[(zp + 1) & 0xFF] << 8)) + y
            a = set_nz(mem[addr & 0xFFFF])
        elif op == 0xBD:  # LDA abs,X
            addr = (mem[pc] | (mem[pc + 1] << 8)) + x; pc += 2
            a = set_nz(mem[addr & 0xFFFF])
        elif op == 0xB9:  # LDA abs,Y
            addr = (mem[pc] | (mem[pc + 1] << 8)) + y; pc += 2
            a = set_nz(mem[addr & 0xFFFF])
        elif op == 0xAD:  # LDA abs
            addr = mem[pc] | (mem[pc + 1] << 8); pc += 2
            a = set_nz(mem[addr])
        elif op == 0x8D:  # STA abs
            addr = mem[pc] | (mem[pc + 1] << 8); pc += 2
            if addr == 0xF001:
                out.append(a & 0xFF)
            else:
                mem[addr] = a
        elif op == 0xE6:  # INC zp
            zp = mem[pc]; pc += 1
            mem[zp] = set_nz(mem[zp] + 1)
        elif op == 0xE8:  # INX
            x = set_nz(x + 1)
        elif op == 0xC8:  # INY
            y = set_nz(y + 1)
        elif op == 0xCA:  # DEX
            x = set_nz(x - 1)
        elif op == 0x88:  # DEY
            y = set_nz(y - 1)
        elif op == 0xAA:  # TAX
            x = set_nz(a)
        elif op == 0x8A:  # TXA
            a = set_nz(x)
        elif op == 0xA8:  # TAY
            y = set_nz(a)
        elif op == 0x98:  # TYA
            a = set_nz(y)
        elif op == 0x48:  # PHA
            mem[0x0100 | sp] = a
            sp = (sp - 1) & 0xFF
        elif op == 0x68:  # PLA
            sp = (sp + 1) & 0xFF
            a = set_nz(mem[0x0100 | sp])
        elif op == 0x38:  # SEC
            c_flag = 1
        elif op == 0x18:  # CLC
            c_flag = 0
        elif op == 0x69:  # ADC #imm
            imm = mem[pc]; pc += 1
            res = a + imm + c_flag
            c_flag = 1 if res > 255 else 0
            a = set_nz(res)
        elif op == 0xE9:  # SBC #imm
            imm = mem[pc]; pc += 1
            res = a - imm - (1 - c_flag)
            c_flag = 1 if res >= 0 else 0
            a = set_nz(res)
        elif op == 0xC9:  # CMP #imm
            imm = mem[pc]; pc += 1
            c_flag = 1 if a >= imm else 0
            set_nz(a - imm)
        elif op == 0xE0:  # CPX #imm
            imm = mem[pc]; pc += 1
            c_flag = 1 if x >= imm else 0
            set_nz(x - imm)
        elif op == 0xC0:  # CPY #imm
            imm = mem[pc]; pc += 1
            c_flag = 1 if y >= imm else 0
            set_nz(y - imm)
        elif op == 0xF0:  # BEQ
            off = rel(mem[pc]); pc += 1
            if z_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0xD0:  # BNE
            off = rel(mem[pc]); pc += 1
            if not z_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0xB0:  # BCS
            off = rel(mem[pc]); pc += 1
            if c_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0x90:  # BCC
            off = rel(mem[pc]); pc += 1
            if not c_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0x4C:  # JMP abs
            pc = mem[pc] | (mem[pc + 1] << 8)
        elif op == 0x20:  # JSR abs
            target = mem[pc] | (mem[pc + 1] << 8)
            ret = (pc + 1) & 0xFFFF
            mem[0x0100 | sp] = (ret >> 8) & 0xFF
            sp = (sp - 1) & 0xFF
            mem[0x0100 | sp] = ret & 0xFF
            sp = (sp - 1) & 0xFF
            pc = target
        elif op == 0x60:  # RTS
            sp = (sp + 1) & 0xFF
            lo = mem[0x0100 | sp]
            sp = (sp + 1) & 0xFF
            hi = mem[0x0100 | sp]
            pc = ((lo | (hi << 8)) + 1) & 0xFFFF
        elif op == 0xEA:  # NOP
            pass
        else:
            raise RuntimeError(f"Unknown 6502 opcode 0x{op:02X} at 0x{pc-1:04X}")
    sys.stdout.buffer.write(out)

if __name__ == "__main__":
    with open(sys.argv[1], "rb") as f:
        run(f.read())
