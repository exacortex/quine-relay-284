#!/usr/bin/env ruby
# Rail interpreter for Quine Relay B20.
# Spec: https://esolangs.org/wiki/Rail
lines = File.binread(ARGV[0]).split(/\r?\n/, -1)
w = lines.map(&:bytesize).max || 1
grid = lines.map { |l| l.ljust(w) }

r = 0
c = 0
grid.each_with_index do |l, idx|
  if l.start_with?("$")
    r = idx
    c = 0
    break
  end
end

dr = 1
dc = 1
stack = []
out = +""
loop do
  r += dr
  c += dc
  ch = grid[r][c]
  case ch
  when "#"
    break
  when "\\"
    if dr == 0 && dc == 1
      dr, dc = 1, 1
    elsif dr == 0 && dc == -1
      dr, dc = -1, -1
    elsif dr == 1 && dc == 0
      dr, dc = 1, 1
    elsif dr == -1 && dc == 0
      dr, dc = -1, -1
    end
  when "/"
    if dr == 0 && dc == 1
      dr, dc = -1, 1
    elsif dr == 0 && dc == -1
      dr, dc = 1, -1
    elsif dr == 1 && dc == 0
      dr, dc = 1, -1
    elsif dr == -1 && dc == 0
      dr, dc = -1, 1
    end
  when "-"
    if dr == 1 && dc == 1
      dr, dc = 0, 1
    elsif dr == -1 && dc == 1
      dr, dc = 0, 1
    elsif dr == 1 && dc == -1
      dr, dc = 0, -1
    elsif dr == -1 && dc == -1
      dr, dc = 0, -1
    end
  when "["
    s = +""
    loop do
      r += dr
      c += dc
      cur = grid[r][c]
      if cur == "\\"
        r += dr
        c += dc
        esc = grid[r][c]
        s << (esc == "n" ? "\n" : esc)
      elsif cur == "]"
        break
      else
        s << cur
      end
    end
    stack.push(s)
  when "o"
    out << stack.pop.to_s
  end
end
STDOUT.binmode
STDOUT.write(out)
