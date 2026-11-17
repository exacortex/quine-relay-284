#!/usr/bin/env ruby
# Deadfish~ interpreter for Quine Relay B20.
# Spec: https://esolangs.org/wiki/Deadfish~
src = File.binread(ARGV[0])
a = 0
out = +""

exec_block = lambda do |code, i, n|
  while i < n
    c = code.getbyte(i)
    case c
    when 123 # '{'
      depth = 1
      j = i + 1
      while j < n && depth > 0
        b = code.getbyte(j)
        depth += 1 if b == 123
        depth -= 1 if b == 125
        j += 1
      end
      inner = code.byteslice(i + 1, j - 1 - (i + 1))
      10.times do
        break if exec_block.call(inner, 0, inner.bytesize) == :halt
      end
      i = j
      next
    when 105 # 'i'
      j = i + 1
      j += 1 while j < n && code.getbyte(j) == 105
      run = j - i
      if a + run < 256
        a += run
      else
        run.times do
          a += 1
          a = 0 if a == 256 || a == -1
        end
      end
      i = j
      next
    when 100 # 'd'
      j = i + 1
      j += 1 while j < n && code.getbyte(j) == 100
      run = j - i
      if a - run >= 0
        a -= run
      else
        a = 0
      end
      i = j
      next
    when 115 # 's'
      a *= a
      a = 0 if a == 256 || a == -1
    when 99 # 'c'
      out << (a & 0xFF).chr
    when 111 # 'o'
      out << a.to_s
    when 119 # 'w'
      out << "Hello, World!"
    when 104 # 'h'
      return :halt
    end
    i += 1
  end
  nil
end

exec_block.call(src, 0, src.bytesize)
STDOUT.binmode
STDOUT.write(out)
