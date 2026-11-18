require_relative "code-gen"

apts = RunSteps.flat_map {|s| s.apt }
other_packages = %w(libpng-dev libgd-dev libfl-dev groff flex bison curl git ca-certificates)

apts = [*apts.flatten.compact.uniq, *other_packages].uniq.sort

def squash_installs(files)
  out = []
  files.each do |f|
    insns = []
    cur = nil
    File.read(f).each_line do |l|
      l = l.chomp
      if cur
        cur << "\n" << l
      else
        next if l.strip.empty? || l.lstrip.start_with?("#")
        cur = l.dup
      end
      if cur.end_with?("\\")
        next
      else
        insns << cur
        cur = nil
      end
    end
    insns << cur if cur
    group = []
    flush = lambda do
      next if group.empty?
      out << "RUN " + group.map {|b| "( #{ b } )" }.join(" && \\\n    ")
      group.clear
    end
    insns.each do |i|
      if i =~ /\ARUN\s+(.*)\z/m
        body = $1
        raise "#{ f }: RUN in exec form cannot be squashed" if body.start_with?("[")
        group << body
      else
        flush.call
        out << i
      end
    end
    flush.call
  end
  out
end

dockerfile = []
dockerfile << "FROM ubuntu:#{ `bash -c 'source /etc/os-release && echo $VERSION_ID'`.chomp }"
dockerfile << "ENV DEBIAN_FRONTEND=noninteractive CARGO_HTTP_MULTIPLEXING=false CARGO_NET_RETRY=10"
dockerfile << "RUN dpkg-divert --quiet --local --rename --add /usr/bin/sync && ln -sf /bin/true /usr/bin/sync && apt-get update && apt-get upgrade -y && apt-get -qq install -y apt-utils moreutils > /dev/null && apt-get clean"
apts.each_slice(20) do |apt|
  dockerfile << "RUN chronic apt-get -qq install -y #{ apt.join(" ") } && chronic apt-get clean"
end
# Non-apt toolchains from the 151/157 base (pinned)
dockerfile << "RUN chronic apt-get -qq install -y python3-pip golang-go cargo && chronic apt-get clean"
dockerfile << "RUN pip install --break-system-packages --ignore-installed coconut==3.2.0"
dockerfile << "RUN GOBIN=/usr/local/bin go install github.com/d5/tengo/v2/cmd/tengo@v2.17.0 && GOBIN=/usr/local/bin go install github.com/mattn/anko@v0.1.15"
dockerfile << "RUN cargo install --root /usr/local rhai@1.27.0 --features bin-features --bin rhai-run && cargo install --root /usr/local koto_cli@0.16.1"
# Squashed per-batch installs (stays well below Docker's 127-layer overlay2 limit)
dockerfile.concat(squash_installs(Dir[File.join(__dir__, "extra-installs", "*.txt")].sort))
dockerfile << "ADD . /usr/local/share/quine-relay"
dockerfile << "WORKDIR /usr/local/share/quine-relay"
dockerfile << "RUN make -C vendor && rm -f /usr/bin/sync && dpkg-divert --quiet --local --rename --remove /usr/bin/sync"
dockerfile << "CMD make check -j 10000"

File.write("../Dockerfile", dockerfile.join("\n") + "\n")
