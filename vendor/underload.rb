#!/usr/bin/env ruby
# Underload interpreter for Quine Relay B19.
# Spec: https://esolangs.org/wiki/Underload
src = File.binread(ARGV[0])
stack = []
out = +""
i = 0
n = src.bytesize
while i < n
  c = src.getbyte(i)
  case c
  when 40 # '('
    depth = 1
    i += 1
    start = i
    while i < n && depth > 0
      b = src.getbyte(i)
      depth += 1 if b == 40
      depth -= 1 if b == 41
      i += 1
    end
    stack.push(src.byteslice(start, i - 1 - start))
    next
  when 83 # 'S'
    out << stack.pop
  when 58 # ':'
    stack.push(stack.last)
  when 33 # '!'
    stack.pop
  when 126 # '~'
    stack[-1], stack[-2] = stack[-2], stack[-1]
  when 42 # '*'
    b = stack.pop
    a = stack.pop
    stack.push(a + b)
  when 97 # 'a'
    stack.push("(" + stack.pop + ")")
  when 94 # '^'
    code = stack.pop
    src = code + src.byteslice(i + 1, n - i - 1)
    i = 0
    n = src.bytesize
    next
  end
  i += 1
end
STDOUT.binmode
STDOUT.write(out)
