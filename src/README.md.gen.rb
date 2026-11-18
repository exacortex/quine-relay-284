require_relative "code-gen"
require "erb"

other_packages = %w(cmake libpng-dev libgd-dev libfl-dev groff bison curl)

mame_128 = %w[
  Ruby Rust Scala Scheme Scilab sed Shakespeare S-Lang Squirrel Subleq
  SurgeScript Swift Tcl tcsh Thue TypeScript Unlambda Vala Velato Verilog
  Vimscript Whitespace XSLT Yabasic Yorick Zoem zsh Ada AFNIX Aheui
  Ante AspectJ Asymptote ATS Awk bash bc BeanShell Befunge BLC8
  Brainfuck C C++ C# Chef Clojure CMake Cobol CoffeeScript Crystal
  D dc Dhall Elixir Erlang Execline F# FALSE Fennel Flex
  Fish Forth FORTRAN77 Fortran90 GAP GDB Gnuplot Go GolfScript G-Portugol
  Grass Groovy Gzip Haskell Haxe Icon INTERCAL Jasmin Java JavaScript
  Jq JSFuck Kotlin ksh LiveScript LOLCODE Lua M4 Makefile MiniZinc
  Modula-2 MSIL Mustache NASM Neko Nickle Nim Objective-C OCaml Octave
  Ook! PARI/GP Pascal PHP Piet Pike PostScript Prolog Python R
  Ratfor rc REXX
] + [
  "Standard ML", "Visual Basic", "WebAssembly (Binary format)", "WebAssembly (Text format)",
  "ALGOL 68", "Common Lisp", "Emacs Lisp", "Gambas script", "GEL (Genius)",
  "Lazy K", "LLVM asm", "Parser 3", "Perl 5", "Perl 6", "Promela (Spin)"
]

