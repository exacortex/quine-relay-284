# squash-installs.rb FILE... -> Dockerfile lines for the lap image, one layer per installs file.
# Added Nov 15 (merge 248): FROM qr157 + one layer per install line passed Docker's overlay depth limit
# ("max depth exceeded" at 85 new layers). Each file's consecutive RUN instructions become one RUN, each body in
# its own ( subshell ) so a `cd` or `export` can't leak into the next; ENV / COPY / other directives stay as-is
# and split the group. Comments and blank lines are dropped (they were before, too). Contents are unchanged.
out = []
ARGV.each do |f|
  insns = []; cur = nil
  File.read(f).each_line do |l|
    l = l.chomp
    if cur
      cur << "\n" << l
    else
      next if l.strip.empty? || l.lstrip.start_with?("#")
      cur = l.dup
    end
    if cur.end_with?("\\") then next else insns << cur; cur = nil end
  end
  insns << cur if cur
  group = []
  flush = lambda do
    next if group.empty?
    out << "RUN " + group.map { |b| "( #{b} )" }.join(" && \\\n    ")
    group.clear
  end
  insns.each do |i|
    if i =~ /\ARUN\s+(.*)\z/m
      body = $1
      raise "#{f}: RUN in exec (JSON) form can't be squashed: #{i[0, 60]}" if body.start_with?("[")
      group << body
    else
      flush.call; out << i
    end
  end
  flush.call
end
puts out
