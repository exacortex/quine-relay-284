# Quine Relay 284

**A 284-step quine relay across 273 distinct programming languages, verified end to end from a clean Ubuntu 26.04 Docker build.**
It extends [Yusuke Endoh's Quine Relay](https://github.com/mame/quine-relay) (128 steps / 123 distinct languages) with 156 more steps (+150 net new distinct languages) — more than doubling the previous world record under both counting rules.

## What this is

[QR.rb](QR.rb) is a Ruby program that generates
a SNOBOL4 program that generates
a Simula program that generates
...(through 284 steps / 273 distinct languages in total)...
a REXX program that generates
the original Ruby code again.

![Language Uroboros][langs]

[langs]: langs.png

The languages in red are the 156 steps added in this fork. Everything in black is mame's Ubuntu 26.04 relay.

## Proof that it works

In November 2026, the full 284-step relay built from scratch (`FROM ubuntu:26.04`) using this repository's [`Dockerfile`](Dockerfile) and ran end to end:

- **All 284 steps ran consecutively on their real interpreters and compilers.** Zero stand-ins, zero skipped steps.
- Step 284 (REXX) printed `QR2.rb`, byte-for-byte identical to `QR.rb` (42680 bytes).
- `make check` passed. SHA-256 of both files:
  `9ce6dbe31564079cb8e7bec5830e06a02b8cb7c651b7a48e0f6970aaeceb509a`

The complete standalone `docker build` log, `docker run` log, and payload profile are in [`proof/`](proof/). Anyone can repeat the exact build and run with the two Docker commands below.

## What's new in this fork

**156 new steps** — 151 Tier-1 steps (including 17 classic languages restored from mame's retired Ubuntu relays, with `BASIC (bwBASIC)` sharing the BASIC family with mame's `Yabasic` for **+150 net new distinct Tier-1 languages**) plus 5 Tier-2-only implementations (`mksh`, `BusyBox ash`, `yash`, `Chicken Scheme`, `Chez Scheme`):

SNOBOL4, Simula, Oberon, Euphoria, ALGOL 60, BCPL, K (ngn/k), BASIC (bwBASIC), ChucK, dash, groff, Hy, Jsonnet, newLISP, NQP, PicoLisp, Racket, SQL (SQLite), AspectC++, Parrot asm (PASM), xonsh, mksh, BusyBox ash, Arturo, yash, YueScript, Elvish, Rocq, Lean 4, Idris 2, V, Hare, C3, Nelua, Zig, PowerShell, Nushell, Ion, YSH, Murex, Hush, es, Boo, VHDL, Genie, Nix, XQuery, Pkl, Koto, CUE, Macaulay2, Dart, Anko, Tengo, Nickel, Rhai, ><> (Fish), Hexagony, ///, CJam, Underload, Brain-Flak, Singular, FriCAS, Nial, Uiua, BQN, Fantom, Golo, Ballerina, Yeti, Gosu, Frege, J, Starlark, Teal, Umka, F*, MoonScript, Rego, Mathics, Berry, Pyth, Emmental, ArnoldC, LFE, Joy, Factor, Numbat, Frink, Ring, Janet, Io, Picat, CLIPS, Wren, PureScript, Elm, Pyret, ReScript, Wisp, Imba, Dafny, Julia, Maxima, Gri, UCBLogo, GNU Smalltalk, TXR, Gravity, Klong, GSL (Generator Scripting Language), Seed7, Curry, nesC, REDUCE, Lisaac, eC, CDuce, A+, Falcon, Coconut, Gleam, Roc, Inko, Koka, Chapel, Pony, Odin, rep (librep), Chicken Scheme, Rockstar, Chez Scheme, Mercury, Maude, Logtalk, Agda, ACL2, Rail, Kipple, Beatnik, Glass, Taxi, Deadfish~, Lout, Plain TeX, MetaPost, Inform 6, Ink, TADS 3, Uxntal, MMIX, 6502 asm, ARM64 asm, Z80 asm, RISC-V asm.

See [RELAY-284.md](RELAY-284.md) for how 284 steps fit into a ~41 KB Ruby quine without blowing through compiler, VM, and memory ceilings (zero-backslash Forth `126 PARSE`, 3-byte base-84 LZ78 in Kotlin, self-reading comment decoders for Shakespeare and historical languages, and interleaved Re-Pair assembly compression).

## Records

We claim records under two transparent counting rules, published in [RECORDS.md](RECORDS.md) so anyone can verify or challenge them:

- **Tier 1, distinct languages:** each language counts once regardless of versions, dialects, or implementations. This relay counts **273** distinct languages (mame's 128 counts 123; [quine-relay-151](https://github.com/exacortex/quine-relay-151) counted 143).
- **Tier 2, relay steps:** every step runs on its own real interpreter or compiler with its own source file, with at most 3 steps per language family. This relay counts **284** steps.

See [RECORDS.md](RECORDS.md) for the full rules and leaderboard, and [LANGUAGES.md](LANGUAGES.md) for the step-by-step Tier 1 / Tier 2 audit.

## Usage

### Docker (recommended)

    $ docker build -t qr .
    $ docker run --rm qr

This installs every Ubuntu package, builds all source/release toolchains and bundled interpreters in `vendor/`, runs all 284 steps in order, and verifies `QR2.rb == QR.rb`.

### Ubuntu 26.04

#### 1. Install the Ubuntu packages and extra toolchains.

    $ sudo apt-get install acl2 afnix agda algol68g aspectc++ aspectj \
      asymptote ats2-lang basex bash bc bsh busybox-static bwbasic \
      chezscheme chicken-bin chuck clips clisp clojure cmake coffeescript \
      coq crystal dash dc default-jdk-headless dhall dotnet-sdk-10.0 elixir \
      elvish emacs-nox erlang erlang-nox execline f2c fennel fish flex \
      fp-compiler fricas g++ gambas3-gb-pcre gambas3-scripter gap gawk gcc \
      gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu gdb gdc \
      generator-scripting-language genius gforth gfortran ghc ghdl \
      ghostscript gm2 gnat gnucobol4 gnuplot gobjc golang gpt gri groff \
      groovy guile-3.0 gzip hare haxe hy icont iconx inform6-compiler \
      intercal iverilog jasmin-sable jq jsonnet kotlin ksh libevent-dev \
      libpolyml-dev livescript llvm lua5.3 m4 macaulay2 make maude maxima \
      minizinc mksh mono-devel nasm neko newlisp nickle nim nix-bin \
      node-typescript nodejs nqp ocaml octave openjdk-25-jdk pari-gp \
      parser3-cgi perl php-cli picolisp pike8.0 polyml python3 qemu-user \
      r-base racket rakudo ratfor rc regina-rexx rep ruby ruby-mustache \
      rustc scala scilab-cli sed singular slsh spin sqlite3 squirrel3 \
      surgescript swi-prolog swi-prolog-nox swiftlang tcl tcsh \
      texlive-binaries texlive-metapost valac vim wabt xa65 xonsh xsltproc \
      yabasic yash yorick z80asm zoem zsh

For the remaining languages installed from pinned releases, cargo, Go, npm, pip, LuaRocks, or source tarballs, see [`Dockerfile`](Dockerfile) (generated from [`src/Dockerfile.gen.rb`](src/Dockerfile.gen.rb) and [`src/extra-installs/`](src/extra-installs/)).

Then build the bundled interpreters:

    $ sudo apt-get install cmake libpng-dev libgd-dev libfl-dev groff bison curl
    $ make -C vendor

#### 2. Run each program on each interpreter/compiler.

    $ ulimit -s unlimited
    $ ruby QR.rb > QR.sno
    $ snobol4 -b QR.sno > QR.sim
    $ rm -f QR QR.c && cim -q QR.sim >/dev/null 2>&1 && ./QR > QR.obn &&
      rm -f QR QR.c
    $ rm -rf QR .obnc && obnc QR.obn >/dev/null && ./QR > QR.ex && rm -rf QR .obnc
    $ eui QR.ex > QR.alg
    $ marst QR.alg -o QR.alg.c && gcc QR.alg.c -lalgol -lm -o QR && ./QR < QR.alg > QR.b &&
      rm -f QR QR.alg.c
    $ rm -f QR QR.out && BCPLROOT=/opt/BCPL/cintcode BCPLPATH=/opt/BCPL/cintcode/cin64 BCPLHDRS=/opt/BCPL/cintcode/g BCPLSCRIPTS=/opt/BCPL/cintcode/s /opt/BCPL/cintcode/bin/cintsys64 -c 'bcpl QR.b to QR; QR' >/dev/null &&
      cat QR.out > QR.k.k && rm -f QR QR.out
    $ ngnk QR.k.k < /dev/null > QR.bas
    $ bwbasic QR.bas > /dev/null; cat QR.out > QR.ck
    $ chuck --silent QR.ck > QR.dash
    $ dash QR.dash > QR.roff
    $ groff -z QR.roff 2> QR.hy
    $ hy QR.hy > QR.jsonnet
    $ jsonnet -S QR.jsonnet > QR.nl
    $ newlisp -n QR.nl > QR.nqp
    $ nqp QR.nqp > QR.l
    $ pil QR.l > QR.rkt
    $ racket QR.rkt > QR.sql
    $ sqlite3 < QR.sql > QR.cc
    $ ag++ --keywords -o QR QR.cc && ./QR > QR.pasm
    $ parrot QR.pasm > QR.xsh
    $ xonsh --no-rc QR.xsh > QR.mksh
    $ mksh QR.mksh > QR.bbash
    $ busybox ash QR.bbash > QR.art
    $ arturo QR.art < /dev/null > QR.yash
    $ yash QR.yash > QR.yue
    $ yue -e QR.yue > QR.elv
    $ elvish QR.elv > QR_rocq.v
    $ coqc QR_rocq.v && printf 'module Pstring=struct let unsafe_of_string s=s end\n' | cat - QR_rocq.ml > QR_rocq_run.ml &&
      ocaml QR_rocq_run.ml > QR.lean && rm -f QR_rocq.ml QR_rocq_run.ml QR_rocq.vo QR_rocq.vok QR_rocq.vos QR_rocq.glob
    $ lean --run QR.lean > QR.idr
    $ idris2 --exec main QR.idr > QR.vlang.v
    $ v run QR.vlang.v > QR.ha
    $ hare build -q -o QR QR.ha && ./QR > QR.c3
    $ c3c compile QR.c3 -o QR && ./QR > QR.nelua
    $ nelua --no-cache QR.nelua > QR.zig
    $ zig run QR.zig > QR.ps1
    $ DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 POWERSHELL_TELEMETRY_OPTOUT=1 pwsh -NoProfile -NonInteractive -File QR.ps1 > QR.nu
    $ nu --no-config-file QR.nu > QR.ion
    $ ion QR.ion > QR.ysh
    $ ysh QR.ysh > QR.mx
    $ murex QR.mx > QR.hsh
    $ hush QR.hsh > QR.es
    $ es QR.es > QR.boo
    $ booi QR.boo > QR.vhdl
    $ ghdl -a QR.vhdl && ghdl -e qr && ghdl -r qr > QR.genie.gs
    $ valac QR.genie.gs && ./QR.genie > QR.nix
    $ nix eval --extra-experimental-features nix-command --raw --file QR.nix > QR.xq
    $ basex QR.xq > QR.pkl
    $ pkl eval QR.pkl > QR.koto
    $ koto QR.koto > QR.cue
    $ cue export --out text -e o QR.cue > QR.m2
    $ M2 --script QR.m2 > QR.dart
    $ dart run QR.dart > QR.ank
    $ anko QR.ank > QR.tengo
    $ tengo QR.tengo > QR.ncl
    $ nickel export --format text QR.ncl > QR.rhai
    $ rhai-run QR.rhai > QR.rs
    $ rustc QR.rs && ./QR > QR.scala
    $ scalac QR.scala && scala QR > QR.scm
    $ guile QR.scm > QR.sci
    $ scilab-cli -nb -f QR.sci > QR.sed
    $ sed -E -f QR.sed QR.sed > QR.spl
    $ spl2c < QR.spl > QR.spl.c && gcc -z muldefs -o QR -I ./vendor/local/include -L ./vendor/local/lib QR.spl.c -lspl -lm &&
      ./QR > QR.sl
    $ slsh QR.sl > QR.nut
    $ squirrel QR.nut > QR.sml
    $ polyc -o QR QR.sml && ./QR > QR.sq
    $ ruby vendor/subleq.rb QR.sq > QR.ss
    $ surgescript QR.ss > QR.swift
    $ swiftc QR.swift && ./QR > QR.tcl
    $ tclsh QR.tcl > QR.tcsh
    $ tcsh QR.tcsh > QR.t
    $ ruby vendor/thue.rb QR.t > QR.ts
    $ tsc --outFile QR.ts.js QR.ts && nodejs QR.ts.js > QR.unl
    $ ruby vendor/unlambda.rb QR.unl > QR.v
    $ iverilog -o QR QR.v && ./QR -vcd-none > QR.fish.fish
    $ python3 vendor/fish.py QR.fish.fish > QR.hxg
    $ ruby /opt/hexagony/interpreter.rb QR.hxg > QR.vim
    $ vim -EsS QR.vim > QR.vb
    $ echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.vb" /></ItemGroup></Project>' > tmp.vbproj &&
      DOTNET_NOLOGO=1 dotnet run --project tmp.vbproj > QR.wasm
    $ $(WASI_RUNTIME) QR.wasm > QR.wat
    $ wat2wasm QR.wat -o QR.wat.wasm && $(WASI_RUNTIME) QR.wat.wasm > QR.ws
    $ ruby vendor/whitespace.rb QR.ws > QR.xslt
    $ xsltproc QR.xslt > QR.slashes
    $ ruby vendor/slashes.rb QR.slashes > QR.cjam
    $ ruby vendor/cjam.rb QR.cjam > QR.ul
    $ ruby vendor/underload.rb QR.ul > QR.bflk
    $ ruby vendor/brain_flak.rb -A QR.bflk > QR.yab
    $ yabasic QR.yab > QR.yorick
    $ yorick -batch QR.yorick > QR.sing
    $ Singular -q QR.sing > QR.input
    $ fricas -nosman < QR.input > /dev/null && cat QR_fricas.out > QR.azm
    $ zoem -i QR.azm > QR.ndf
    $ nial -defs QR.ndf < /dev/null > QR.zsh
    $ zsh QR.zsh > QR.ua
    $ uiua run --no-format QR.ua > QR.bqn
    $ bqn QR.bqn > QR.fan
    $ fan QR.fan > QR.golo
    $ golo golo --files QR.golo > QR.bal
    $ bal run --offline QR.bal > QR.yeti
    $ yeti QR.yeti > QR.gsp
    $ gosu QR.gsp > QR.fr
    $ mkdir -p frege-out && frege -d frege-out QR.fr && java -cp frege-out:/usr/local/lib/frege.jar QR > qr.adb
    $ gnatmake qr.adb && ./qr > QR.als
    $ LANG=C LD_LIBRARY_PATH=/usr/lib/afnix axi QR.als > QR.aheui
    $ ruby vendor/aheui.rb QR.aheui > QR.ijs
    $ ijconsole QR.ijs < /dev/null > QR.a68
    $ a68g --heap 512M QR.a68 > QR.ante
    $ ruby vendor/ante.rb QR.ante > QR.star
    $ starlark QR.star 2> QR.aj
    $ ajc QR.aj && java QR > QR.tl
    $ tl run QR.tl > QR.asy
    $ asy QR.asy > QR.um
    $ umka QR.um > QR.fst
    $ fstar.exe --cache_checked_modules --cache_dir fst_out QR.fst > /dev/null &&
      fstar.exe --cache_dir fst_out --odir fst_out --codegen OCaml --custard_main QR.main QR.fst > /dev/null &&
      ocaml fst_out/Custard.ml > QR.dats
    $ patscc -o QR QR.dats && ./QR > QR.moon
    $ moon QR.moon > QR.awk
    $ awk -f QR.awk > QR.rego
    $ opa eval --format raw -d QR.rego data.qr.x > QR.wl
    $ mathics -q --no-completion -f QR.wl < /dev/null > QR.bash
    $ bash QR.bash > QR.bc
    $ BC_LINE_LENGTH=4000000 bc -q QR.bc > QR.be
    $ berry QR.be > QR.c
    $ gcc -o QR QR.c && ./QR > QR.cpp
    $ g++ -o QR QR.cpp && ./QR > QR.pyth
    $ python3 /opt/pyth/pyth.py -n QR.pyth > QR.emmental
    $ ruby vendor/emmental.rb QR.emmental > QR.arnoldc
    $ rm -f QR.class && java -jar /opt/ArnoldC.jar QR.arnoldc && java QR > QR.lfe &&
      rm -f QR.class
    $ lfe QR.lfe > QR.joy
    $ joy QR.joy > QR.factor
    $ /opt/factor/factor QR.factor > QR.nbt
    $ numbat QR.nbt > QR.cs
    $ echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.cs" /></ItemGroup></Project>' > tmp.csproj &&
      DOTNET_NOLOGO=1 dotnet run --project tmp.csproj > QR.chef
    $ PERL5LIB=vendor/local/lib/perl5 compilechef QR.chef QR.chef.pl &&
      perl QR.chef.pl > QR.frink
    $ java -cp /opt/frink/frink.jar frink.parser.Frink QR.frink > QR.clj
    $ clojure QR.clj > QR.cmake
    $ cmake -P QR.cmake > QR.cob
    $ cobc -O2 -x QR.cob && ./QR > QR.ring
    $ ring QR.ring > QR.coffee
    $ coffee --nodejs --stack_size=100000 QR.coffee > QR.lisp
    $ clisp QR.lisp > QR.cr
    $ crystal QR.cr > QR.d
    $ gdc -o QR QR.d && ./QR > QR.dc
    $ dc QR.dc > QR.dhall || true
    $ dhall text --file QR.dhall > QR.exs
    $ elixir QR.exs > QR.el
    $ emacs -Q --script QR.el > QR.erl
    $ escript QR.erl > QR.e
    $ execlineb QR.e > QR.fsx
    $ echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.fsx" /></ItemGroup></Project>' > tmp.fsproj &&
      DOTNET_NOLOGO=1 dotnet run --project tmp.fsproj > QR.false
    $ ruby vendor/false.rb QR.false > QR.fnl
    $ fennel QR.fnl > QR.fl
    $ flex -o QR.fl.c QR.fl && gcc -o QR QR.fl.c && ./QR > QR.fish
    $ fish QR.fish > QR.fs
    $ gforth QR.fs > QR.f
    $ gfortran -o QR QR.f && ./QR > QR.f90
    $ gfortran -o QR QR.f90 && ./QR > QR.gbs
    $ gbs3 QR.gbs > QR.g
    $ gap -q QR.g > QR.gdb
    $ gdb -q -x QR.gdb > QR.gel
    $ genius QR.gel > QR.plt
    $ gnuplot QR.plt > QR.go
    $ go run QR.go > QR.gs
    $ ruby vendor/golfscript.rb QR.gs > QR.gpt
    $ mv QR.c QR.c.bak && gpt -t QR.c QR.gpt && gcc -o QR QR.c && ./QR > QR.grass &&
      mv QR.c.bak QR.c
    $ ruby vendor/grass.rb QR.grass > QR.janet
    $ janet QR.janet > QR.groovy
    $ groovy QR.groovy > QR.gz
    $ gzip -cd QR.gz > QR.io
    $ io QR.io > QR.hs
    $ rm -f QR.o && ghc QR.hs && ./QR > QR.pi
    $ picat QR.pi > QR.hx
    $ haxe -main QR -neko QR.n && neko QR.n > QR.clp
    $ clips -f2 QR.clp > QR.icn
    $ icont -s QR.icn && ./QR > QR.i
    $ ick -bfOc QR.i && gcc -std=c99 -static QR.c -I /usr/include/ick-* -o QR -lick &&
      ./QR > QR.wren
    $ wren_cli QR.wren > QR.j
    $ jasmin QR.j && java QR > QR.purs
    $ purs compile -o /opt/purs/out QR.purs '/opt/purs/lib/*/src/**/*.purs' &&
      node /opt/purs/run.mjs > QR.elm
    $ cp QR.elm /opt/elm/src/QR.elm && cd /opt/elm; elm make src/QR.elm --output=/usr/local/share/quine-relay/QR.elm.js &&
      node -e 'require("./QR.elm.js").Elm.QR.init().ports.o.subscribe(s=>process.stdout.write(s))' > QR.arr
    $ pyretc QR.arr QR.jarr && NODE_PATH=/opt/b05/node_modules node QR.jarr > QR.res
    $ bsc QR.res > QR.res.js && node QR.res.js > QR.wisp
    $ wisp < QR.wisp > QR.wisp.js && node QR.wisp.js > QR.imba
    $ imba QR.imba > QR.dfy
    $ dafny build -o dafny-out/QR QR.dfy && DOTNET_ROLL_FORWARD=Major dotnet dafny-out/QR.dll > QR.jl
    $ julia QR.jl > QR.mac
    $ maxima -q --init-mac=QR.mac > QR.gri
    $ gri QR.gri > QR.logo
    $ ucblogo QR.logo > QR.java
    $ javac QR.java && java QR > QR.st
    $ gst QR.st > QR.js
    $ nodejs QR.js > QR.jq
    $ jq -r -n -f QR.jq > QR.jsfuck
    $ nodejs --stack_size=100000 QR.jsfuck > QR.kt
    $ kotlinc QR.kt -include-runtime -d QR.jar && kotlin QR.jar > QR.txrlisp
    $ txr --lisp QR.txrlisp > QR.gravity
    $ gravity -q QR.gravity > QR.kg
    $ kg QR.kg < /dev/null > QR.gsl
    $ gsl -q QR.gsl > QR.sd7
    $ s7 -q QR.sd7 > QR.curry
    $ pakcs --nocypm :load QR.curry :save :quit && ./QR > QR.nc
    $ nescc -gcc=gcc-14 -o QR QR.nc && ./QR > QR.ll
    $ llvm-as QR.ll && lli QR.bc > QR.red
    $ redcsl -w -b < QR.red > /dev/null && cat QR_reduce.out > QR.lol
    $ lci QR.lol > QR.lua
    $ lua5.3 QR.lua > qr.li
    $ lisaac -gcc -Wno-implicit-function-declaration qr.li > /dev/null &&
      ./qr > QR_ec.ec
    $ ecp -c QR_ec.ec -o QR_ec.sym && ecc -c QR_ec.ec -o QR_ec.c && ecs -console QR_ec.sym QR_ec.imp -o QR_ec.main.ec &&
      ecp -c QR_ec.main.ec -o QR_ec.main.sym && ecc -c QR_ec.main.ec -o QR_ec.main.c &&
      gcc -std=gnu17 -w -o QR_ec QR_ec.c QR_ec.main.c -lecereCOM &&
      ./QR_ec > QR.cd
    $ cduce QR.cd > QR.aplus.a
    $ a+ QR.aplus.a > QR.m4 2> /dev/null < /dev/null
    $ m4 QR.m4 > QR.mk
    $ make -f QR.mk > QR.mzn
    $ minizinc --solver COIN-BC --soln-sep '' QR.mzn > QR.mod
    $ gm2 -fiso QR.mod -o QR && ./QR > QR.il
    $ ilasm QR.il && mono QR.exe > QR.php
    $ php QR.php > QR.png
    $ npiet QR.png > QR.mustache
    $ mustache QR.mustache QR.mustache > QR.asm
    $ nasm -felf QR.asm && ld -m elf_i386 -o QR QR.o && ./QR > QR.neko
    $ nekoc QR.neko && neko QR.n > QR.5c
    $ nickle QR.5c > QR.nim
    $ nim compile QR.nim && ./QR > QR.m
    $ gcc -o QR QR.m && ./QR > QR.ml
    $ ocaml QR.ml > QR.fal
    $ falcon QR.fal > QR.vala
    $ valac QR.vala && ./QR > QR.mid
    $ mono vendor/local/bin/Vlt.exe /s QR.mid && mono QR.exe > QR.coco
    $ coconut -q -r QR.coco > QR.octave
    $ mv QR.m QR.m.bak && octave -qf QR.octave > QR.ook && mv QR.m.bak QR.m
    $ ruby vendor/ook-to-bf.rb QR.ook QR.ook.bf && ruby vendor/bf.rb QR.ook.bf > QR.gp
    $ gp -f -q QR.gp > QR.gleam
    $ mkdir -p qrgleam/src && cp QR.gleam qrgleam/src/qr.gleam && printf 'name = "qr"\nversion = "1.0.0"\n' > qrgleam/gleam.toml &&
      (cd qrgleam; gleam run --no-print-progress) > QR.roc
    $ roc build --output qrroc QR.roc && ./qrroc > QR.inko
    $ inko run QR.inko > qr.kk
    $ koka -v0 -o qrkoka qr.kk && chmod +x qrkoka && ./qrkoka > QR.chpl
    $ chpl -o qrchpl QR.chpl && ./qrchpl > QR.pony
    $ mkdir -p qrpony && cp QR.pony qrpony/main.pony && ponyc -V0 -b qrpony.out -o . qrpony &&
      ./qrpony.out > QR.odin
    $ odin run QR.odin -file > QR.rep
    $ rep QR.rep > QR.chicken.scm
    $ csi -q -s QR.chicken.scm > QR.rock
    $ rockstar QR.rock > QR.chez.ss
    $ chezscheme --script QR.chez.ss > QR.p
    $ parser3 QR.p > QR.pas
    $ fpc QR.pas && ./QR > QR.pl
    $ perl QR.pl > QR.pl6
    $ perl6 QR.pl6 > qr_mercury.m
    $ mmc --make qr_mercury > /dev/null && ./qr_mercury > QR.maude
    $ maude -no-banner -no-advise -allow-files file QR.maude < /dev/null > /dev/null &&
      cat QR_maude.out > QR.pike
    $ pike QR.pike > QR.lgt
    $ swilgt -q -g "logtalk_load('QR.lgt'),halt" < /dev/null > QR.ps
    $ gs -dNODISPLAY -q QR.ps > QR.agda
    $ agda --compile --compile-dir=agda_out QR.agda > /dev/null && ./agda_out/QR > QR.prolog
    $ swipl -q -t qr -f QR.prolog > QR.acl2
    $ acl2 < QR.acl2 > /dev/null && cat QR_acl2.out > QR.pr
    $ spin -T QR.pr > QR.rail
    $ rail QR.rail > QR.kpl
    $ cipple QR.kpl > QR.beatnik
    $ ruby vendor/beatnik.rb QR.beatnik > QR.glass
    $ ruby vendor/glass.rb QR.glass > QR.taxi
    $ taxi QR.taxi > QR.dft
    $ ruby vendor/deadfish_tilde.rb QR.dft > QR.lout
    $ lout -s -p6p12p QR.lout 2>/dev/null | tr -d '\014' | grep . > QR.tex
    $ rm -f QR.out QR.log && tex -interaction=batchmode QR.tex >/dev/null &&
      cat QR.out > QR.mp && rm -f QR.out QR.log
    $ rm -f QR.out QR.log && mpost -interaction=batchmode QR.mp >/dev/null &&
      cat QR.out > QR.inf && rm -f QR.out QR.log
    $ rm -f QR.z8 && inform6 -v8 QR.inf QR.z8 >/dev/null && dfrotz -m -q -r cm -w 240 -h 200 QR.z8 | tail -n +2 > QR.ink &&
      rm -f QR.z8
    $ inklecate -p QR.ink > QR.t3.t
    $ rm -f QR.out QR.t3 && t3make -q -a -FI /usr/share/frobtads/tads3/include -FI /usr/local/share/frobtads/tads3/include -FL /usr/share/frobtads/tads3/lib -FL /usr/local/share/frobtads/tads3/lib -o QR.t3 system.tl QR.t3.t &&
      frob -i plain -p -s0 QR.t3 >/dev/null && cat QR.out > QR.tal &&
      rm -f QR.out QR.t3
    $ uxnasm QR.tal QR.rom && uxncli QR.rom > QR.mms && rm -f QR.rom
    $ mmixal -b 2000000 -o QR.mmo QR.mms && mmix QR.mmo > QR.s65 && rm -f QR.mmo
    $ xa -o QR.o65 QR.s65 && python3 vendor/run6502.py QR.o65 > QR.arm64.s
    $ rm -f QR && aarch64-linux-gnu-gcc -nostdlib -static -o QR QR.arm64.s &&
      qemu-aarch64 ./QR > QR.z80 && rm -f QR
    $ z80asm QR.z80 -o QR.z80.bin && python3 vendor/runz80.py QR.z80.bin > QR.rv.s
    $ rm -f QR && riscv64-linux-gnu-gcc -nostdlib -static -o QR QR.rv.s &&
      qemu-riscv64 ./QR > QR.bsh && rm -f QR
    $ bsh QR.bsh > QR.bef
    $ cfunge QR.bef > QR.Blc
    $ ruby vendor/blc.rb < QR.Blc > QR.bf
    $ ruby vendor/bf.rb QR.bf > QR.ksh
    $ ksh QR.ksh > QR.lazy
    $ lazyk QR.lazy > QR.ls
    $ lsc QR.ls > QR.py
    $ python3 QR.py > QR.R
    $ R --slave -f QR.R > QR.ratfor
    $ ratfor -o QR.ratfor.f QR.ratfor && gfortran -o QR QR.ratfor.f &&
      ./QR > QR.rc
    $ rc QR.rc > QR.rexx
    $ rexx ./QR.rexx > QR2.rb

You will see that `QR.rb` is byte-for-byte identical to `QR2.rb`:

    $ diff -s QR.rb QR2.rb

Or just run `make check`:

    $ make check

## Languages and packages

\#  |language                           |ubuntu package (or how to get it)                     |added in
----|-----------------------------------|------------------------------------------------------|--------------
1   |Ruby                               |ruby                                                  |mame
2   |SNOBOL4                            |`CSNOBOL4 2.3 source tarball`                         |**this fork**
3   |Simula                             |`GNU Cim 5.1 source tarball`                          |**this fork**
4   |Oberon                             |`OBNC 0.17.2 source tarball`                          |**this fork**
5   |Euphoria                           |`OpenEuphoria 4.1.0 release`                          |**this fork**
6   |ALGOL 60                           |`GNU MARST 2.8 source tarball`                        |**this fork**
7   |BCPL                               |`Martin Richards BCPL Cintcode kit`                   |**this fork**
8   |K (ngn/k)                          |`codeberg.org/ngn/k (clang build)`                    |**this fork**
9   |BASIC (bwBASIC)                    |bwbasic                                               |**this fork**
10  |ChucK                              |chuck                                                 |**this fork**
11  |dash                               |dash                                                  |**this fork**
12  |groff                              |groff                                                 |**this fork**
13  |Hy                                 |hy                                                    |**this fork**
14  |Jsonnet                            |jsonnet                                               |**this fork**
15  |newLISP                            |newlisp                                               |**this fork**
16  |NQP                                |nqp                                                   |**this fork**
17  |PicoLisp                           |picolisp                                              |**this fork**
18  |Racket                             |racket                                                |**this fork**
19  |SQL (SQLite)                       |sqlite3                                               |**this fork**
20  |AspectC++                          |aspectc++                                             |**this fork**
21  |Parrot asm (PASM)                  |`Parrot 8.1.0 source build`                           |**this fork**
22  |xonsh                              |xonsh                                                 |**this fork**
23  |mksh                               |mksh                                                  |**this fork**
24  |BusyBox ash                        |busybox-static                                        |**this fork**
25  |Arturo                             |`Arturo v0.10.0 release`                              |**this fork**
26  |yash                               |yash                                                  |**this fork**
27  |YueScript                          |`YueScript v0.34.3 source build`                      |**this fork**
28  |Elvish                             |elvish                                                |**this fork**
29  |Rocq                               |coq                                                   |**this fork**
30  |Lean 4                             |`Lean v4.35.0 release`                                |**this fork**
31  |Idris 2                            |`Idris2 v0.8.0 source build`                          |**this fork**
32  |V                                  |`V 0.4.12 release`                                    |**this fork**
33  |Hare                               |hare                                                  |**this fork**
34  |C3                                 |`c3c v0.7.0 release`                                  |**this fork**
35  |Nelua                              |`nelua-lang source build`                             |**this fork**
36  |Zig                                |`Zig 0.13.0 release`                                  |**this fork**
37  |PowerShell                         |`PowerShell v7.4.6 release`                           |**this fork**
38  |Nushell                            |`Nushell 0.101.0 release`                             |**this fork**
39  |Ion                                |`cargo install ion-shell`                             |**this fork**
40  |YSH                                |`Oils for Unix 0.24.0 source tarball`                 |**this fork**
41  |Murex                              |`Murex v7.4.2002 (Go build)`                          |**this fork**
42  |Hush                               |`cargo install hush@0.1.4`                            |**this fork**
43  |es                                 |`es-shell v0.9.2 source tarball`                      |**this fork**
44  |Boo                                |`Ubuntu archive boo 0.9.5 (.deb)`                     |**this fork**
45  |VHDL                               |ghdl                                                  |**this fork**
46  |Genie                              |valac                                                 |**this fork**
47  |Nix                                |nix-bin                                               |**this fork**
48  |XQuery                             |basex                                                 |**this fork**
49  |Pkl                                |`Apple Pkl 0.33.0 release`                            |**this fork**
50  |Koto                               |`cargo install koto_cli@0.16.1`                       |**this fork**
51  |CUE                                |`go install cuelang.org/go/cmd/cue@v0.17.1`           |**this fork**
52  |Macaulay2                          |macaulay2                                             |**this fork**
53  |Dart                               |`Dart SDK 3.14.0 release`                             |**this fork**
54  |Anko                               |`go install github.com/mattn/anko@v0.1.15`            |**this fork**
55  |Tengo                              |`go install github.com/d5/tengo/v2/cmd/tengo@v2.17.0` |**this fork**
56  |Nickel                             |`cargo install nickel-lang-cli@1.18.0`                |**this fork**
57  |Rhai                               |`cargo install rhai@1.27.0`                           |**this fork**
58  |Rust                               |rustc                                                 |mame
59  |Scala                              |scala                                                 |mame
60  |Scheme                             |guile-3.0                                             |mame
61  |Scilab                             |scilab-cli                                            |mame
62  |sed                                |sed                                                   |mame
63  |Shakespeare                        |*bundled in vendor/*                                  |mame
64  |S-Lang                             |slsh                                                  |mame
65  |Squirrel                           |squirrel3                                             |mame
66  |Standard ML                        |polyml, libpolyml-dev                                 |mame
67  |Subleq                             |*bundled in vendor/*                                  |mame
68  |SurgeScript                        |surgescript                                           |mame
69  |Swift                              |swiftlang                                             |mame
70  |Tcl                                |tcl                                                   |mame
71  |tcsh                               |tcsh                                                  |mame
72  |Thue                               |*bundled in vendor/*                                  |mame
73  |TypeScript                         |node-typescript                                       |mame
74  |Unlambda                           |*bundled in vendor/*                                  |mame
75  |Verilog                            |iverilog                                              |mame
76  |><> (Fish)                         |*bundled in vendor/*                                  |**this fork**
77  |Hexagony                           |`m-ender/hexagony (official Ruby interpreter)`        |**this fork**
78  |Vimscript                          |vim                                                   |mame
79  |Visual Basic                       |dotnet-sdk-10.0                                       |mame
80  |WebAssembly (Binary format)        |wabt                                                  |mame
81  |WebAssembly (Text format)          |wabt                                                  |mame
82  |Whitespace                         |*bundled in vendor/*                                  |mame
83  |XSLT                               |xsltproc                                              |mame
84  |///                                |*bundled in vendor/*                                  |**this fork**
85  |CJam                               |*bundled in vendor/*                                  |**this fork**
86  |Underload                          |*bundled in vendor/*                                  |**this fork**
87  |Brain-Flak                         |*bundled in vendor/*                                  |**this fork**
88  |Yabasic                            |yabasic                                               |mame
89  |Yorick                             |yorick                                                |mame
90  |Singular                           |singular                                              |**this fork**
91  |FriCAS                             |fricas                                                |**this fork**
92  |Zoem                               |zoem                                                  |mame
93  |Nial                               |`Q'Nial nialcore source build`                        |**this fork**
94  |zsh                                |zsh                                                   |mame
95  |Uiua                               |`cargo install uiua@0.19.1`                           |**this fork**
96  |BQN                                |`CBQN v0.9.0 (clang build)`                           |**this fork**
97  |Fantom                             |`Fantom v1.0.84 release`                              |**this fork**
98  |Golo                               |`Eclipse Golo 3.4.0 release`                          |**this fork**
99  |Ballerina                          |`Ballerina 2201.14.1 (.deb)`                          |**this fork**
100 |Yeti                               |`Yeti ML source build (ant)`                          |**this fork**
101 |Gosu                               |`Gosu 1.18.14 Maven release`                          |**this fork**
102 |Frege                              |`Frege 3.25.84 jar release`                           |**this fork**
103 |Ada                                |gnat                                                  |mame
104 |AFNIX                              |afnix                                                 |mame
105 |Aheui                              |*bundled in vendor/*                                  |mame
106 |J                                  |`J 9.7 release`                                       |**this fork**
107 |ALGOL 68                           |algol68g                                              |mame
108 |Ante                               |*bundled in vendor/*                                  |mame
109 |Starlark                           |`go install go.starlark.net/cmd/starlark`             |**this fork**
110 |AspectJ                            |aspectj                                               |mame
111 |Teal                               |`luarocks install tl 0.24.8-1`                        |**this fork**
112 |Asymptote                          |asymptote                                             |mame
113 |Umka                               |`Umka v1.5.7 source build`                            |**this fork**
114 |F*                                 |`FStar v2026.10.25 release`                           |**this fork**
115 |ATS                                |ats2-lang                                             |mame
116 |MoonScript                         |`luarocks install moonscript 0.5.0-1`                 |**this fork**
117 |Awk                                |gawk                                                  |mame
118 |Rego                               |`Open Policy Agent v1.22.4 release`                   |**this fork**
119 |Mathics                            |`pip install mathics3==10.0.1`                        |**this fork**
120 |bash                               |bash                                                  |mame
121 |bc                                 |bc                                                    |mame
122 |Berry                              |`Berry v1.1.0 source build`                           |**this fork**
123 |C                                  |gcc                                                   |mame
124 |C++                                |g++                                                   |mame
125 |Pyth                               |`isaacg1/pyth git release + python3`                  |**this fork**
126 |Emmental                           |*bundled in vendor/*                                  |**this fork**
127 |ArnoldC                            |`ArnoldC.jar + default-jdk-headless`                  |**this fork**
128 |LFE                                |erlang-nox                                            |**this fork**
129 |Joy                                |`Joy source build`                                    |**this fork**
130 |Factor                             |`Factor 0.100 release`                                |**this fork**
131 |Numbat                             |`cargo install numbat-cli@1.24.0`                     |**this fork**
132 |C#                                 |dotnet-sdk-10.0                                       |mame
133 |Chef                               |*bundled in vendor/*                                  |mame
134 |Frink                              |*bundled in vendor/*                                  |**this fork**
135 |Clojure                            |clojure                                               |mame
136 |CMake                              |cmake                                                 |mame
137 |Cobol                              |gnucobol4                                             |mame
138 |Ring                               |`Ring v1.27 source build`                             |**this fork**
139 |CoffeeScript                       |coffeescript                                          |mame
140 |Common Lisp                        |clisp                                                 |mame
141 |Crystal                            |crystal, libevent-dev                                 |mame
142 |D                                  |gdc                                                   |mame
143 |dc                                 |dc                                                    |mame
144 |Dhall                              |dhall                                                 |mame
145 |Elixir                             |elixir                                                |mame
146 |Emacs Lisp                         |emacs-nox                                             |mame
147 |Erlang                             |erlang                                                |mame
148 |Execline                           |execline                                              |mame
149 |F#                                 |dotnet-sdk-10.0                                       |mame
150 |FALSE                              |*bundled in vendor/*                                  |mame
151 |Fennel                             |fennel                                                |mame
152 |Flex                               |flex                                                  |mame
153 |Fish                               |fish                                                  |mame
154 |Forth                              |gforth                                                |mame
155 |FORTRAN77                          |f2c                                                   |mame
156 |Fortran90                          |gfortran                                              |mame
157 |Gambas script                      |gambas3-scripter, gambas3-gb-pcre                     |mame
158 |GAP                                |gap                                                   |mame
159 |GDB                                |gdb                                                   |mame
160 |GEL (Genius)                       |genius                                                |mame
161 |Gnuplot                            |gnuplot                                               |mame
162 |Go                                 |golang                                                |mame
163 |GolfScript                         |*bundled in vendor/*                                  |mame
164 |G-Portugol                         |gpt                                                   |mame
165 |Grass                              |*bundled in vendor/*                                  |mame
166 |Janet                              |`Janet v1.43.0 source build`                          |**this fork**
167 |Groovy                             |groovy                                                |mame
168 |Gzip                               |gzip                                                  |mame
169 |Io                                 |`Io 2019.05.22 source build`                          |**this fork**
170 |Haskell                            |ghc                                                   |mame
171 |Picat                              |`Picat 3.9#12 release`                                |**this fork**
172 |Haxe                               |haxe                                                  |mame
173 |CLIPS                              |clips                                                 |**this fork**
174 |Icon                               |icont, iconx                                          |mame
175 |INTERCAL                           |intercal                                              |mame
176 |Wren                               |`Wren CLI 0.4.0 source build`                         |**this fork**
177 |Jasmin                             |jasmin-sable                                          |mame
178 |PureScript                         |`npm install purescript@0.15.17`                      |**this fork**
179 |Elm                                |`npm install elm@0.19.1-6`                            |**this fork**
180 |Pyret                              |`npm install pyret-npm@0.1.29`                        |**this fork**
181 |ReScript                           |`npm install rescript@12.3.1`                         |**this fork**
182 |Wisp                               |`npm install wisp@0.13.0`                             |**this fork**
183 |Imba                               |`npm install imba@2.0.0-alpha.253`                    |**this fork**
184 |Dafny                              |`Dafny v4.11.0 release`                               |**this fork**
185 |Julia                              |`Julia 1.13.4 release`                                |**this fork**
186 |Maxima                             |maxima                                                |**this fork**
187 |Gri                                |gri                                                   |**this fork**
188 |UCBLogo                            |`UCBLogo 6.2.5 source tarball`                        |**this fork**
189 |Java                               |openjdk-25-jdk                                        |mame
190 |GNU Smalltalk                      |`GNU Smalltalk 3.2.5 source tarball`                  |**this fork**
191 |JavaScript                         |nodejs                                                |mame
192 |Jq                                 |jq                                                    |mame
193 |JSFuck                             |nodejs                                                |mame
194 |Kotlin                             |kotlin                                                |mame
195 |TXR                                |`TXR 302 source tarball`                              |**this fork**
196 |Gravity                            |`Gravity 0.9.9 source build`                          |**this fork**
197 |Klong                              |`Klong 20221212 source tarball`                       |**this fork**
198 |GSL (Generator Scripting Language) |generator-scripting-language                          |**this fork**
199 |Seed7                              |`Seed7 2026-07-11 source build`                       |**this fork**
200 |Curry                              |`PAKCS 3.9.0 + swi-prolog-nox`                        |**this fork**
201 |nesC                               |`nesC v1.4.0 source build`                            |**this fork**
202 |LLVM asm                           |llvm                                                  |mame
203 |REDUCE                             |`REDUCE 2026-03-08 (.deb)`                            |**this fork**
204 |LOLCODE                            |*bundled in vendor/*                                  |mame
205 |Lua                                |lua5.3                                                |mame
206 |Lisaac                             |`Ubuntu archive lisaac 0.39 (.deb)`                   |**this fork**
207 |eC                                 |`Ubuntu archive ecere-sdk 0.44.15 (.deb)`             |**this fork**
208 |CDuce                              |`Ubuntu archive cduce 0.6.0 (.deb)`                   |**this fork**
209 |A+                                 |`Ubuntu archive aplus-fsf 4.22.1 (.deb)`              |**this fork**
210 |M4                                 |m4                                                    |mame
211 |Makefile                           |make                                                  |mame
212 |MiniZinc                           |minizinc                                              |mame
213 |Modula-2                           |gm2                                                   |mame
214 |MSIL                               |mono-devel                                            |mame
215 |PHP                                |php-cli                                               |mame
216 |Piet                               |*bundled in vendor/*                                  |mame
217 |Mustache                           |ruby-mustache                                         |mame
218 |NASM                               |nasm                                                  |mame
219 |Neko                               |neko                                                  |mame
220 |Nickle                             |nickle                                                |mame
221 |Nim                                |nim                                                   |mame
222 |Objective-C                        |gobjc                                                 |mame
223 |OCaml                              |ocaml                                                 |mame
224 |Falcon                             |`Ubuntu archive falconpl 0.9.6.9 (.deb)`              |**this fork**
225 |Vala                               |valac                                                 |mame
226 |Velato                             |*bundled in vendor/*                                  |mame
227 |Coconut                            |`pip install coconut==3.2.0`                          |**this fork**
228 |Octave                             |octave                                                |mame
229 |Ook!                               |*bundled in vendor/*                                  |mame
230 |PARI/GP                            |pari-gp                                               |mame
231 |Gleam                              |`Gleam v1.19.2 release`                               |**this fork**
232 |Roc                                |`Roc alpha4-rolling release`                          |**this fork**
233 |Inko                               |`Inko v0.21.1 source build`                           |**this fork**
234 |Koka                               |`Koka v3.2.9 release`                                 |**this fork**
235 |Chapel                             |`Chapel 2.10.0 (.deb)`                                |**this fork**
236 |Pony                               |`ponyc 0.78.2 release`                                |**this fork**
237 |Odin                               |`Odin dev-2026-10 release`                            |**this fork**
238 |rep (librep)                       |rep                                                   |**this fork**
239 |Chicken Scheme                     |chicken-bin                                           |**this fork**
240 |Rockstar                           |`Rockstar v2.0.15 release`                            |**this fork**
241 |Chez Scheme                        |chezscheme                                            |**this fork**
242 |Parser 3                           |parser3-cgi                                           |mame
243 |Pascal                             |fp-compiler                                           |mame
244 |Perl 5                             |perl                                                  |mame
245 |Perl 6                             |rakudo                                                |mame
246 |Mercury                            |`Mercury 22.01.8 apt repository`                      |**this fork**
247 |Maude                              |maude                                                 |**this fork**
248 |Pike                               |pike8.0                                               |mame
249 |Logtalk                            |`Logtalk 3.102.0 (.deb)`                              |**this fork**
250 |PostScript                         |ghostscript                                           |mame
251 |Agda                               |agda                                                  |**this fork**
252 |Prolog                             |swi-prolog                                            |mame
253 |ACL2                               |acl2                                                  |**this fork**
254 |Promela (Spin)                     |spin                                                  |mame
255 |Rail                               |`TryItOnline/rail C++ build`                          |**this fork**
256 |Kipple                             |`cipple 0.2.1 C build`                                |**this fork**
257 |Beatnik                            |*bundled in vendor/*                                  |**this fork**
258 |Glass                              |*bundled in vendor/*                                  |**this fork**
259 |Taxi                               |`BigZaphod Taxi C++ build`                            |**this fork**
260 |Deadfish~                          |*bundled in vendor/*                                  |**this fork**
261 |Lout                               |`Basser Lout source build`                            |**this fork**
262 |Plain TeX                          |texlive-binaries                                      |**this fork**
263 |MetaPost                           |texlive-metapost                                      |**this fork**
264 |Inform 6                           |inform6-compiler                                      |**this fork**
265 |Ink                                |`Inklecate v1.2.1 release`                            |**this fork**
266 |TADS 3                             |`FrobTADS v2.0`                                       |**this fork**
267 |Uxntal                             |`Uxn uxnasm + uxncli C build`                         |**this fork**
268 |MMIX                               |`Knuth MMIXware source build`                         |**this fork**
269 |6502 asm                           |xa65                                                  |**this fork**
270 |ARM64 asm                          |gcc-aarch64-linux-gnu, qemu-user                      |**this fork**
271 |Z80 asm                            |z80asm                                                |**this fork**
272 |RISC-V asm                         |gcc-riscv64-linux-gnu, qemu-user                      |**this fork**
273 |BeanShell                          |bsh                                                   |mame
274 |Befunge                            |*bundled in vendor/*                                  |mame
275 |BLC8                               |*bundled in vendor/*                                  |mame
276 |Brainfuck                          |*bundled in vendor/*                                  |mame
277 |ksh                                |ksh                                                   |mame
278 |Lazy K                             |*bundled in vendor/*                                  |mame
279 |LiveScript                         |livescript                                            |mame
280 |Python                             |python3                                               |mame
281 |R                                  |r-base                                                |mame
282 |Ratfor                             |ratfor                                                |mame
283 |rc                                 |rc                                                    |mame
284 |REXX                               |regina-rexx                                           |mame

Languages marked *bundled in vendor/* have interpreters included in `vendor/`; see [`vendor/README`](vendor/README) for licenses and details.

## Frequently asked questions

### Q. Who made this?

A. The original 128-language relay, its uroboros code generator, and the core compression architecture are by [Yusuke Endoh (mame)](https://github.com/mame). This fork extends the relay from 128 to 284 steps (273 distinct languages), re-engineers the escaping/compression corridors to survive 284 layers, and documents the record rules. Built by [Drawn With Code](https://www.youtube.com/@DrawnWithCode).

### Q. How does a quine relay work?

A. mame explains the original design in ["The World of Obfuscated, Esoteric, Artistic Programming"](http://gihyo.jp/book/2015/978-4-7741-7643-7) (in Japanese), and [RELAY-284.md](RELAY-284.md) covers how this fork scales the loop to 284 steps.

### Q. Language XXX is missing!

A. Pull requests are welcome! Every added step must run on its real compiler or interpreter inside the Docker image and close the full loop with zero stand-ins. See [RECORDS.md](RECORDS.md).

### Q. The code does not fit on my screen!

A. [Here is the 1-pixel-per-bit bitmap of `QR.rb`][thumbnail].

[thumbnail]: thumbnail.png

### Q. How was the code generated?

A.

    $ cd src
    $ rake

`src/code-gen.rb` defines all 284 steps. `rake` rebuilds `QR.rb`, `Makefile`, `Dockerfile`, `LANGUAGES.md`, the CI workflow, and this `README.md`. `tools/langs_png.py` renders `langs.png`, and `src/thumbnail.png.gen.rb` renders `thumbnail.png`.

## History

### This fork

- **284 steps / 273 distinct languages, Ubuntu 26.04 (Nov 2026).** Extended from 151 to 284 steps across 21 language batches (systems, theorem provers, logic, array, CAS, JVM, JS-targeted, scripting, shells, historical languages, interactive fiction/typesetting, multi-ISA assembly, and esolangs).
- **151 steps / 143 distinct languages, Ubuntu 26.04 (Nov 13, 2026).** Published at [exacortex/quine-relay-151](https://github.com/exacortex/quine-relay-151).

### mame's Quine Relay

- **50 -> 64 -> 100 -> 128 languages (Ubuntu 13.04 through Ubuntu 26.04):** [mame/quine-relay](https://github.com/mame/quine-relay).

## License

The MIT License applies to all resources
*except* the files in the `vendor/` directory.

The files in the `vendor/` directory are from third-parties (or self-made esolang runners)
and are distributed under their respective licenses.
See [`vendor/README`](vendor/README) in detail.

---

The MIT License (MIT)

Copyright (c) 2013–2026 Yusuke Endoh (@mametter), @hirekoke
Copyright (c) 2026 Drawn With Code (@exacortex / @rasteia): the 156 steps and scale architecture added in this fork

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
