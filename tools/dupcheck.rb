# dupcheck.rb - fail if two steps would use the same source file (the QR.ss bug that broke the first
# 157 lap: make silently dropped a dependency and ran SurgeScript before its file existed).
#   ruby dupcheck.rb code-gen.rb
src = File.read(ARGV[0])
seen = {}
bad = []
src.scan(/^class (\w+) < CodeGen\b(.*?)^end\n/m) do |cls, body|
  line = body[/^\s*File\s*=\s*(.+)$/, 1] or next
  line.scan(/"([^"]+)"/).flatten.each do |f|
    bad << "#{f}: #{seen[f]} and #{cls}" if seen[f]
    bad << "#{f}: #{cls} uses a reserved name" if %w(QR.rb QR2.rb).include?(f) && cls != "Ruby_"
    seen[f] ||= cls
  end
end
names = src.scan(/^class (\w+) < CodeGen\b/).flatten
names.group_by { |n| n }.each { |n, a| bad << "class #{n} defined #{a.size} times" if a.size > 1 }
if bad.empty?
  puts "dupcheck ok: #{seen.size} source files, #{names.size} classes"
else
  puts "DUPCHECK FAILED:", *bad.map { |b| "  " + b }
  exit 1
end