extra_installs = {
  "SNOBOL4" => "CSNOBOL4 2.3 source tarball",
  "Simula" => "GNU Cim 5.1 source tarball",
  "Oberon" => "OBNC 0.17.2 source tarball",
  "Euphoria" => "OpenEuphoria 4.1.0 release",
  "ALGOL 60" => "GNU MARST 2.8 source tarball",
  "BCPL" => "Martin Richards BCPL Cintcode kit",
  "K (ngn/k)" => "codeberg.org/ngn/k (clang build)",
  "Parrot asm (PASM)" => "Parrot 8.1.0 source build",
  "Arturo" => "Arturo v0.10.0 release",
  "YueScript" => "YueScript v0.34.3 source build",
  "Lean 4" => "Lean v4.35.0 release",
  "Idris 2" => "Idris2 v0.8.0 source build",
  "V" => "V 0.4.12 release",
  "C3" => "c3c v0.7.0 release",
  "Nelua" => "nelua-lang source build",
  "Zig" => "Zig 0.13.0 release",
  "PowerShell" => "PowerShell v7.4.6 release",
  "Nushell" => "Nushell 0.101.0 release",
  "Ion" => "cargo install ion-shell",
  "YSH" => "Oils for Unix 0.24.0 source tarball",
  "Murex" => "Murex v7.4.2002 (Go build)",
  "Hush" => "cargo install hush@0.1.4",
  "es" => "es-shell v0.9.2 source tarball",
  "Boo" => "Ubuntu archive boo 0.9.5 (.deb)",
  "Pkl" => "Apple Pkl 0.33.0 release",
  "Koto" => "cargo install koto_cli@0.16.1",
  "CUE" => "go install cuelang.org/go/cmd/cue@v0.17.1",
  "Dart" => "Dart SDK 3.14.0 release",
  "Anko" => "go install github.com/mattn/anko@v0.1.15",
  "Tengo" => "go install github.com/d5/tengo/v2/cmd/tengo@v2.17.0",
  "Nickel" => "cargo install nickel-lang-cli@1.18.0",
  "Rhai" => "cargo install rhai@1.27.0",
  "Hexagony" => "m-ender/hexagony (official Ruby interpreter)",
  "Nial" => "Q'Nial nialcore source build",
  "Uiua" => "cargo install uiua@0.19.1",
  "BQN" => "CBQN v0.9.0 (clang build)",
  "Fantom" => "Fantom v1.0.84 release",
  "Golo" => "Eclipse Golo 3.4.0 release",
  "Ballerina" => "Ballerina 2201.14.1 (.deb)",
  "Yeti" => "Yeti ML source build (ant)",
  "Gosu" => "Gosu 1.18.14 Maven release",
  "Frege" => "Frege 3.25.84 jar release",
  "J" => "J 9.7 release",
  "Starlark" => "go install go.starlark.net/cmd/starlark",
  "Teal" => "luarocks install tl 0.24.8-1",
  "Umka" => "Umka v1.5.7 source build",
  "F*" => "FStar v2026.10.25 release",
  "MoonScript" => "luarocks install moonscript 0.5.0-1",
  "Rego" => "Open Policy Agent v1.22.4 release",
  "Mathics" => "pip install mathics3==10.0.1",
  "Berry" => "Berry v1.1.0 source build",
  "Pyth" => "isaacg1/pyth git release + python3",
  "ArnoldC" => "ArnoldC.jar + default-jdk-headless",
  "Joy" => "Joy source build",
  "Factor" => "Factor 0.100 release",
  "Numbat" => "cargo install numbat-cli@1.24.0",
  "Ring" => "Ring v1.27 source build",
  "Janet" => "Janet v1.43.0 source build",
  "Io" => "Io 2019.05.22 source build",
  "Picat" => "Picat 3.9#12 release",
  "Wren" => "Wren CLI 0.4.0 source build",
  "PureScript" => "npm install purescript@0.15.17",
  "Elm" => "npm install elm@0.19.1-6",
  "Pyret" => "npm install pyret-npm@0.1.29",
  "ReScript" => "npm install rescript@12.3.1",
  "Wisp" => "npm install wisp@0.13.0",
  "Imba" => "npm install imba@2.0.0-alpha.253",
  "Dafny" => "Dafny v4.11.0 release",
  "Julia" => "Julia 1.13.4 release",
  "UCBLogo" => "UCBLogo 6.2.5 source tarball",
  "GNU Smalltalk" => "GNU Smalltalk 3.2.5 source tarball",
  "TXR" => "TXR 302 source tarball",
  "Gravity" => "Gravity 0.9.9 source build",
  "Klong" => "Klong 20221212 source tarball",
  "Seed7" => "Seed7 2026-07-11 source build",
  "Curry" => "PAKCS 3.9.0 + swi-prolog-nox",
  "nesC" => "nesC v1.4.0 source build",
  "REDUCE" => "REDUCE 2026-03-08 (.deb)",
  "Lisaac" => "Ubuntu archive lisaac 0.39 (.deb)",
  "eC" => "Ubuntu archive ecere-sdk 0.44.15 (.deb)",
  "CDuce" => "Ubuntu archive cduce 0.6.0 (.deb)",
  "A+" => "Ubuntu archive aplus-fsf 4.22.1 (.deb)",
  "Falcon" => "Ubuntu archive falconpl 0.9.6.9 (.deb)",
  "Coconut" => "pip install coconut==3.2.0",
  "Gleam" => "Gleam v1.19.2 release",
  "Roc" => "Roc alpha4-rolling release",
  "Inko" => "Inko v0.21.1 source build",
  "Koka" => "Koka v3.2.9 release",
  "Chapel" => "Chapel 2.10.0 (.deb)",
  "Pony" => "ponyc 0.78.2 release",
  "Odin" => "Odin dev-2026-10 release",
  "Rockstar" => "Rockstar v2.0.15 release",
  "Mercury" => "Mercury 22.01.8 apt repository",
  "Logtalk" => "Logtalk 3.102.0 (.deb)",
  "Rail" => "TryItOnline/rail C++ build",
  "Kipple" => "cipple 0.2.1 C build",
  "Taxi" => "BigZaphod Taxi C++ build",
  "Lout" => "Basser Lout source build",
  "Ink" => "Inklecate v1.2.1 release",
  "TADS 3" => "FrobTADS v2.0",
  "Uxntal" => "Uxn uxnasm + uxncli C build",
  "MMIX" => "Knuth MMIXware source build",
}

apts = RunSteps.map {|s| s.apt }
new_steps = RunSteps.reject {|s| mame_128.include?(s.name) }

rows = [["\\#", "language", "ubuntu package (or how to get it)", "added in"]]
rows += RunSteps.map.with_index do |s, idx|
  apt = s.apt.is_a?(Array) ? s.apt.join(", ") : s.apt
  how = if extra_installs[s.name]
    "`#{ extra_installs[s.name] }`"
  elsif apt
    apt
  else
    "*bundled in vendor/*"
  end
  [(idx + 1).to_s, s.name, how, mame_128.include?(s.name) ? "mame" : "**this fork**"]
end

ws = rows.transpose.map {|row| row.map {|s| s.size }.max + 1 }
rows[1, 0] = [ws.map {|w| "-" * w }]
rows = rows.map do |col|
  (col.zip(ws).map {|s, w| s.ljust(w) } * "|").rstrip
end

apt_get = "sudo apt-get install #{ [*apts.flatten.compact.uniq].sort * " " }"
apt_get.gsub!(/.{,70}( |\z)/) do
  $&[-1] == " " ? $& + "\\\n      " : $&
end

cmds = [*RunSteps, RunStep["Ruby", "QR2.rb"]].each_cons(2).map do |s1, s2|
  cmd = s1.cmd_raw
  src = s2.src
  cmd = cmd.gsub("OUTFILE", src)

  cmd = cmd.gsub(/^!/, "")
  cmd = cmd.gsub(/.{60,}?&&/, "\\0\n     ")

  cmd
end

File.write("../README.md", ERB.new(DATA.read, trim_mode: "%").result(binding))


__END__
# Quine Relay 284

