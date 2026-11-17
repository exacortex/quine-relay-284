#!/usr/bin/env ruby
# Brain-Flak interpreter for Quine Relay B19.
# Supports -A (ASCII output mode) and standard integer output mode.
# Spec: https://esolangs.org/wiki/Brain-Flak
ascii_mode = ARGV.delete("-A") || ARGV.delete("-a")
src = File.binread(ARGV[0]).gsub(/[^()\[\]{}<>]/, "")
tokens = src.scan(/(?:\(\))+|\[\]|\{\}|<>|[()\[\]{}<>]/)

match = {}
bstack = []
tokens.each_with_index do |tok, idx|
  case tok
  when "(", "[", "{", "<"
    bstack.push(idx)
  when ")", "]", "}", ">"
    open_idx = bstack.pop
    match[open_idx] = idx
    match[idx] = open_idx
  end
end

left = []
right = []
active = left
val_stack = [0]
i = 0
n = tokens.size
while i < n
  tok = tokens[i]
  case tok
  when "[]"
    val_stack[-1] += active.size
  when "{}"
    val_stack[-1] += (active.pop || 0)
  when "<>"
    active = active.equal?(left) ? right : left
  when "(", "[", "<"
    val_stack.push(0)
  when ")"
    v = val_stack.pop
    active.push(v)
    val_stack[-1] += v
  when "]"
    v = val_stack.pop
    val_stack[-1] -= v
  when ">"
    val_stack.pop
  when "{"
    if active.empty? || active.last == 0
      i = match[i]
    else
      val_stack.push(0)
    end
  when "}"
    v = val_stack.pop
    val_stack[-1] += v
    if !active.empty? && active.last != 0
      i = match[i]
      val_stack.push(0)
    end
  else
    # Run of ()()...
    val_stack[-1] += tok.bytesize >> 1
  end
  i += 1
end

STDOUT.binmode
if ascii_mode
  STDOUT.write(active.reverse.map { |x| (x & 0xFF).chr }.join)
else
  active.reverse_each { |x| STDOUT.puts(x) }
end
