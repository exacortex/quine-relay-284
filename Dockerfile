FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive CARGO_HTTP_MULTIPLEXING=false CARGO_NET_RETRY=10
RUN dpkg-divert --quiet --local --rename --add /usr/bin/sync && ln -sf /bin/true /usr/bin/sync && apt-get update && apt-get upgrade -y && apt-get -qq install -y apt-utils moreutils > /dev/null && apt-get clean
RUN chronic apt-get -qq install -y acl2 afnix agda algol68g aspectc++ aspectj asymptote ats2-lang basex bash bc bison bsh busybox-static bwbasic ca-certificates chezscheme chicken-bin chuck clips && chronic apt-get clean
RUN chronic apt-get -qq install -y clisp clojure cmake coffeescript coq crystal curl dash dc default-jdk-headless dhall dotnet-sdk-10.0 elixir elvish emacs-nox erlang erlang-nox execline f2c fennel && chronic apt-get clean
RUN chronic apt-get -qq install -y fish flex fp-compiler fricas g++ gambas3-gb-pcre gambas3-scripter gap gawk gcc gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu gdb gdc generator-scripting-language genius gforth gfortran ghc ghdl && chronic apt-get clean
RUN chronic apt-get -qq install -y ghostscript git gm2 gnat gnucobol4 gnuplot gobjc golang gpt gri groff groovy guile-3.0 gzip hare haxe hy icont iconx inform6-compiler && chronic apt-get clean
RUN chronic apt-get -qq install -y intercal iverilog jasmin-sable jq jsonnet kotlin ksh libevent-dev libfl-dev libgd-dev libpng-dev libpolyml-dev livescript llvm lua5.3 m4 macaulay2 make maude maxima && chronic apt-get clean
RUN chronic apt-get -qq install -y minizinc mksh mono-devel nasm neko newlisp nickle nim nix-bin node-typescript nodejs nqp ocaml octave openjdk-25-jdk pari-gp parser3-cgi perl php-cli picolisp && chronic apt-get clean
RUN chronic apt-get -qq install -y pike8.0 polyml python3 qemu-user r-base racket rakudo ratfor rc regina-rexx rep ruby ruby-mustache rustc scala scilab-cli sed singular slsh spin && chronic apt-get clean
RUN chronic apt-get -qq install -y sqlite3 squirrel3 surgescript swi-prolog swi-prolog-nox swiftlang tcl tcsh texlive-binaries texlive-metapost valac vim wabt xa65 xonsh xsltproc yabasic yash yorick z80asm && chronic apt-get clean
RUN chronic apt-get -qq install -y zoem zsh && chronic apt-get clean
RUN chronic apt-get -qq install -y python3-pip golang-go cargo && chronic apt-get clean
RUN pip install --break-system-packages --ignore-installed coconut==3.2.0
RUN GOBIN=/usr/local/bin go install github.com/d5/tengo/v2/cmd/tengo@v2.17.0 && GOBIN=/usr/local/bin go install github.com/mattn/anko@v0.1.15
RUN cargo install --root /usr/local rhai@1.27.0 --features bin-features --bin rhai-run && cargo install --root /usr/local koto_cli@0.16.1
RUN ( chronic apt-get -qq install -y autoconf automake autoconf-archive libncurses-dev libgmp-dev libffi-dev libltdl-dev libreadline-dev zlib1g-dev gawk pkg-config unzip && chronic apt-get clean ) && \
    ( curl --retry 3 -fsSL -o /tmp/ucb.tgz https://github.com/jrincayc/ucblogo-code/archive/refs/tags/version_6.2.5.tar.gz && echo "668734c775d4f8eddb999094941572c55aaa1951b6936df2ba1f376427bedb3c  /tmp/ucb.tgz" | sha256sum -c && tar xzf /tmp/ucb.tgz -C /tmp && cd /tmp/ucblogo-code-version_6.2.5 && mkdir shim && echo '#include <termios.h>' > shim/termio.h && sed -i 's/struct termio /struct termios /; s/ioctl(0,TCGETA,(char \*)(&tty_cooked))/tcgetattr(0,\&tty_cooked)/; s/ioctl(0,TCSETA,(char \*)(&tty_cbreak))/tcsetattr(0,TCSANOW,\&tty_cbreak)/; s/ioctl(0,TCSETA,(char \*)(&tty_cooked))/tcsetattr(0,TCSANOW,\&tty_cooked)/' term.c && ! grep -q 'TCGETA\|TCSETA' term.c && chronic autoreconf -fi && chronic ./configure --disable-docs CFLAGS="-O2 -std=gnu17" CPPFLAGS="-I/tmp/ucblogo-code-version_6.2.5/shim" ac_cv_header_sgtty_h=no && chronic make -j8 && chronic make install && cd / && rm -rf /tmp/ucblogo-code-version_6.2.5 /tmp/ucb.tgz ) && \
    ( curl --retry 5 -fsSL -o /tmp/st.tgz https://mirrors.kernel.org/gnu/smalltalk/smalltalk-3.2.5.tar.gz && echo "06e574e818ec49f0555d948ae53b1453d8c1df59ef597dad911a4fd1ffba1cce  /tmp/st.tgz" | sha256sum -c && tar xzf /tmp/st.tgz -C /tmp && cd /tmp/smalltalk-3.2.5 && chronic ./configure --disable-generational-gc --without-emacs --without-tk --without-x CFLAGS="-O2 -std=gnu11 -fcommon -Wno-error -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-int-conversion" && chronic make -j8 && chronic make install && cd / && rm -rf /tmp/smalltalk-3.2.5 /tmp/st.tgz ) && \
    ( curl --retry 3 -fsSL https://julialang-s3.julialang.org/bin/linux/x64/1.13/julia-1.13.4-linux-x86_64.tar.gz | tar xz -C /opt && ln -s /opt/julia-1.13.4/bin/julia /usr/local/bin/julia ) && \
    ( curl --retry 3 -fsSL -o /tmp/dafny.zip https://github.com/dafny-lang/dafny/releases/download/v4.11.0/dafny-4.11.0-x64-ubuntu-22.04.zip && echo "a46a9ff7cdd720f7955854c78e95df13f4cfe6b80691b05f8654fe19e8267179  /tmp/dafny.zip" | sha256sum -c && unzip -q /tmp/dafny.zip -d /opt && rm /tmp/dafny.zip && printf '#!/bin/sh\nexec /opt/dafny/dafny "$@"\n' > /usr/local/bin/dafny && chmod +x /usr/local/bin/dafny ) && \
    ( cd /tmp && echo 'method Main(){print "ok";}' > w.dfy && dafny build -o w/w w.dfy && DOTNET_ROLL_FORWARD=Major dotnet w/w.dll && rm -rf /tmp/w /tmp/w.dfy )
RUN ( cd /tmp && U=http://archive.ubuntu.com/ubuntu/pool/universe && curl -fsSO $U/a/aplus-fsf/aplus-fsf_4.22.1-12_amd64.deb && curl -fsSO "$U/l/lisaac/lisaac_0.39~rc1-3.1_amd64.deb" && curl -fsSO "$U/l/lisaac/lisaac-common_0.39~rc1-3.1_all.deb" && apt-get update -qq && apt-get install -y -qq ./aplus-fsf_*.deb ./lisaac_*.deb ./lisaac-common_*.deb libcurl3t64-gnutls libexpat1 && apt-get clean && rm -f /tmp/*.deb ) && \
    ( mkdir -p /opt/falcon && cd /tmp && U=http://archive.ubuntu.com/ubuntu/pool && curl -fsSO $U/universe/f/falconpl/falconpl_0.9.6.9-git20120606-2_amd64.deb && curl -fsSO $U/universe/f/falconpl/libfalcon-engine1_0.9.6.9-git20120606-2_amd64.deb && curl -fsSO $U/main/o/openssl/libssl1.0.0_1.0.1f-1ubuntu2_amd64.deb && curl -fsSO $U/main/p/pcre3/libpcre3_8.31-2ubuntu2_amd64.deb && for d in *.deb; do dpkg -x $d /opt/falcon; done && rm -f /tmp/*.deb && printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/falcon/usr/lib:/opt/falcon/lib/x86_64-linux-gnu exec /opt/falcon/usr/bin/falcon "$@"\n' > /usr/local/bin/falcon && chmod +x /usr/local/bin/falcon ) && \
    ( mkdir -p /opt/boo && cd /tmp && U=http://archive.ubuntu.com/ubuntu/pool/universe/b/boo && curl -fsSO "$U/boo_0.9.5~git20110729.r1.202a430-2_all.deb" && curl -fsSO "$U/libboo2.0.9-cil_0.9.5~git20110729.r1.202a430-2_all.deb" && for d in *.deb; do dpkg -x $d /opt/boo; done && rm -f /tmp/*.deb && cp /opt/boo/usr/lib/cli/*/*.dll /opt/boo/usr/lib/boo/ && printf '#!/bin/sh\nexec mono /opt/boo/usr/lib/boo/booi.exe "$@"\n' > /usr/local/bin/booi && chmod +x /usr/local/bin/booi ) && \
    ( mkdir -p /opt/ecere && cd /tmp && U=http://archive.ubuntu.com/ubuntu/pool/universe/e/ecere-sdk && for p in ecere-dev libecc0 libecerecom0 libecere0; do curl -fsSO $U/${p}_0.44.15-1build3_amd64.deb; done && for d in *.deb; do dpkg -x $d /opt/ecere; done && rm -f /tmp/*.deb && for t in ecp ecc ecs; do printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/ecere/usr/lib/x86_64-linux-gnu:/opt/ecere/usr/lib/x86_64-linux-gnu/ec exec /opt/ecere/usr/bin/%s "$@"\n' $t > /usr/local/bin/$t && chmod +x /usr/local/bin/$t; done && ln -s /opt/ecere/usr/lib/x86_64-linux-gnu/libecereCOM.so /usr/local/lib/libecereCOM.so && echo /opt/ecere/usr/lib/x86_64-linux-gnu > /etc/ld.so.conf.d/ecere.conf && ldconfig ) && \
    ( mkdir -p /opt/cduce && cd /tmp && U=http://archive.ubuntu.com/ubuntu/pool && curl -fsSO $U/universe/c/cduce/cduce_0.6.0-5_amd64.deb && curl -fsSO $U/main/p/pcre3/libpcre3_8.31-2ubuntu2_amd64.deb && for d in *.deb; do dpkg -x $d /opt/cduce; done && rm -f /tmp/*.deb && printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/cduce/lib/x86_64-linux-gnu exec /opt/cduce/usr/bin/cduce "$@"\n' > /usr/local/bin/cduce && chmod +x /usr/local/bin/cduce )
RUN ( apt-get update -qq && apt-get -qq install -y git curl autoconf automake bison flex libx11-dev libncurses-dev && apt-get clean ) && \
    ( cd /opt && curl -fsSL https://www.curry-lang.org/pakcs/download/pakcs-3.9.0-amd64-Linux.tar.gz | tar -xz && make -C /opt/pakcs-3.9.0 > /tmp/pakcs-make.log 2>&1 || (tail -40 /tmp/pakcs-make.log; exit 1) )
ENV PATH=/opt/pakcs-3.9.0/bin:$PATH
RUN ( git clone -q --depth 1 -b RELEASE_8_1_0 https://github.com/parrot/parrot.git /opt/parrot-src && cd /opt/parrot-src && perl Configure.pl --prefix=/opt/parrot --optimize && (make -j"$(nproc)" || make) && make install && ln -s /opt/parrot/bin/parrot /usr/local/bin/parrot ) && \
    ( git clone -q --depth 1 -b Seed7_release_2026-07-11 https://github.com/ThomasMertes/seed7.git /opt/seed7 && cd /opt/seed7/src && make -f mk_linux.mak depend && make -f mk_linux.mak -j"$(nproc)" && make -f mk_linux.mak install ) && \
    ( apt-get -qq install -y gperf gcc-14 && apt-get clean && git clone -q --depth 1 -b v1.4.0 https://github.com/tinyos/nesc.git /opt/nesc && cd /opt/nesc && ./Bootstrap && ./configure CFLAGS='-O2 -std=gnu17 -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration' && make && make install )
RUN ( chronic apt-get -qq install -y unzip ant && chronic apt-get clean ) && \
    ( curl -fsSL -o /tmp/fan.zip https://github.com/fantom-lang/fantom/releases/download/v1.0.84/fantom-1.0.84.zip && unzip -q /tmp/fan.zip -d /opt && rm /tmp/fan.zip && chmod +x /opt/fantom-1.0.84/bin/* && printf '#!/bin/sh\nexec /opt/fantom-1.0.84/bin/fan "$@"\n' > /usr/local/bin/fan && chmod +x /usr/local/bin/fan ) && \
    ( curl -fsSL -o /tmp/golo.zip https://github.com/eclipse-archived/golo-lang/releases/download/release/3.4.0/golo-3.4.0.zip && unzip -q /tmp/golo.zip -d /opt && rm /tmp/golo.zip && chmod +x /opt/golo-3.4.0/bin/* && printf '#!/bin/sh\nexec /opt/golo-3.4.0/bin/golo "$@"\n' > /usr/local/bin/golo && chmod +x /usr/local/bin/golo ) && \
    ( curl -fsSL -o /tmp/yeti.tgz https://github.com/mth/yeti/archive/45f939babffacf73f6c3980867f6ca94e14b093f.tar.gz && tar xzf /tmp/yeti.tgz -C /opt && mv /opt/yeti-45f939babffacf73f6c3980867f6ca94e14b093f /opt/yeti && rm /tmp/yeti.tgz && cd /opt/yeti && ant -q jar && printf '#!/bin/sh\nexec java -jar /opt/yeti/yeti.jar "$@"\n' > /usr/local/bin/yeti && chmod +x /usr/local/bin/yeti ) && \
    ( curl -fsSL -o /tmp/bal.deb https://github.com/ballerina-platform/ballerina-distribution/releases/download/v2201.14.1/ballerina-2201.14.1-swan-lake-linux-x64.deb && dpkg -i /tmp/bal.deb && rm /tmp/bal.deb && bal pull ballerina/io:1.8.3 ) && \
    ( curl -fsSL -o /tmp/gosu.zip https://repo1.maven.org/maven2/org/gosu-lang/gosu/gosu/1.18.14/gosu-1.18.14-full.zip && unzip -q /tmp/gosu.zip -d /opt && rm /tmp/gosu.zip && chmod +x /opt/gosu-1.18.14/bin/* && printf '#!/bin/sh\nexec /opt/gosu-1.18.14/bin/gosu "$@"\n' > /usr/local/bin/gosu && chmod +x /usr/local/bin/gosu ) && \
    ( curl -fsSL -o /usr/local/lib/frege.jar https://github.com/Frege/frege/releases/download/3.25alpha/frege3.25.84.jar && printf '#!/bin/sh\nexec java -Xss32m -jar /usr/local/lib/frege.jar "$@"\n' > /usr/local/bin/frege && chmod +x /usr/local/bin/frege )
RUN ( chronic apt-get -qq install -y npm && chronic apt-get clean ) && \
    ( npm install --prefix /opt/b05 --no-fund --no-audit rescript@12.3.1 purescript@0.15.17 elm@0.19.1-6 imba@2.0.0-alpha.253 wisp@0.13.0 commander@7.2.0 pyret-npm@0.1.29 && for b in bsc purs elm imba wisp; do ln -s /opt/b05/node_modules/.bin/$b /usr/local/bin/$b; done ) && \
    ( for p in prelude:v6.0.2 effect:v4.0.0 console:v6.1.0; do mkdir -p /opt/purs/lib/${p%%:*} && curl -fsSL https://github.com/purescript/purescript-${p%%:*}/archive/refs/tags/${p#*:}.tar.gz | tar -xz --strip-components=1 -C /opt/purs/lib/${p%%:*} || exit 1; done && printf 'import {main} from "./out/QR/index.js"; main();\n' > /opt/purs/run.mjs && purs compile -o /opt/purs/out '/opt/purs/lib/*/src/**/*.purs' ) && \
    ( mkdir -p /opt/elm/src && cd /opt/elm && printf '{"type":"application","source-directories":["src"],"elm-version":"0.19.1","dependencies":{"direct":{"elm/core":"1.0.5","elm/json":"1.1.3"},"indirect":{}},"test-dependencies":{"direct":{},"indirect":{}}}\n' > elm.json && printf 'port module QR exposing (main)\nport o : String -> Cmd m\nmain : Program () () ()\nmain = Platform.worker {init = always ((), o "ok"), update = always (always ((), Cmd.none)), subscriptions = always Sub.none}\n' > src/QR.elm && elm make src/QR.elm --output=/dev/null ) && \
    ( printf '#!/bin/sh\n# pyretc IN.arr OUT.jarr: compile one Pyret program to a standalone node file\n# (the same compiler call the pyret CLI makes, without its background compile server)\nI=$(realpath "$1"); O=$(realpath -m "$2")\ncd %s && exec node --max-old-space-size=8192 --stack-size=8192 build/phaseA/pyret.jarr --build-runnable "$I" --outfile "$O" --builtin-js-dir src/js/trove/ --builtin-arr-dir src/arr/trove --require-config src/scripts/standalone-configA.json --standalone-file src/js/base/handalone.js --compiled-dir /opt/pyret-compiled -no-check-mode < /dev/null\n' /opt/b05/node_modules/pyret-npm/pyret-lang > /usr/local/bin/pyretc && chmod +x /usr/local/bin/pyretc && printf 'print("ok")' > /tmp/w.arr && pyretc /tmp/w.arr /tmp/w.jarr && NODE_PATH=/opt/b05/node_modules node /tmp/w.jarr )
ENV CARGO_HTTP_MULTIPLEXING=false CARGO_NET_RETRY=10
RUN ( mkdir -p /opt/pwsh && curl -fsSL https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-7.4.6-linux-x64.tar.gz | tar -xz -C /opt/pwsh && chmod +x /opt/pwsh/pwsh && ln -sf /opt/pwsh/pwsh /usr/local/bin/pwsh ) && \
    ( mkdir -p /opt/nu && curl -fsSL https://github.com/nushell/nushell/releases/download/0.101.0/nu-0.101.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz -C /opt/nu --strip-components=1 && ln -sf /opt/nu/nu /usr/local/bin/nu ) && \
    ( cargo install --git https://github.com/redox-os/ion.git --rev e9b3ca48b7ab6444498d5c3aa902d471ce29f759 ion-shell --root /usr/local ) && \
    ( mkdir -p /tmp/oils && curl -fsSL https://www.oilshell.org/download/oils-for-unix-0.24.0.tar.gz | tar -xz -C /tmp/oils --strip-components=1 && (cd /tmp/oils && ./configure && _build/oils.sh && ./install) && rm -rf /tmp/oils ) && \
    ( git clone --branch v7.4.2002 --depth 1 https://github.com/lmorg/murex.git /tmp/murex && (cd /tmp/murex && go build -o /usr/local/bin/murex .) && rm -rf /tmp/murex ) && \
    ( cargo install hush --version 0.1.4 --root /usr/local ) && \
    ( mkdir -p /tmp/es && curl -fsSL https://github.com/wryun/es-shell/releases/download/v0.9.2/es-0.9.2.tar.gz | tar -xz -C /tmp/es && (cd /tmp/es && ./configure CFLAGS="-O2 -std=gnu89" && make -j4 && cp es /usr/local/bin/es) && rm -rf /tmp/es )
RUN ( curl -fsSL https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ -C /opt && ln -sf /opt/zig-linux-x86_64-0.13.0/zig /usr/local/bin/zig ) && \
    ( mkdir -p /usr/local/lib/odin && curl -fsSL https://github.com/odin-lang/Odin/releases/download/dev-2026-10/odin-linux-amd64-dev-2026-10.tar.gz | tar -xz -C /usr/local/lib/odin --strip-components=1 && ln -sf /usr/local/lib/odin/odin /usr/local/bin/odin && ln -sf /usr/bin/gcc /usr/local/bin/clang ) && \
    ( curl -fsSL https://github.com/vlang/v/releases/download/0.4.12/v_linux.zip -o /tmp/v_linux.zip && unzip -q /tmp/v_linux.zip -d /opt && ln -sf /opt/v/v /usr/local/bin/v && rm /tmp/v_linux.zip ) && \
    ( curl -fsSL https://github.com/c3lang/c3c/releases/download/v0.7.0/c3-linux.tar.gz | tar -xz -C /opt && ln -sf /opt/c3/c3c /usr/local/bin/c3c && ln -sf /usr/lib/x86_64-linux-gnu/libxml2.so.16 /usr/lib/x86_64-linux-gnu/libxml2.so.2 ) && \
    ( mkdir -p /tmp/nelua && curl -fsSL https://github.com/edubart/nelua-lang/archive/9840cc8e.tar.gz | tar -xz -C /tmp/nelua --strip-components=1 && make -C /tmp/nelua install PREFIX=/usr/local && rm -rf /tmp/nelua )
RUN ( curl -fsSL -o /tmp/gleam.tgz https://github.com/gleam-lang/gleam/releases/download/v1.19.2/gleam-v1.19.2-x86_64-unknown-linux-musl.tar.gz && \
    echo "2ba2afb66ca9f6dcc01a4a6e9169b6942963bad6483bec9571ddc078cfe6f41f  /tmp/gleam.tgz" | sha256sum -c && \
    tar -xzf /tmp/gleam.tgz -C /usr/local/bin gleam && rm /tmp/gleam.tgz && \
    gleam --version; erl -noshell -eval 'io:format("~s~n",[erlang:system_info(otp_release)]),halt().' ) && \
    ( curl -fsSL -o /tmp/roc.tgz https://github.com/roc-lang/roc/releases/download/alpha4-rolling/roc-linux_x86_64-alpha4-rolling.tar.gz && \
    echo "96e8be05e6f7176433ada74532ff36a62b8dc44c5247a82cdf919f2dadc5178b  /tmp/roc.tgz" | sha256sum -c && \
    mkdir -p /opt/roc && tar -xzf /tmp/roc.tgz -C /opt/roc --strip-components=1 && rm /tmp/roc.tgz && \
    ln -sf /opt/roc/roc /usr/local/bin/roc && \
    roc version && \
    mkdir -p /tmp/rocwarm && printf 'app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }\nimport pf.Stdout\nmain! = |_args| Stdout.write!("warm")\n' > /tmp/rocwarm/w.roc && \
    (cd /tmp/rocwarm && roc build --output w w.roc && ./w) && rm -rf /tmp/rocwarm ) && \
    ( apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq llvm-18-dev libpolly-18-dev libzstd-dev zlib1g-dev && \
    curl -fsSL -o /tmp/inko.tgz https://github.com/inko-lang/inko/archive/refs/tags/v0.21.1.tar.gz && \
    echo "6d73f93a7331ef9111d7bf8a3665059ccda25a33a6f2bd723a7aa2ab83b22259  /tmp/inko.tgz" | sha256sum -c && \
    tar -xzf /tmp/inko.tgz -C /tmp && rm /tmp/inko.tgz && \
    cd /tmp/inko-0.21.1 && LLVM_SYS_181_PREFIX=/usr/lib/llvm-18 make build PREFIX=/usr/local && make install PREFIX=/usr/local && \
    cd / && rm -rf /tmp/inko-0.21.1 && \
    inko --version ) && \
    ( curl -fsSL -o /tmp/koka.tgz https://github.com/koka-lang/koka/releases/download/v3.2.9/koka-v3.2.9-linux-x64.tar.gz && \
    echo "310459831a7c6fa6a0cd8e0e02d6b5b3b36441d5e7ce24168bda016cd2e95eee  /tmp/koka.tgz" | sha256sum -c && \
    mkdir -p /opt/koka && tar -xzf /tmp/koka.tgz -C /opt/koka && rm /tmp/koka.tgz && \
    ln -sf /opt/koka/bin/koka /usr/local/bin/koka && \
    koka --version ) && \
    ( apt-get update -qq && \
    curl -fsSL -o /tmp/chapel.deb https://github.com/chapel-lang/chapel/releases/download/2.10.0/chapel-2.10.0-1.ubuntu26.amd64.deb && \
    echo "9af4153bea3cd225f5f3e90ddc215e15fcf1c7fa8ce2246108415b6da1c27d11  /tmp/chapel.deb" | sha256sum -c && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq /tmp/chapel.deb && rm /tmp/chapel.deb && \
    chpl --version ) && \
    ( curl -fsSL -o /tmp/ponyc.tgz https://github.com/ponylang/ponyc/releases/download/0.78.2/ponyc-x86-64-unknown-linux-ubuntu26.04.tar.gz && \
    echo "69f9dae95da5eb4a1abe411f011a18e819f677cd33f10bbd8e44f36fd46f5103  /tmp/ponyc.tgz" | sha256sum -c && \
    mkdir -p /opt/ponyc && tar -xzf /tmp/ponyc.tgz -C /opt/ponyc --strip-components=1 && rm /tmp/ponyc.tgz && \
    ln -sf /opt/ponyc/bin/ponyc /usr/local/bin/ponyc && \
    ponyc --version )
RUN ( cd /opt && curl -fsSL -o lean.zip https://github.com/leanprover/lean4/releases/download/v4.35.0/lean-4.35.0-linux.zip && unzip -q lean.zip && rm lean.zip && ln -s /opt/lean-4.35.0-linux/bin/lean /usr/local/bin/lean && lean --version ) && \
    ( apt-get update -qq && apt-get install -y -qq chezscheme libgmp-dev > /dev/null && git clone -q --depth 1 -b v0.8.0 https://github.com/idris-lang/Idris2 /tmp/idris2src && cd /tmp/idris2src && make bootstrap SCHEME=chezscheme PREFIX=/opt/idris2 > /tmp/idris2-build.log 2>&1 && make install PREFIX=/opt/idris2 >> /tmp/idris2-build.log 2>&1 && ln -s /opt/idris2/bin/idris2 /usr/local/bin/idris2 && cd / && rm -rf /tmp/idris2src && idris2 --version ) && \
    ( cd /opt && curl -fsSL https://github.com/FStarLang/FStar/releases/download/v2026.10.25/fstar-v2026.10.25-Linux-x86_64.tar.gz | tar -xz && ln -s /opt/fstar/bin/fstar.exe /usr/local/bin/fstar.exe && fstar.exe --version )
RUN ( cd /opt && curl -fsSL -o dart.zip https://storage.googleapis.com/dart-archive/channels/stable/release/3.14.0/sdk/dartsdk-linux-x64-release.zip && unzip -q dart.zip && rm dart.zip && ln -s /opt/dart-sdk/bin/dart /usr/local/bin/dart && dart --version ) && \
    ( cd /opt && curl -fsSL https://picat-lang.org/download/picat39_12_linux64.tar.gz | tar -xz && ln -s /opt/Picat/picat /usr/local/bin/picat && picat --version ) && \
    ( echo "deb [trusted=yes] https://dl.mercurylang.org/deb/ trixie main" > /etc/apt/sources.list.d/mercury.list && apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mercury-recommended=22.01.8-1~trixie > /dev/null && rm /etc/apt/sources.list.d/mercury.list && apt-get clean && mmc --version | head -1 )
ENV LOGTALKHOME=/usr/share/logtalk LOGTALKUSER=/root/logtalk
RUN ( curl -fsSL -o /tmp/lgt.deb https://logtalk.org/files/logtalk_3.102.0-1_all.deb && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq /tmp/lgt.deb > /dev/null && rm /tmp/lgt.deb && logtalk_user_setup > /dev/null && swilgt -q -g halt < /dev/null )
RUN ( cargo install uiua --version 0.19.1 --locked --root /opt/uiua > /tmp/uiua-build.log 2>&1 && ln -s /opt/uiua/bin/uiua /usr/local/bin/uiua && uiua --version ) && \
    ( apt-get update -qq && apt-get install -y -qq clang > /dev/null && git clone -q --depth 1 -b v0.9.0 https://github.com/dzaima/CBQN /opt/cbqn && make -C /opt/cbqn CC=/usr/bin/clang > /tmp/cbqn-build.log 2>&1 && ln -s /opt/cbqn/BQN /usr/local/bin/bqn && bqn -p 1+1 ) && \
    ( curl -fsSL -o /tmp/j97.tgz https://www.jsoftware.com/download/j9.7/install/j9.7_linux64.tar.gz && echo "1c0cf450b45f563d7408a6c93563006782da8b422e0769781eb8731c465ffd06  /tmp/j97.tgz" | sha256sum -c && tar -xzf /tmp/j97.tgz -C /opt && rm /tmp/j97.tgz && ln -s /opt/j9.7/bin/jconsole /usr/local/bin/ijconsole )
COPY vendor/ngnk-b9eeb91e.tar.gz /tmp/ngnk.tgz
RUN ( apt-get update -qq && apt-get install -y -qq clang > /dev/null && echo "3e0072b2a61e1247b58f424c1b818f94618aea87f5dc4bdbe94cbae766e9f7ac  /tmp/ngnk.tgz" | sha256sum -c && ( (git clone -q https://codeberg.org/ngn/k /opt/ngnk && cd /opt/ngnk && git checkout -q b9eeb91e0343ef6029f59d55dd98f82667b9bd59) || (rm -rf /opt/ngnk && mkdir -p /opt/ngnk && tar -xzf /tmp/ngnk.tgz -C /opt/ngnk) ) && rm -f /tmp/ngnk.tgz && make -C /opt/ngnk a N=k R=k O=-O3 L='-lm -ldl' CC=/usr/bin/clang > /tmp/ngnk-build.log 2>&1 && ln -s /opt/ngnk/k /usr/local/bin/ngnk ) && \
    ( curl -fsSL -o /tmp/klong.tgz https://t3x.org/klong/klong20221212.tgz && echo "5e1a4877228a3c643a99dbfd2d73e60bc3fa856e2615ac2fe78c80370e7f96b4  /tmp/klong.tgz" | sha256sum -c && mkdir -p /opt/klong && tar -xzf /tmp/klong.tgz -C /opt/klong --strip-components=1 && make -C /opt/klong > /tmp/klong-build.log 2>&1 && ln -s /opt/klong/kg /usr/local/bin/kg ) && \
    ( git clone -q https://github.com/niallang/Nial_Development /opt/nial && cd /opt/nial && git checkout -q cdd6e8158814e96d063b921715de91e038191ead && CMAKE_POLICY_VERSION_MINIMUM=3.5 CFLAGS=-std=gnu17 make nialcore > /tmp/nial-build.log 2>&1 && ln -s /opt/nial/nialcore /usr/local/bin/nial )
RUN ( curl -fsSL --retry 6 --retry-delay 10 --retry-all-errors -o /tmp/reduce.deb "https://sourceforge.net/projects/reduce-algebra/files/snapshot_2026-03-08/linux64/reduce-complete_2026-03-08_amd64.deb/download" && echo "fcf171b0f7509aa187f185966195a0761c11a00d862db4981f65d4ffd9388cf4  /tmp/reduce.deb" | sha256sum -c && apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq /tmp/reduce.deb > /dev/null && rm /tmp/reduce.deb && which redcsl )
COPY vendor/frink/frink.jar /opt/frink/frink.jar
RUN ( echo "ca267b62466eb46ac1b323b279c83634fa42b631d22f1bf261cc2609f1b1ccb0  /opt/frink/frink.jar" | sha256sum -c ) && \
    ( pip install --break-system-packages -q mathics3==10.0.1 && mathics --version | head -1 ) && \
    ( cargo install numbat-cli --version 1.24.0 --locked --root /opt/numbat > /tmp/numbat-build.log 2>&1 && ln -s /opt/numbat/bin/numbat /usr/local/bin/numbat && numbat --version )
RUN ( cd /opt && git clone -q --depth 1 -b v1.43.0 https://github.com/janet-lang/janet && make -C janet -j4 > /tmp/janet.log 2>&1 && ln -s /opt/janet/build/janet /usr/local/bin/janet && echo '(prin "janet ok")' > /tmp/t.janet && janet /tmp/t.janet ) && \
    ( cd /opt && git clone -q --depth 1 -b v1.1.0 https://github.com/berry-lang/berry && make -C berry -j4 > /tmp/berry.log 2>&1 && ln -s /opt/berry/berry /usr/local/bin/berry && echo 'print("berry ok")' > /tmp/t.be && berry /tmp/t.be ) && \
    ( cd /opt && git clone -q --depth 1 -b 0.9.9 https://github.com/marcobambini/gravity && make -C gravity -j4 > /tmp/gravity.log 2>&1 && ln -s /opt/gravity/gravity /usr/local/bin/gravity && echo 'func main(){System.print("gravity ok")}' > /tmp/t.gravity && gravity -q /tmp/t.gravity ) && \
    ( cd /opt && git clone -q --depth 1 -b v1.5.7 https://github.com/vtereshkov/umka-lang && make -C umka-lang -j4 > /tmp/umka.log 2>&1 && ln -s /opt/umka-lang/build/umka /usr/local/bin/umka && echo 'fn main(){printf("umka ok")}' > /tmp/t.um && umka /tmp/t.um ) && \
    ( cd /opt && git clone -q --depth 1 -b 0.4.0 https://github.com/wren-lang/wren-cli && sed -i 's/static void write(/static void cliWrite(/; s/= write;/= cliWrite;/' wren-cli/src/cli/vm.c && make -C wren-cli/projects/make -j4 > /tmp/wren.log 2>&1 && ln -s /opt/wren-cli/bin/wren_cli /usr/local/bin/wren_cli && echo 'System.print("wren ok")' > /tmp/t.wren && wren_cli /tmp/t.wren ) && \
    ( (command -v cmake > /dev/null || (apt-get update -qq && apt-get -qq install -y cmake && apt-get clean)) && cd /opt && git clone -q --depth 1 -b 2019.05.22-alpha --recurse-submodules --shallow-submodules https://github.com/IoLanguage/io && sed -i 's|^# include <sys/sysctl.h>|/* sys/sysctl.h dropped */|' io/libs/iovm/source/IoSystem.c && mkdir io/build && cd io/build && (cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 '-DCMAKE_C_FLAGS=-std=gnu11 -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion' > /tmp/io.log 2>&1 && make -j4 io_static >> /tmp/io.log 2>&1 || (grep -n -i -m20 -B2 'error' /tmp/io.log; tail -15 /tmp/io.log; exit 1)) && cp _build/binaries/io_static /usr/local/bin/io && echo '"io ok" println' > /tmp/t.io && io /tmp/t.io )
RUN ( (command -v luarocks > /dev/null || (apt-get update -qq && apt-get -qq install -y luarocks lua5.4 liblua5.4-dev && apt-get clean)) && luarocks --lua-version=5.4 install moonscript 0.5.0-1 > /tmp/moon.log 2>&1 && luarocks --lua-version=5.4 install tl 0.24.8-1 > /tmp/tl.log 2>&1 && echo 'io.write [==[moon ok]==]' > /tmp/t.moon && moon /tmp/t.moon && echo 'io.write([==[ tl ok]==])' > /tmp/t.tl && tl run /tmp/t.tl ) && \
    ( cd /opt && git clone -q --depth 1 -b v0.34.3 https://github.com/IppClub/YueScript && make -C YueScript release -j4 > /tmp/yue.log 2>&1 && ln -s /opt/YueScript/bin/release/yue /usr/local/bin/yue && echo 'io.write [==[yue ok]==]' > /tmp/t.yue && yue -e /tmp/t.yue ) && \
    ( cd /opt && curl -fsSL --retry 6 --retry-delay 10 --retry-all-errors https://www.kylheku.com/cgit/txr/snapshot/txr-302.tar.bz2 | tar -xj && cd txr-302 && ./configure > /tmp/txr.log 2>&1 && make -j4 >> /tmp/txr.log 2>&1 && make install >> /tmp/txr.log 2>&1 && echo '(put-string "txr ok")' > /tmp/t.tl && txr /tmp/t.tl ) && \
    ( mkdir -p /opt/arturo && cd /opt/arturo && curl -fsSL --retry 6 --retry-delay 10 --retry-all-errors https://github.com/arturo-lang/arturo/releases/download/v0.10.0/arturo-0.10.0-linux-amd64-mini.zip -o a.zip && unzip -q a.zip && rm a.zip && ln -s /opt/arturo/arturo /usr/local/bin/arturo && echo 'prints {:arturo ok:}' > /tmp/t.art && arturo /tmp/t.art ) && \
    ( cd /opt && git clone -q --depth 1 --filter=blob:none --sparse -b v1.27 https://github.com/ring-lang/ring && cd ring && git sparse-checkout set language > /dev/null && cd language/src && gcc -O2 $(ls *.c | grep -v ringw) -I ../include -lm -ldl -o /usr/local/bin/ring > /tmp/ring.log 2>&1 && echo 'see "ring ok"' > /tmp/t.ring && ring /tmp/t.ring )
RUN ( apt-get update && apt-get install -y --no-install-recommends \
    gcc libc6-dev libgc-dev m4 make git curl ca-certificates \
    && (curl --retry 5 --retry-all-errors -fsSL https://ftp.regressive.org/snobol/snobol4-2.3.3.tar.gz -o /tmp/sno.tgz \
        || curl --retry 5 --retry-all-errors -fsSL https://ftp.regressive.org/snobol/snobol4-2.3.2.tar.gz -o /tmp/sno.tgz \
        || curl --retry 5 --retry-all-errors -fsSL https://ftp.regressive.org/snobol/snobol4-2.3.1.tar.gz -o /tmp/sno.tgz \
        || (SNO_TGZ=$(curl --retry 5 -fsSL https://ftp.regressive.org/snobol/ | grep -oE 'snobol4-2\.[0-9.]+\.tar\.gz' | sort -V | tail -1) && curl --retry 5 -fsSL "https://ftp.regressive.org/snobol/$SNO_TGZ" -o /tmp/sno.tgz)) \
    && mkdir -p /tmp/sno && tar -xzf /tmp/sno.tgz -C /tmp/sno --strip-components=1 \
    && cd /tmp/sno && CC="gcc -std=gnu17 -fcommon -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-type" ./configure --prefix=/usr/local \
    && make && make install && cd / && rm -rf /tmp/sno /tmp/sno.tgz \
    && (curl --retry 5 --retry-all-errors -fsSL https://mirrors.kernel.org/gnu/cim/cim-5.1.tar.gz -o /tmp/cim.tar.gz \
        || curl --retry 5 -fsSL http://ftpmirror.gnu.org/cim/cim-5.1.tar.gz -o /tmp/cim.tar.gz \
        || curl --retry 5 -fsSL https://ftp.gnu.org/gnu/cim/cim-5.1.tar.gz -o /tmp/cim.tar.gz) \
    && mkdir -p /tmp/cim && tar -xzf /tmp/cim.tar.gz -C /tmp/cim --strip-components=1 \
    && cd /tmp/cim && sed -i 's|\.\./\.\./lib/cim\.h|cim.h|g' lib/*.c \
    && ./configure --prefix=/usr/local CC="gcc -std=gnu89" CFLAGS="-O2 -fcommon -std=gnu89 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-type" \
    && make && make install && ldconfig \
    && cd / && rm -rf /tmp/cim /tmp/cim.tar.gz \
    && (curl --retry 5 --retry-all-errors -fsSL https://miasap.se/obnc/downloads/obnc_0.17.2.tar.gz -o /tmp/obnc.tgz \
        || curl --retry 5 -fsSL http://miasap.se/obnc/downloads/obnc_0.17.2.tar.gz -o /tmp/obnc.tgz) \
    && mkdir -p /tmp/obnc && tar -xzf /tmp/obnc.tgz -C /tmp/obnc --strip-components=1 \
    && cd /tmp/obnc && sed -i 's/strlen("\\0")/1/g' src/*.c \
    && CC="gcc -std=gnu17 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0" CFLAGS="-O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -Wno-error" ./build --prefix=/usr/local && ./install && ldconfig \
    && cd / && rm -rf /tmp/obnc /tmp/obnc.tgz \
    && curl --retry 5 --retry-all-errors -fsSL https://github.com/OpenEuphoria/euphoria/releases/download/4.1.0/euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz -o /tmp/euphoria.tar.gz \
    && tar -xzf /tmp/euphoria.tar.gz -C /opt \
    && ln -sf /opt/euphoria-4.1.0-Linux-x64/bin/eui /usr/local/bin/eui \
    && ln -sf /opt/euphoria-4.1.0-Linux-x64/bin/euc /usr/local/bin/euc \
    && rm -f /tmp/euphoria.tar.gz \
    && (curl --retry 5 --retry-all-errors -fsSL https://mirrors.kernel.org/gnu/marst/marst-2.8.tar.gz -o /tmp/marst.tgz \
        || curl --retry 5 -fsSL http://ftpmirror.gnu.org/marst/marst-2.8.tar.gz -o /tmp/marst.tgz \
        || curl --retry 5 -fsSL https://ftp.gnu.org/gnu/marst/marst-2.8.tar.gz -o /tmp/marst.tgz) \
    && mkdir -p /tmp/marst && tar -xzf /tmp/marst.tgz -C /tmp/marst --strip-components=1 \
    && cd /tmp/marst && sed -i 's/append(code, t_image);/append(code, "%s", t_image);/g' marst.c \
    && CC="gcc -std=gnu17" ./configure --prefix=/usr/local && make && make install && ldconfig \
    && cd / && rm -rf /tmp/marst /tmp/marst.tgz \
    && curl --retry 5 --retry-all-errors -fsSL https://www.cl.cam.ac.uk/users/mr10/BCPL/bcpl.tgz -o /tmp/bcpl.tgz \
    && tar -xzf /tmp/bcpl.tgz -C /opt \
    && cd /opt/BCPL/cintcode \
    && mkdir -p obj obj64 bin && touch cin/syscin/* cin64/syscin/* \
    && sed -i 's/gcc /gcc -std=gnu17 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-type /g' Makefile \
    && export BCPLROOT=/opt/BCPL/cintcode BCPLPATH=/opt/BCPL/cintcode/cin64 BCPLHDRS=/opt/BCPL/cintcode/g BCPLSCRIPTS=/opt/BCPL/cintcode/s PATH="/opt/BCPL/cintcode/bin:$PATH" \
    && make clean64 && make sys64 \
    && ln -sf /opt/BCPL/cintcode/bin/cintsys64 /usr/local/bin/cintsys64 \
    && rm -f /tmp/bcpl.tgz )
RUN ( apt-get update && apt-get install -y --no-install-recommends \
    erlang-nox erlang-dev default-jdk-headless python3 gcc libc6-dev libgc-dev make git curl ca-certificates \
    && curl --retry 5 --retry-all-errors -fsSL https://downloads.factorcode.org/releases/0.100/factor-linux-x86-64-0.100.tar.gz -o /tmp/factor.tar.gz \
    && tar -xzf /tmp/factor.tar.gz -C /opt \
    && ln -sf /opt/factor/factor /usr/local/bin/factor-vm \
    && rm -f /tmp/factor.tar.gz \
    && git clone --depth 1 https://github.com/Wodan58/joy0.git /tmp/joy \
    && cd /tmp/joy \
    && ([ -f globals.h ] && sed -i 's/INPLINEMAX.*/INPLINEMAX 65535/; s/MEMORYMAX.*/MEMORYMAX 2000000/' globals.h || true) \
    && ([ -f main.c ] && sed -i '/JOY  -  compiled/d; /totaltime = clock/i exit(EXIT_SUCCESS);' main.c || true) \
    && gcc -O2 -std=gnu89 -fcommon -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-type -Wno-int-conversion *.c -lm -o /usr/local/bin/joy \
    && cd / && rm -rf /tmp/joy \
    && git clone --branch 2.1.4 --depth 1 https://github.com/lfe/lfe.git /opt/lfe \
    && make -C /opt/lfe compile \
    && ln -sf /opt/lfe/bin/lfe /usr/local/bin/lfe \
    && ln -sf /opt/lfe/bin/lfec /usr/local/bin/lfec \
    && ln -sf /opt/lfe/bin/lfescript /usr/local/bin/lfescript \
    && curl --retry 5 --retry-all-errors -fsSL https://lhartikk.github.io/ArnoldC.jar -o /opt/ArnoldC.jar \
    && git clone --depth 1 https://github.com/isaacg1/pyth.git /opt/pyth )
RUN ( apt-get update && apt-get install -y --no-install-recommends \
    texlive-base texlive-binaries texlive-metapost inform6-compiler inform6-library frotz \
    gcc g++ libc6-dev make cmake libncurses-dev libcurl4-openssl-dev unzip ca-certificates git curl \
    && git clone --depth 1 https://gitlab.com/DavidGriffith/frotz.git /tmp/frotz \
    && make -C /tmp/frotz dumb \
    && install -m 755 /tmp/frotz/dfrotz /usr/local/bin/dfrotz \
    && rm -rf /tmp/frotz \
    && git clone --depth 1 https://github.com/william8000/lout.git /tmp/lout \
    && mkdir -p /usr/local/bin /usr/local/lib/lout /usr/local/share/doc/lout /usr/local/share/man/man1 \
    && make -C /tmp/lout CC="gcc -std=gnu17 -O2 -Wno-implicit-function-declaration -Wno-return-type" PREFIX=/usr/local BINDIR=/usr/local/bin LOUTLIBDIR=/usr/local/lib/lout LOUTDOCDIR=/usr/local/share/doc/lout MANDIR=/usr/local/share/man/man1 all install \
    && (/usr/local/bin/lout -x -s /usr/local/lib/lout/include/init || true) \
    && rm -rf /tmp/lout \
    && (apt-get install -y --no-install-recommends frobtads || ( \
        git clone --recurse-submodules --branch v2.0 --depth 1 https://github.com/realnc/frobtads.git /tmp/frobtads \
        && cmake -S /tmp/frobtads -B /tmp/frobtads/build -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
        && cmake --build /tmp/frobtads/build -j$(nproc) \
        && cmake --install /tmp/frobtads/build \
        && rm -rf /tmp/frobtads \
    )) \
    && (curl --retry 5 -fsSL https://github.com/inkle/ink/releases/download/v1.2.1/inklecate_linux.zip -o /tmp/inklecate.zip \
        || curl --retry 5 -fsSL https://github.com/inkle/ink/releases/latest/download/inklecate_linux.zip -o /tmp/inklecate.zip) \
    && mkdir -p /opt/inklecate \
    && unzip -q /tmp/inklecate.zip -d /opt/inklecate \
    && chmod +x /opt/inklecate/inklecate \
    && ln -sf /opt/inklecate/inklecate /usr/local/bin/inklecate \
    && rm -f /tmp/inklecate.zip )
RUN ( (git clone -q https://github.com/theartofcomputerprogramming/mmixware.git /opt/mmixware || git clone -q https://gitlab.lrz.de/mmix/mmixware.git /opt/mmixware) && make -C /opt/mmixware CFLAGS="-O2 -std=gnu89 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-type" mmixal mmix && install -m 755 /opt/mmixware/mmixal /opt/mmixware/mmix /usr/local/bin/ && rm -rf /opt/mmixware && printf ' LOC #100\nMain GETA $255,S\n TRAP 0,Fputs,StdOut\n TRAP 0,Halt,0\nS BYTE "ok",0\n' > /tmp/t.mms && mmixal -o /tmp/t.mmo /tmp/t.mms && test "$(mmix /tmp/t.mmo)" = "ok" && rm -f /tmp/t.mms /tmp/t.mmo ) && \
    ( mkdir -p /opt/uxn && (curl --retry 5 -fsSL https://github.com/kivutar/uxn/archive/9e483ae8b129029152a2b3e1ebb6762078378e65.tar.gz | tar -xz -C /opt/uxn --strip-components=1 || git clone -q --depth 1 https://github.com/kivutar/uxn.git /opt/uxn) && cd /opt/uxn && gcc -O2 -Wno-error src/uxnasm.c -o /usr/local/bin/uxnasm && (gcc -O2 -Wno-error src/uxn.c src/uxncli.c -o /usr/local/bin/uxncli 2>/dev/null || gcc -O2 -Wno-error src/uxncli.c -o /usr/local/bin/uxncli 2>/dev/null || gcc -O2 -Wno-error src/uxn.c src/devices/*.c src/uxncli.c -o /usr/local/bin/uxncli) && cd / && rm -rf /opt/uxn && printf '|0100 #6f #18 DEO #6b #18 DEO #800f DEO BRK\n' > /tmp/t.tal && uxnasm /tmp/t.tal /tmp/t.rom >/dev/null && test "$(uxncli /tmp/t.rom)" = "ok" && rm -f /tmp/t.tal /tmp/t.rom )
RUN ( mkdir -p /opt/hexagony && curl --retry 5 -fsSL https://github.com/m-ender/hexagony/archive/b674f59a0c9e10c1867bd9cf34f676ba89f0fc1c.tar.gz | tar -xz -C /opt/hexagony --strip-components=1 && printf 'o;k;@' > /tmp/t.hxg && test "$(ruby /opt/hexagony/interpreter.rb /tmp/t.hxg)" = "ok" && rm -f /tmp/t.hxg )
RUN ( mkdir -p /opt/taxi && curl --retry 5 -fsSL https://github.com/BigZaphod/Taxi/archive/61383585546668901e77287334ab454426e6f148.tar.gz | tar -xz -C /opt/taxi --strip-components=1 && g++ -O2 -std=gnu++14 -DNO_GREETINGS -include cstring -include cstdlib -include cstdint -include ctime -o /usr/local/bin/taxi /opt/taxi/source/taxi.cpp && rm -rf /opt/taxi && printf '%s\n' '"ok" is waiting at the Writer'\''s Depot.' 'Go to Writer'\''s Depot: west 1st left, 2nd right, 1st left, 2nd left.' 'Pickup a passenger going to the Post Office.' 'Go to the Post Office: north 1st right, 2nd right, 1st left.' 'Go to the Taxi Garage: north 1st right, 1st left, 1st right.' > /tmp/t.taxi && test "$(taxi /tmp/t.taxi)" = "ok" && rm -f /tmp/t.taxi ) && \
    ( mkdir -p /tmp/rail && curl --retry 5 -fsSL https://github.com/TryItOnline/rail/archive/04b7259fc19cceba2f06dfdc8431f683c81c80dd.tar.gz | tar -xz -C /tmp/rail --strip-components=1 && (cd /tmp/rail && bash compile.sh && install -m 755 /tmp/rail/rail /usr/local/bin/rail) && rm -rf /tmp/rail && printf "\$ 'main'\n \\\\\n  \\\\-[ok]o#\n" > /tmp/t.rail && test "$(rail /tmp/t.rail)" = "ok" && rm -f /tmp/t.rail ) && \
    ( curl --retry 5 -fsSL -o /tmp/cipple.c https://raw.githubusercontent.com/graue/esofiles/07dce2dbff3325ced047f080b4c9b9f433b3c72b/kipple/impl/cipple-0.2.1.c && gcc -O3 -w /tmp/cipple.c -o /usr/local/bin/cipple && rm -f /tmp/cipple.c && printf '107>o 111>o\n' > /tmp/t.kpl && test "$(cipple /tmp/t.kpl)" = "ok" && rm -f /tmp/t.kpl ) && \
    ( curl --retry 5 -fsSL -o /tmp/rock.tgz https://github.com/RockstarLang/rockstar/releases/download/v2.0.15/rockstar-v2.0.15-linux-x64.tar.gz && echo "cae38e48214f6512a593f8832e4905e11a4d2d218810a36641c1ac8f7eabfa74  /tmp/rock.tgz" | sha256sum -c && mkdir -p /tmp/rock && tar -xzf /tmp/rock.tgz -C /tmp/rock --strip-components=1 && install -m 755 /tmp/rock/rockstar /usr/local/bin/rockstar && rm -rf /tmp/rock /tmp/rock.tgz && printf 'shout "ok"\n' > /tmp/t.rock && test "$(rockstar /tmp/t.rock)" = "ok" && rm -f /tmp/t.rock )
RUN ( cargo install nickel-lang-cli --version 1.18.0 --locked --root /opt/nickel > /tmp/nickel-build.log 2>&1 && ln -s /opt/nickel/bin/nickel /usr/local/bin/nickel && nickel --version ) && \
    ( GOBIN=/usr/local/bin go install cuelang.org/go/cmd/cue@v0.17.1 && GOBIN=/usr/local/bin go install go.starlark.net/cmd/starlark@v0.0.0-20261021141710-4f4267fb140d && cue version | head -1 ) && \
    ( curl -fsSL --retry 6 --retry-delay 10 --retry-all-errors -o /usr/local/bin/pkl https://github.com/apple/pkl/releases/download/0.33.0/pkl-linux-amd64 && echo "b9a6ddea6b382b7d4db4cf78e77aa3858e0c8a7e02939d2ba298574b5d1fcc69  /usr/local/bin/pkl" | sha256sum -c && chmod +x /usr/local/bin/pkl && pkl --version ) && \
    ( curl -fsSL --retry 6 --retry-delay 10 --retry-all-errors -o /usr/local/bin/opa https://github.com/open-policy-agent/opa/releases/download/v1.22.4/opa_linux_amd64_static && echo "35e3b352e715e80624ead6c89930d8585f6f7d94cdc409eb2a9fe36620dcccba  /usr/local/bin/opa" | sha256sum -c && chmod +x /usr/local/bin/opa && opa version | head -1 )
ADD . /usr/local/share/quine-relay
WORKDIR /usr/local/share/quine-relay
RUN make -C vendor && rm -f /usr/bin/sync && dpkg-divert --quiet --local --rename --remove /usr/bin/sync
CMD make check -j 10000
