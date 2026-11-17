#!/usr/bin/env ruby
# Kipple interpreter for Quine Relay B20.
# Spec: https://esolangs.org/wiki/Kipple
src = File.binread(ARGV[0])
src = src.gsub(/<([^>]*)>\s*>\s*([a-zA-Z@])/) do
  raw, st = $1, $2
  str = raw.gsub(/!([0-9a-fA-F]{2})/) { $1.to_i(16).chr }
  str.bytes.map { |b| "#{b}>#{st}" }.join(" ")
end
src = src.gsub(/"((?:\\.|[^"\\])*)"\s*>\s*([a-zA-Z@])/) do
  raw, st = $1, $2
  str = raw.gsub(/\\(.)/) { $1 == "n" ? "\n" : $1 }
  str.bytes.map { |b| "#{b}>#{st}" }.join(" ")
end

stacks = Array.new(128) { [] }
tokens = src.scan(/\([a-zA-Z@]|[0-9]+>[a-zA-Z@]|[a-zA-Z@][><][0-9]+|[a-zA-Z@][><][a-zA-Z@]|[a-zA-Z@][+-][0-9]+|[a-zA-Z@][+-][a-zA-Z@]|[a-zA-Z@]\?|\)/)

lstack = []
ops = tokens.each_with_index.map do |t, idx|
  if t.start_with?("(")
    lstack.push(idx)
    [0, t[1].downcase.ord, 0]
  elsif t == ")"
    open_idx = lstack.pop
    [1, tokens[open_idx][1].downcase.ord, open_idx + 1]
  elsif t.end_with?("?")
    [2, t[0].downcase.ord, 0]
  elsif t =~ /\A([0-9]+)>([a-zA-Z@])\z/
    [3, $2.downcase.ord, $1.to_i]
  elsif t =~ /\A([a-zA-Z@])<([0-9]+)\z/
    [3, $1.downcase.ord, $2.to_i]
  elsif t =~ /\A([a-zA-Z@])>([a-zA-Z@])\z/
    [4, $1.downcase.ord, $2.downcase.ord]
  elsif t =~ /\A([a-zA-Z@])<([a-zA-Z@])\z/
    [4, $2.downcase.ord, $1.downcase.ord]
  elsif t =~ /\A([a-zA-Z@])\+([0-9]+)\z/
    [5, $1.downcase.ord, $2.to_i]
  elsif t =~ /\A([a-zA-Z@])-([0-9]+)\z/
    [6, $1.downcase.ord, $2.to_i]
  elsif t =~ /\A([a-zA-Z@])\+([a-zA-Z@])\z/
    [7, $1.downcase.ord, $2.downcase.ord]
  elsif t =~ /\A([a-zA-Z@])-([a-zA-Z@])\z/
    [8, $1.downcase.ord, $2.downcase.ord]
  end
end
ops.each_with_index do |ins, idx|
  ops[ins[2] - 1][2] = idx + 1 if ins[0] == 1
end

pc = 0
n = ops.size
while pc < n
  op, a, b = ops[pc]
  case op
  when 0
    if stacks[a].empty?
      pc = b
      next
    end
  when 1
    unless stacks[a].empty?
      pc = b
      next
    end
  when 2
    stacks[a].clear if (stacks[a].last || 0) == 0
  when 3
    stacks[a].push(b)
  when 4
    stacks[b].push(stacks[a].pop || 0)
  when 5
    stacks[a].push((stacks[a].pop || 0) + b)
  when 6
    stacks[a].push((stacks[a].pop || 0) - b)
  when 7
    rhs = stacks[b].pop || 0
    stacks[a].push((stacks[a].pop || 0) + rhs)
  when 8
    rhs = stacks[b].pop || 0
    stacks[a].push((stacks[a].pop || 0) - rhs)
  end
  pc += 1
end

STDOUT.binmode
STDOUT.write(stacks[111].reverse.map { |x| (x & 0xFF).chr }.join)
