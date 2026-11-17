#!/usr/bin/env ruby
# Emmental interpreter for Quine Relay B16.
# Spec: https://esolangs.org/wiki/Emmental
src = File.binread(ARGV[0])
defs = Array.new(256) { |i| i.chr }
stack = []
queue = []
out = +""

run_code = lambda do |code|
  i = 0
  n = code.bytesize
  while i < n
    b = code.getbyte(i)
    op = defs[b]
    if op.bytesize != 1 || op.getbyte(0) != b
      run_code.call(op)
      i += 1
      next
    end
    case b
    when 35 # '#'
      stack.push(0)
    when 48..57 # '0'..'9'
      stack[-1] = ((stack[-1] || 0) * 10 + (b - 48)) & 0xFF
    when 43 # '+'
      y = stack.pop
      x = stack.pop
      stack.push((x + y) & 0xFF)
    when 45 # '-'
      y = stack.pop
      x = stack.pop
      stack.push((x - y) & 0xFF)
    when 126 # '~'
      x = stack.pop
      stack.push(x == 0 ? 0 : (Math.log2(x).to_i & 0xFF))
    when 46 # '.'
      out << (stack.pop & 0xFF).chr
    when 44 # ','
      c = STDIN.getbyte
      stack.push(c || 0)
    when 94 # '^'
      stack.push(queue.shift || 0)
    when 118 # 'v'
      queue.push(stack.pop || 0)
    when 58 # ':'
      stack.push(stack.last || 0)
    when 59 # ';'
      stack.push(59)
    when 33 # '!'
      sym = stack.pop
      buf = +""
      while (v = stack.pop) && v != 59
        buf << (v & 0xFF).chr
      end
      defs[sym & 0xFF] = buf.reverse
    when 63 # '?'
      sym = stack.pop
      run_code.call(defs[sym & 0xFF])
    end
    i += 1
  end
end

run_code.call(src)
STDOUT.binmode
STDOUT.write(out)
