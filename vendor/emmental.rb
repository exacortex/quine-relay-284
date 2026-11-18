#!/usr/bin/env ruby
# Emmental interpreter for Quine Relay B16 (matches Chris Pressey's catseye/Emmental Emmental.hs).
# Spec: https://esolangs.org/wiki/Emmental
src = File.binread(ARGV[0])
defs = Array.new(256) { |i| [i] }
stack = []
queue = []
out = +""

run_ops = lambda do |ops|
  i = 0
  n = ops.size
  while i < n
    b = ops[i]
    if b.is_a?(Array)
      run_ops.call(b)
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
    when 126 # '~' (discreteLog 0 = 8, discreteLog n = floor(log2(n)))
      x = stack.pop & 0xFF
      stack.push(x == 0 ? 8 : Math.log2(x).to_i)
    when 46 # '.'
      out << (stack.pop & 0xFF).chr
    when 44 # ','
      c = STDIN.getbyte
      stack.push(c || 0)
    when 94 # '^' (enqueue copy of stack top without popping)
      queue.push(stack.last || 0)
    when 118 # 'v' (dequeue and push onto stack)
      stack.push(queue.shift || 0)
    when 58 # ':'
      stack.push(stack.last || 0)
    when 59 # ';'
      stack.push(59)
    when 33 # '!' (lexical capture of current defs, matching createOp in Emmental.hs)
      sym = stack.pop & 0xFF
      buf = []
      while (v = stack.pop) && v != 59
        buf << (v & 0xFF)
      end
      compiled = buf.reverse.map do |c|
        cur = defs[c]
        cur.size == 1 && cur[0] == c ? c : cur
      end
      defs[sym] = compiled
    when 63 # '?'
      sym = stack.pop & 0xFF
      run_ops.call(defs[sym])
    end
    i += 1
  end
end

i = 0
n = src.bytesize
while i < n
  b = src.getbyte(i)
  cur = defs[b]
  if cur.size == 1 && cur[0] == b
    run_ops.call(cur)
  else
    run_ops.call(cur)
  end
  i += 1
end

STDOUT.binmode
STDOUT.write(out)
