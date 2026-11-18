# usage: ruby dump_steps.rb SRC_DIR OUT_DIR
src, out = ARGV
Dir.chdir(src)
require File.join(src, "code-gen")
gp1 = GenPrologue.split(?;)[0, 2].join(?;)
gp2 = GenPrologue.split(?;)[2..-1].join(?;)
s = gp2 + ?; + GenSteps[0..-2].inject('"eval$s=%q(#$s)"') do |code, g|
  g.code.sub("PREV") { "check[#{ g.name.dump },#{ code },:check_end]" }.chomp
end
$s = File.binread(File.join(src, "../QR.rb"))[/\Aeval\$s=%q\((.*)\)\n?\z/m, 1] or abort "no $s"
Dir.mkdir(out) rescue nil
idx = 0
names = []
check = ->(name, prev, _) do
  idx += 1
  names << name
  File.binwrite(File.join(out, "%03d.out" % idx), prev)
  prev
end
Object.new.instance_eval((gp1 + ?; + s).gsub(/[^\S ]/, ""))
File.write(File.join(out, "names.txt"), names.each_with_index.map{|n,i| "%03d %s" % [i+1,n]}.join("\n")+"\n")
