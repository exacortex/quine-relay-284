#!/usr/bin/env python3
# Z80 CLI emulator for Quine Relay B18 (loads flat binary at $0000, OUT (1),A -> stdout, stops on HALT).
import sys

def run(rom: bytes):
    mem = bytearray(65536)
    mem[0:len(rom)] = rom
    pc = 0x0000
    sp = 0xFFFF
    a = f = b = c = d = e = h = l = 0
    z_flag = 0
    c_flag = 0
    out = bytearray()

    def rel(offset):
        return offset - 256 if offset >= 128 else offset

    while True:
        op = mem[pc]
        pc = (pc + 1) & 0xFFFF
        if op == 0x76:  # HALT
            break
        elif op == 0x00:  # NOP
            pass
        elif op == 0x31:  # LD SP, nn
            sp = mem[pc] | (mem[pc + 1] << 8); pc += 2
        elif op == 0x21:  # LD HL, nn
            l = mem[pc]; h = mem[pc + 1]; pc += 2
        elif op == 0x11:  # LD DE, nn
            e = mem[pc]; d = mem[pc + 1]; pc += 2
        elif op == 0x01:  # LD BC, nn
            c = mem[pc]; b = mem[pc + 1]; pc += 2
        elif op == 0x3E:  # LD A, n
            a = mem[pc]; pc += 1
        elif op == 0x06:  # LD B, n
            b = mem[pc]; pc += 1
        elif op == 0x0E:  # LD C, n
            c = mem[pc]; pc += 1
        elif op == 0x16:  # LD D, n
            d = mem[pc]; pc += 1
        elif op == 0x1E:  # LD E, n
            e = mem[pc]; pc += 1
        elif op == 0x7E:  # LD A, (HL)
            a = mem[(h << 8) | l]
        elif op == 0x46:  # LD B, (HL)
            b = mem[(h << 8) | l]
        elif op == 0x4E:  # LD C, (HL)
            c = mem[(h << 8) | l]
        elif op == 0x56:  # LD D, (HL)
            d = mem[(h << 8) | l]
        elif op == 0x5E:  # LD E, (HL)
            e = mem[(h << 8) | l]
        elif op == 0x5F:  # LD E, A
            e = a
        elif op == 0x78:  # LD A, B
            a = b
        elif op == 0x79:  # LD A, C
            a = c
        elif op == 0xB7:  # OR A
            z_flag = 1 if a == 0 else 0
            c_flag = 0
        elif op == 0xFE:  # CP n
            n = mem[pc]; pc += 1
            z_flag = 1 if a == n else 0
            c_flag = 1 if a < n else 0
        elif op == 0xD6:  # SUB n
            n = mem[pc]; pc += 1
            c_flag = 1 if a < n else 0
            a = (a - n) & 0xFF
            z_flag = 1 if a == 0 else 0
        elif op == 0x23:  # INC HL
            hl = (((h << 8) | l) + 1) & 0xFFFF
            h = (hl >> 8) & 0xFF; l = hl & 0xFF
        elif op == 0x19:  # ADD HL, DE
            hl = ((h << 8) | l) + ((d << 8) | e)
            c_flag = 1 if hl > 0xFFFF else 0
            hl &= 0xFFFF
            h = (hl >> 8) & 0xFF; l = hl & 0xFF
        elif op == 0x18:  # JR d
            off = rel(mem[pc]); pc = (pc + 1 + off) & 0xFFFF
        elif op == 0x28:  # JR Z, d
            off = rel(mem[pc]); pc += 1
            if z_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0x20:  # JR NZ, d
            off = rel(mem[pc]); pc += 1
            if not z_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0x30:  # JR NC, d
            off = rel(mem[pc]); pc += 1
            if not c_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0x38:  # JR C, d
            off = rel(mem[pc]); pc += 1
            if c_flag:
                pc = (pc + off) & 0xFFFF
        elif op == 0xC3:  # JP nn
            pc = mem[pc] | (mem[pc + 1] << 8)
        elif op == 0xCA:  # JP Z, nn
            target = mem[pc] | (mem[pc + 1] << 8); pc += 2
            if z_flag:
                pc = target
        elif op == 0xD2:  # JP NC, nn
            target = mem[pc] | (mem[pc + 1] << 8); pc += 2
            if not c_flag:
                pc = target
        elif op == 0xCD:  # CALL nn
            target = mem[pc] | (mem[pc + 1] << 8); pc += 2
            sp = (sp - 1) & 0xFFFF; mem[sp] = (pc >> 8) & 0xFF
            sp = (sp - 1) & 0xFFFF; mem[sp] = pc & 0xFF
            pc = target
        elif op == 0xC9:  # RET
            lo = mem[sp]; sp = (sp + 1) & 0xFFFF
            hi = mem[sp]; sp = (sp + 1) & 0xFFFF
            pc = (hi << 8) | lo
        elif op == 0xE5:  # PUSH HL
            sp = (sp - 1) & 0xFFFF; mem[sp] = h
            sp = (sp - 1) & 0xFFFF; mem[sp] = l
        elif op == 0xE1:  # POP HL
            l = mem[sp]; sp = (sp + 1) & 0xFFFF
            h = mem[sp]; sp = (sp + 1) & 0xFFFF
        elif op == 0xC5:  # PUSH BC
            sp = (sp - 1) & 0xFFFF; mem[sp] = b
            sp = (sp - 1) & 0xFFFF; mem[sp] = c
        elif op == 0xC1:  # POP BC
            c = mem[sp]; sp = (sp + 1) & 0xFFFF
            b = mem[sp]; sp = (sp + 1) & 0xFFFF
        elif op == 0xF5:  # PUSH AF
            sp = (sp - 1) & 0xFFFF; mem[sp] = a
            sp = (sp - 1) & 0xFFFF; mem[sp] = f
        elif op == 0xF1:  # POP AF
            f = mem[sp]; sp = (sp + 1) & 0xFFFF
            a = mem[sp]; sp = (sp + 1) & 0xFFFF
        elif op == 0xD3:  # OUT (n), A
            port = mem[pc]; pc += 1
            out.append(a & 0xFF)
        else:
            raise RuntimeError(f"Unknown Z80 opcode 0x{op:02X} at 0x{pc-1:04X}")
    sys.stdout.buffer.write(out)

if __name__ == "__main__":
    with open(sys.argv[1], "rb") as f:
        run(f.read())
