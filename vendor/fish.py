#!/usr/bin/env python3
# ><> (Fish) interpreter for Quine Relay B19.
# Spec: https://esolangs.org/wiki/%3E%3C%3E
import sys

def run(src: str):
    lines = src.split("\n")
    w = max((len(l) for l in lines), default=1) or 1
    grid = [list(l.ljust(w)) for l in lines]
    h = len(grid)
    x = y = 0
    dx, dy = 1, 0
    stack = []
    reg = [None]
    str_mode = None
    skip = False
    out = bytearray()
    while True:
        ch = grid[y][x]
        if skip:
            skip = False
        elif str_mode is not None:
            if ch == str_mode:
                str_mode = None
            else:
                stack.append(ord(ch))
        else:
            if ch == '"' or ch == "'":
                str_mode = ch
            elif ch == ">":
                dx, dy = 1, 0
            elif ch == "<":
                dx, dy = -1, 0
            elif ch == "v":
                dx, dy = 0, 1
            elif ch == "^":
                dx, dy = 0, -1
            elif ch == "/":
                dx, dy = -dy, -dx
            elif ch == "\\":
                dx, dy = dy, dx
            elif ch == "|":
                dx = -dx
            elif ch == "_":
                dy = -dy
            elif ch == "#":
                dx, dy = -dx, -dy
            elif "0" <= ch <= "9":
                stack.append(ord(ch) - 48)
            elif "a" <= ch <= "f":
                stack.append(ord(ch) - 87)
            elif ch == "+":
                b, a = stack.pop(), stack.pop()
                stack.append(a + b)
            elif ch == "-":
                b, a = stack.pop(), stack.pop()
                stack.append(a - b)
            elif ch == "*":
                b, a = stack.pop(), stack.pop()
                stack.append(a * b)
            elif ch == ",":
                b, a = stack.pop(), stack.pop()
                stack.append(a // b)
            elif ch == "%":
                b, a = stack.pop(), stack.pop()
                stack.append(a % b)
            elif ch == "=":
                b, a = stack.pop(), stack.pop()
                stack.append(1 if a == b else 0)
            elif ch == ")":
                b, a = stack.pop(), stack.pop()
                stack.append(1 if a > b else 0)
            elif ch == "(":
                b, a = stack.pop(), stack.pop()
                stack.append(1 if a < b else 0)
            elif ch == ":":
                stack.append(stack[-1])
            elif ch == "~":
                stack.pop()
            elif ch == "$":
                stack[-1], stack[-2] = stack[-2], stack[-1]
            elif ch == "@":
                stack[-1], stack[-2], stack[-3] = stack[-2], stack[-3], stack[-1]
            elif ch == "}":
                stack.insert(0, stack.pop())
            elif ch == "{":
                stack.append(stack.pop(0))
            elif ch == "r":
                stack.reverse()
            elif ch == "l":
                stack.append(len(stack))
            elif ch == "&":
                if reg[-1] is None:
                    reg[-1] = stack.pop()
                else:
                    stack.append(reg[-1])
                    reg[-1] = None
            elif ch == "g":
                gy, gx = stack.pop(), stack.pop()
                stack.append(ord(grid[gy][gx]) if 0 <= gy < h and 0 <= gx < w else 0)
            elif ch == "p":
                gy, gx, gv = stack.pop(), stack.pop(), stack.pop()
                grid[gy][gx] = chr(gv)
            elif ch == "?":
                if stack.pop() == 0:
                    skip = True
            elif ch == "!":
                skip = True
            elif ch == ";":
                break
            elif ch == "o":
                out.append(stack.pop() & 0xFF)
            elif ch == "n":
                out.extend(str(int(stack.pop())).encode("ascii"))
            elif ch == ".":
                ny, nx = stack.pop(), stack.pop()
                x, y = nx, ny
        x = (x + dx) % w
        y = (y + dy) % h
    sys.stdout.buffer.write(out)

if __name__ == "__main__":
    with open(sys.argv[1], "r", encoding="latin1") as f:
        run(f.read())
