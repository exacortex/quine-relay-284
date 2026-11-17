#!/usr/bin/env ruby
# Beatnik interpreter for Quine Relay B20.
# Spec: https://esolangs.org/wiki/Beatnik
SCORES = {
  "A" => 1, "B" => 3, "C" => 3, "D" => 2, "E" => 1, "F" => 4, "G" => 2, "H" => 4,
  "I" => 1, "J" => 8, "K" => 5, "L" => 1, "M" => 3, "N" => 1, "O" => 1, "P" => 3,
  "Q" => 10, "R" => 1, "S" => 1, "T" => 1, "U" => 1, "V" => 4, "W" => 4, "X" => 8,
  "Y" => 4, "Z" => 10
}.freeze

src = File.binread(ARGV[0])
vals = src.scan(/[A-Za-z]+/).map do |w|
  s = 0
  w.upcase.each_char { |ch| s += SCORES[ch] || 0 }
  s
end

stack = []
out = +""
i = 0
n = vals.size
while i < n
  case vals[i]
  when 5
    stack.push(vals[i + 1] || 0)
    i += 2
  when 6
    stack.pop
    i += 1
  when 7
    b = stack.pop || 0
    a = stack.pop || 0
    stack.push((a + b) & 0xFF)
    i += 1
  when 8
    c = STDIN.getbyte
    stack.push(c || 0)
    i += 1
  when 9
    out << ((stack.pop || 0) & 0xFF).chr
    i += 1
  when 10
    b = stack.pop || 0
    a = stack.pop || 0
    stack.push((a - b) & 0xFF)
    i += 1
  when 11
    b = stack.pop || 0
    a = stack.pop || 0
    stack.push(b, a)
    i += 1
  when 12
    stack.push(stack.last || 0)
    i += 1
  when 13
    off = vals[i + 1] || 0
    i = (stack.pop || 0) == 0 ? i + 2 + off : i + 2
  when 14
    off = vals[i + 1] || 0
    i = (stack.pop || 0) != 0 ? i + 2 + off : i + 2
  when 15
    off = vals[i + 1] || 0
    i = (stack.pop || 0) == 0 ? i + 1 - off : i + 2
  when 16
    off = vals[i + 1] || 0
    i = (stack.pop || 0) != 0 ? i + 1 - off : i + 2
  when 17..Float::INFINITY
    break
  else
    i += 1
  end
end
STDOUT.binmode
STDOUT.write(out)
