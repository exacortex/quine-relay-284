#!/usr/bin/env ruby
# Hexagony interpreter for Quine Relay B19.
# Spec: https://esolangs.org/wiki/Hexagony
src = File.binread(ARGV[0]).gsub(/\s+/, "")
n = 1
n += 1 while 3 * n * (n - 1) + 1 < src.bytesize
src = src.ljust(3 * n * (n - 1) + 1, ".")
grid = []
i = 0
(2 * n - 1).times do |r|
  l = n + (r < n ? r : 2 * n - 2 - r)
  grid << src.byteslice(i, l)
  i += l
end

r = 0
c = 0
val = 0
out = +""
loop do
  ch = grid[r].getbyte(c)
  case ch
  when 64 # '@'
    break
  when 46 # '.'
    # no-op
  when 65..90, 97..122 # 'A'..'Z', 'a'..'z'
    val = ch
  when 48..57 # '0'..'9'
    d = ch - 48
    val = val >= 0 ? val * 10 + d : val * 10 - d
  when 45 # '-'
    val = 0
  when 41 # ')'
    val += 1
  when 40 # '('
    val -= 1
  when 126 # '~'
    val = -val
  when 59 # ';'
    out << (val & 0xFF).chr
  end
  c += 1
  if c >= grid[r].bytesize
    c = 0
    r = (r + n) % (2 * n - 1)
  end
end
STDOUT.binmode
STDOUT.write(out)
