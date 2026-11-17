#!/usr/bin/env ruby
# Glass interpreter for Quine Relay B20.
# Spec: https://esolangs.org/wiki/Glass
src = File.binread(ARGV[0])
m_start = src.index("[m")
m_end = src.rindex("]")
body = m_start && m_end ? src.byteslice(m_start + 2, m_end - m_start - 2) : src

# Tokenize body into instructions for fast execution
tokens = []
i = 0
n = body.bytesize
while i < n
  c = body[i]
  case c
  when '"'
    i += 1
    s = +""
    while i < n && body[i] != '"'
      if body[i] == "\\" && i + 1 < n
        i += 1
        esc = body[i]
        s << (esc == "n" ? "\n" : esc)
      else
        s << body[i]
      end
      i += 1
    end
    tokens << [:str, s]
    i += 1
  when "("
    fin = body.index(")", i + 1)
    val = body.byteslice(i + 1, fin - i - 1)
    if val =~ /\A-?[0-9]+\z/
      tokens << [:num, val.to_i]
    else
      tokens << [:sym, val]
    end
    i = fin + 1
  when "/"
    i += 1
    if body[i] == "("
      fin = body.index(")", i + 1)
      vname = body.byteslice(i + 1, fin - i - 1)
      i = fin + 1
    else
      vname = body[i]
      i += 1
    end
    tokens << [:loop_start, vname, 0]
  when "\\"
    tokens << [:loop_end, nil, 0]
    i += 1
  when "!", ".", "?", "$", "*", ",", "^"
    tokens << [c]
    i += 1
  when "A".."Z", "a".."z"
    tokens << [:sym, c]
    i += 1
  else
    i += 1
  end
end

lstack = []
tokens.each_with_index do |t, idx|
  if t[0] == :loop_start
    lstack.push(idx)
  elsif t[0] == :loop_end
    open_idx = lstack.pop
    t[1] = tokens[open_idx][1]
    t[2] = open_idx + 1
    tokens[open_idx][2] = idx + 1
  end
end

stack = []
vars = {}
out = +""
pc = 0
tn = tokens.size
while pc < tn
  t = tokens[pc]
  case t[0]
  when :str, :num, :sym
    stack.push(t[1])
  when "$"
    val = stack.pop
    var = stack.pop
    vars[var] = val
  when "*"
    var = stack.pop
    stack.push(vars[var])
  when ","
    stack.pop
  when "^"
    stack.push(stack.last)
  when "!"
    cls = stack.pop
    var = stack.pop
    vars[var] = cls
  when "."
    meth = stack.pop
    var = stack.pop
    stack.push([vars[var], meth])
  when "?"
    cls, meth = stack.pop
    if cls == "O"
      if meth == "o"
        out << stack.pop.to_s
      elsif meth == "on"
        out << stack.pop.to_i.to_s
      end
    elsif cls == "S"
      if meth == "l"
        stack.push(stack.pop.to_s.bytesize)
      elsif meth == "i"
        idx = stack.pop.to_i
        str = stack.pop.to_s
        stack.push(str.byteslice(idx, 1) || "")
      elsif meth == "ns"
        stack.push(stack.pop.to_s.getbyte(0) || 0)
      elsif meth == "sn"
        stack.push((stack.pop.to_i & 0xFF).chr)
      end
    elsif cls == "A"
      b = stack.pop.to_i
      a = stack.pop.to_i
      case meth
      when "a" then stack.push(a + b)
      when "s" then stack.push(a - b)
      when "m" then stack.push(a * b)
      when "d" then stack.push(a / b)
      when "mod" then stack.push(a % b)
      when "e" then stack.push(a == b ? 1 : 0)
      when "ne" then stack.push(a != b ? 1 : 0)
      when "lt" then stack.push(a < b ? 1 : 0)
      when "gt" then stack.push(a > b ? 1 : 0)
      end
    end
  when :loop_start
    v = vars[t[1]]
    if v.nil? || v == 0 || v == ""
      pc = t[2]
      next
    end
  when :loop_end
    v = vars[t[1]]
    if !(v.nil? || v == 0 || v == "")
      pc = t[2]
      next
    end
  end
  pc += 1
end

STDOUT.binmode
STDOUT.write(out)