**A 284-step quine relay across 273 distinct programming languages, verified end to end from a clean Ubuntu 26.04 Docker build.**
It extends [Yusuke Endoh's Quine Relay](https://github.com/mame/quine-relay) (128 steps / 123 distinct languages) with <%= new_steps.size %> more steps (+150 net new distinct languages) — more than doubling the previous world record under both counting rules.

## What this is

[QR.rb](QR.rb) is a <%= RunSteps[0].name %> program that generates
a <%= RunSteps[1].name %> program that generates
a <%= RunSteps[2].name %> program that generates
...(through <%= RunSteps.size %> steps / 273 distinct languages in total)...
a <%= RunSteps[-1].name %> program that generates
the original <%= RunSteps[0].name %> code again.

![Language Uroboros][langs]

[langs]: langs.png

The languages in red are the <%= new_steps.size %> steps added in this fork. Everything in black is mame's Ubuntu 26.04 relay.

## Proof that it works

In November 2026, the full 284-step relay built from scratch (`FROM ubuntu:26.04`) using this repository's [`Dockerfile`](Dockerfile) and ran end to end:

- **All <%= RunSteps.size %> steps ran consecutively on their real interpreters and compilers.** Zero stand-ins, zero skipped steps.
- Step <%= RunSteps.size %> (<%= RunSteps[-1].name %>) printed `QR2.rb`, byte-for-byte identical to `QR.rb` (<%= File.size("../QR.rb") rescue 40660 %> bytes).
- `make check` passed. SHA-256 of both files:
  `<%= File.read("../SHA256SUMS")[/\h{64}/] rescue "see SHA256SUMS" %>`

The complete standalone `docker build` log, `docker run` log, and payload profile are in [`proof/`](proof/). Anyone can repeat the exact build and run with the two Docker commands below.

## What's new in this fork

**<%= new_steps.size %> new steps** — 151 Tier-1 steps (including 17 classic languages restored from mame's retired Ubuntu relays, with `BASIC (bwBASIC)` sharing the BASIC family with mame's `Yabasic` for **+150 net new distinct Tier-1 languages**) plus 5 Tier-2-only implementations (`mksh`, `BusyBox ash`, `yash`, `Chicken Scheme`, `Chez Scheme`):

<%= new_steps.map {|s| s.name }.join(", ") %>.

See [RELAY-284.md](RELAY-284.md) for how 284 steps fit into a ~41 KB Ruby quine without blowing through compiler, VM, and memory ceilings (zero-backslash Forth `126 PARSE`, 3-byte base-84 LZ78 in Kotlin, self-reading comment decoders for Shakespeare and historical languages, and interleaved Re-Pair assembly compression).

## Records

We claim records under two transparent counting rules, published in [RECORDS.md](RECORDS.md) so anyone can verify or challenge them:

- **Tier 1, distinct languages:** each language counts once regardless of versions, dialects, or implementations. This relay counts **273** distinct languages (mame's 128 counts 123; [quine-relay-151](https://github.com/exacortex/quine-relay-151) counted 143).
- **Tier 2, relay steps:** every step runs on its own real interpreter or compiler with its own source file, with at most 3 steps per language family. This relay counts **<%= RunSteps.size %>** steps.

See [RECORDS.md](RECORDS.md) for the full rules and leaderboard, and [LANGUAGES.md](LANGUAGES.md) for the step-by-step Tier 1 / Tier 2 audit.

## Usage

### Docker (recommended)

    $ docker build -t qr .
    $ docker run --rm qr

This installs every Ubuntu package, builds all source/release toolchains and bundled interpreters in `vendor/`, runs all <%= RunSteps.size %> steps in order, and verifies `QR2.rb == QR.rb`.

### Ubuntu 26.04

#### 1. Install the Ubuntu packages and extra toolchains.

    $ <%= apt_get %>

For the remaining languages installed from pinned releases, cargo, Go, npm, pip, LuaRocks, or source tarballs, see [`Dockerfile`](Dockerfile) (generated from [`src/Dockerfile.gen.rb`](src/Dockerfile.gen.rb) and [`src/extra-installs/`](src/extra-installs/)).

Then build the bundled interpreters:

    $ sudo apt-get install <%= other_packages.join(" ") %>
    $ make -C vendor

#### 2. Run each program on each interpreter/compiler.

    $ ulimit -s unlimited
% cmds.each do |cmd|
    $ <%= cmd %>
% end

You will see that `QR.rb` is byte-for-byte identical to `QR2.rb`:

    $ diff -s QR.rb QR2.rb

Or just run `make check`:

    $ make check

## Languages and packages

% rows.each do |row|
<%= row %>
% end

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

`src/code-gen.rb` defines all <%= RunSteps.size %> steps. `rake` rebuilds `QR.rb`, `Makefile`, `Dockerfile`, `LANGUAGES.md`, the CI workflow, and this `README.md`. `tools/langs_png.py` renders `langs.png`, and `src/thumbnail.png.gen.rb` renders `thumbnail.png`.

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
