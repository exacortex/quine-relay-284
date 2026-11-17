#!/usr/bin/env ruby
# CJam interpreter for Quine Relay B19.
# Spec: https://esolangs.org/wiki/CJam
src = File.binread(ARGV[0])
stack = []
out = +""
i = 0
n = src.bytesize
while i < n
  c = src[i]
  case c
  when '"'
    i += 1
    s = +""
    while i < n && src[i] != '"'
      if src[i] == "\\" && i + 1 < n
        i += 1
        s << src[i]
      else
        s << src[i]
      end
      i += 1
    end
    stack.push(s)
    i += 1
  when "'"
    i += 1
    stack.push(src[i]) if i < n
    i += 1
  when "0".."9"
    j = i
    j += 1 while j < n && src[j] =~ /[0-9]/
    stack.push(src.byteslice(i, j - i).to_i)
    i = j
  when "o"
    out << stack.pop.to_s
    i += 1
  when "p"
    out << stack.pop.inspect << "\n"
    i += 1
  when "N"
    stack.push("\n")
    i += 1
  when "S"
    stack.push(" ")
    i += 1
  when "+"
    b = stack.pop
    a = stack.pop
    stack.push(a.to_s + b.to_s)
    i += 1
  when ";"
    stack.pop
    i += 1
  when ":"
    i += 1
    i += 1 if i < n
  else
    i += 1
  end
end
STDOUT.binmode
STDOUT.write(out)
stack.each { |x| STDOUT.write(x.to_s) }
