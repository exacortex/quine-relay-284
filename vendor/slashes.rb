#!/usr/bin/env ruby
# /// (Slashes) interpreter for Quine Relay B19.
# Spec: https://esolangs.org/wiki////
src = File.binread(ARGV[0])
out = +""
i = 0
n = src.bytesize
while i < n
  c = src.getbyte(i)
  if c == 92 # '\\'
    out << src.getbyte(i + 1).chr if i + 1 < n
    i += 2
  elsif c == 47 # '/'
    i += 1
    pat = +""
    while i < n && src.getbyte(i) != 47
      if src.getbyte(i) == 92 && i + 1 < n
        pat << src.getbyte(i + 1).chr
        i += 2
      else
        pat << src.getbyte(i).chr
        i += 1
      end
    end
    break if i >= n
    i += 1
    rep = +""
    while i < n && src.getbyte(i) != 47
      if src.getbyte(i) == 92 && i + 1 < n
        rep << src.getbyte(i + 1).chr
        i += 2
      else
        rep << src.getbyte(i).chr
        i += 1
      end
    end
    break if i >= n
    src = src.byteslice(i + 1, n - i - 1)
    if !pat.empty?
      src.gsub!(pat) { rep } while src.include?(pat)
    end
    i = 0
    n = src.bytesize
  else
    out << c.chr
    i += 1
  end
end
STDOUT.binmode
STDOUT.write(out)
