# zonemap.rb - for every step, what it has to print (= what a language inserted right after it must embed).
# Run inside src/ after the .dat files exist. Writes CSV to stdout, in run order.
#   run,class,languages,bytes,backslashes,dquotes,squotes,newlines,max_line
require "./code-gen"
# same construction as QR.rb.gen.rb: prologue part 2 + the nested steps, run behind prologue part 1
s = GenPrologue.split(?;)[2..-1].join(?;) + ?; +
    GenSteps[0..-2].inject('"eval$s=%q(#$s)"') { |code, g| g.code.sub("PREV") { "check[#{g.name.dump},#{code},:check_end]" }.chomp }
s = (GenPrologue.split(?;)[0, 2].join(?;) + ?; + s).gsub(/[^\S ]/, "")
$s = File.binread("../QR.rb")[/\Aeval\$s=%q\((.*)\)\n?\z/m, 1] or abort "no $s"
rows = {}
steps = GenSteps.each
check = ->(name, prev, _e) { st = steps.next; raise "order" if st.name != name; rows[name] = prev; prev }
rows[GenSteps[-1].name] = Object.new.instance_eval(s)   # the outermost step (Ruby) prints what the whole chain evaluates to
qr = File.binread("../QR.rb")
puts "run,class,languages,bytes,backslashes,dquotes,squotes,newlines,max_line"
CodeGen::List.reverse.each_with_index do |c, i|
  p = rows[c.name] || qr
  langs = c.run_steps.map(&:name).join(" > ")
  ml = p.each_line.map(&:size).max || 0
  puts [i + 1, c.name, langs.inspect, p.bytesize, p.count("\\"), p.count('"'), p.count("'"), p.count("\n"), ml].join(",")
end
