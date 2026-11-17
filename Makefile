MAKEFLAGS += --no-print-directory

PATH := $(CURDIR)/vendor/local/bin:/usr/games:$(PATH)
CLASSPATH := .

find_any0 = $(firstword $(foreach x,$(1),$(if $(shell which $(x) 2>/dev/null),$(x),)))
check = $(if $(2),$(2),$(error $(1) interpreter not found!))
find_any = $(call check,$(1),$(call find_any0,$(2)))

JAVASCRIPT   := $(call find_any,JavaScript,nodejs node js)
SCHEME       := $(call find_any,Scheme,guile csi gosh)
GBS          := $(call find_any,Gambas script,gbs3 gbs2 gba3)
WASI_RUNTIME := $(call find_any,WASI runtime,wasmtime node)

ifeq ($(SCHEME),csi)
  SCHEME := csi -s
endif
ifeq ($(WASI_RUNTIME),node)
  WASI_RUNTIME := node --experimental-wasi-unstable-preview1 vendor/wasi-runtime.js
endif

.DELETE_ON_ERROR:

all: QR2.rb
	@echo
	@echo "#############"
	@echo "##  CHECK  ##"
	@echo "#############"
	@echo
	diff -s QR.rb QR2.rb

check: all
	@sha256sum --quiet -c SHA256SUMS

QR.sno: QR.rb
	@echo
	@echo "##########################"
	@echo "##  1: Ruby -> SNOBOL4  ##"
	@echo "##########################"
	@echo
	ruby QR.rb > QR.sno

QR.sim: QR.sno
	@echo
	@echo "############################"
	@echo "##  2: SNOBOL4 -> Simula  ##"
	@echo "############################"
	@echo
	snobol4 -b QR.sno > QR.sim

QR.obn: QR.sim
	@echo
	@echo "###########################"
	@echo "##  3: Simula -> Oberon  ##"
	@echo "###########################"
	@echo
	rm -f QR QR.c
	cim -q QR.sim >/dev/null 2>&1
	./QR > QR.obn
	rm -f QR QR.c

QR.ex: QR.obn
	@echo
	@echo "#############################"
	@echo "##  4: Oberon -> Euphoria  ##"
	@echo "#############################"
	@echo
	rm -rf QR .obnc
	obnc QR.obn >/dev/null
	./QR > QR.ex
	rm -rf QR .obnc

QR.alg: QR.ex
	@echo
	@echo "###############################"
	@echo "##  5: Euphoria -> ALGOL 60  ##"
	@echo "###############################"
	@echo
	eui QR.ex > QR.alg

QR.b: QR.alg
	@echo
	@echo "###########################"
	@echo "##  6: ALGOL 60 -> BCPL  ##"
	@echo "###########################"
	@echo
	marst QR.alg -o QR.alg.c
	gcc QR.alg.c -lalgol -lm -o QR
	./QR < QR.alg > QR.b
	rm -f QR QR.alg.c

QR.k.k: QR.b
	@echo
	@echo "############################"
	@echo "##  7: BCPL -> K (ngn/k)  ##"
	@echo "############################"
	@echo
	rm -f QR QR.out
	BCPLROOT=/opt/BCPL/cintcode BCPLPATH=/opt/BCPL/cintcode/cin64 BCPLHDRS=/opt/BCPL/cintcode/g BCPLSCRIPTS=/opt/BCPL/cintcode/s /opt/BCPL/cintcode/bin/cintsys64 -c 'bcpl QR.b to QR; QR' >/dev/null
	cat QR.out > QR.k.k
	rm -f QR QR.out

QR.bas: QR.k.k
	@echo
	@echo "#######################################"
	@echo "##  8: K (ngn/k) -> BASIC (bwBASIC)  ##"
	@echo "#######################################"
	@echo
	ngnk QR.k.k < /dev/null > QR.bas

QR.ck: QR.bas
	@echo
	@echo "###################################"
	@echo "##  9: BASIC (bwBASIC) -> ChucK  ##"
	@echo "###################################"
	@echo
	bwbasic QR.bas > /dev/null; cat QR.out > QR.ck

QR.dash: QR.ck
	@echo
	@echo "#########################"
	@echo "##  10: ChucK -> dash  ##"
	@echo "#########################"
	@echo
	chuck --silent QR.ck > QR.dash

QR.roff: QR.dash
	@echo
	@echo "#########################"
	@echo "##  11: dash -> groff  ##"
	@echo "#########################"
	@echo
	dash QR.dash > QR.roff

QR.hy: QR.roff
	@echo
	@echo "#######################"
	@echo "##  12: groff -> Hy  ##"
	@echo "#######################"
	@echo
	groff -z QR.roff 2> QR.hy

QR.jsonnet: QR.hy
	@echo
	@echo "#########################"
	@echo "##  13: Hy -> Jsonnet  ##"
	@echo "#########################"
	@echo
	hy QR.hy > QR.jsonnet

QR.nl: QR.jsonnet
	@echo
	@echo "##############################"
	@echo "##  14: Jsonnet -> newLISP  ##"
	@echo "##############################"
	@echo
	jsonnet -S QR.jsonnet > QR.nl

QR.nqp: QR.nl
	@echo
	@echo "##########################"
	@echo "##  15: newLISP -> NQP  ##"
	@echo "##########################"
	@echo
	newlisp -n QR.nl > QR.nqp

QR.l: QR.nqp
	@echo
	@echo "###########################"
	@echo "##  16: NQP -> PicoLisp  ##"
	@echo "###########################"
	@echo
	nqp QR.nqp > QR.l

QR.rkt: QR.l
	@echo
	@echo "##############################"
	@echo "##  17: PicoLisp -> Racket  ##"
	@echo "##############################"
	@echo
	pil QR.l > QR.rkt

QR.sql: QR.rkt
	@echo
	@echo "##################################"
	@echo "##  18: Racket -> SQL (SQLite)  ##"
	@echo "##################################"
	@echo
	racket QR.rkt > QR.sql

QR.cc: QR.sql
	@echo
	@echo "#####################################"
	@echo "##  19: SQL (SQLite) -> AspectC++  ##"
	@echo "#####################################"
	@echo
	sqlite3 < QR.sql > QR.cc

QR.pasm: QR.cc
	@echo
	@echo "##########################################"
	@echo "##  20: AspectC++ -> Parrot asm (PASM)  ##"
	@echo "##########################################"
	@echo
	ag++ --keywords -o QR QR.cc
	./QR > QR.pasm

QR.xsh: QR.pasm
	@echo
	@echo "######################################"
	@echo "##  21: Parrot asm (PASM) -> xonsh  ##"
	@echo "######################################"
	@echo
	parrot QR.pasm > QR.xsh

QR.mksh: QR.xsh
	@echo
	@echo "#########################"
	@echo "##  22: xonsh -> mksh  ##"
	@echo "#########################"
	@echo
	xonsh --no-rc QR.xsh > QR.mksh

QR.bbash: QR.mksh
	@echo
	@echo "###############################"
	@echo "##  23: mksh -> BusyBox ash  ##"
	@echo "###############################"
	@echo
	mksh QR.mksh > QR.bbash

QR.art: QR.bbash
	@echo
	@echo "#################################"
	@echo "##  24: BusyBox ash -> Arturo  ##"
	@echo "#################################"
	@echo
	busybox ash QR.bbash > QR.art

QR.yash: QR.art
	@echo
	@echo "##########################"
	@echo "##  25: Arturo -> yash  ##"
	@echo "##########################"
	@echo
	arturo QR.art < /dev/null > QR.yash

QR.yue: QR.yash
	@echo
	@echo "#############################"
	@echo "##  26: yash -> YueScript  ##"
	@echo "#############################"
	@echo
	ulimit -s unlimited && yash QR.yash > QR.yue

QR.elv: QR.yue
	@echo
	@echo "###############################"
	@echo "##  27: YueScript -> Elvish  ##"
	@echo "###############################"
	@echo
	yue -e QR.yue > QR.elv

QR_rocq.v: QR.elv
	@echo
	@echo "##########################"
	@echo "##  28: Elvish -> Rocq  ##"
	@echo "##########################"
	@echo
	elvish QR.elv > QR_rocq.v

QR.lean: QR_rocq.v
	@echo
	@echo "##########################"
	@echo "##  29: Rocq -> Lean 4  ##"
	@echo "##########################"
	@echo
	coqc QR_rocq.v
	printf 'module Pstring=struct let unsafe_of_string s=s end\n' | cat - QR_rocq.ml > QR_rocq_run.ml
	ocaml QR_rocq_run.ml > QR.lean
	rm -f QR_rocq.ml QR_rocq_run.ml QR_rocq.vo QR_rocq.vok QR_rocq.vos QR_rocq.glob

QR.idr: QR.lean
	@echo
	@echo "#############################"
	@echo "##  30: Lean 4 -> Idris 2  ##"
	@echo "#############################"
	@echo
	lean --run QR.lean > QR.idr

QR.vlang.v: QR.idr
	@echo
	@echo "########################"
	@echo "##  31: Idris 2 -> V  ##"
	@echo "########################"
	@echo
	idris2 --exec main QR.idr > QR.vlang.v

QR.ha: QR.vlang.v
	@echo
	@echo "#####################"
	@echo "##  32: V -> Hare  ##"
	@echo "#####################"
	@echo
	v run QR.vlang.v > QR.ha

QR.c3: QR.ha
	@echo
	@echo "######################"
	@echo "##  33: Hare -> C3  ##"
	@echo "######################"
	@echo
	hare build -q -o QR QR.ha
	./QR > QR.c3

QR.nelua: QR.c3
	@echo
	@echo "#######################"
	@echo "##  34: C3 -> Nelua  ##"
	@echo "#######################"
	@echo
	c3c compile QR.c3 -o QR
	./QR > QR.nelua

QR.zig: QR.nelua
	@echo
	@echo "########################"
	@echo "##  35: Nelua -> Zig  ##"
	@echo "########################"
	@echo
	nelua --no-cache QR.nelua > QR.zig

QR.ps1: QR.zig
	@echo
	@echo "#############################"
	@echo "##  36: Zig -> PowerShell  ##"
	@echo "#############################"
	@echo
	zig run QR.zig > QR.ps1

QR.nu: QR.ps1
	@echo
	@echo "#################################"
	@echo "##  37: PowerShell -> Nushell  ##"
	@echo "#################################"
	@echo
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 POWERSHELL_TELEMETRY_OPTOUT=1 pwsh -NoProfile -NonInteractive -File QR.ps1 > QR.nu

QR.ion: QR.nu
	@echo
	@echo "##########################"
	@echo "##  38: Nushell -> Ion  ##"
	@echo "##########################"
	@echo
	nu --no-config-file QR.nu > QR.ion

QR.ysh: QR.ion
	@echo
	@echo "######################"
	@echo "##  39: Ion -> YSH  ##"
	@echo "######################"
	@echo
	ion QR.ion > QR.ysh

QR.mx: QR.ysh
	@echo
	@echo "########################"
	@echo "##  40: YSH -> Murex  ##"
	@echo "########################"
	@echo
	ysh QR.ysh > QR.mx

QR.hsh: QR.mx
	@echo
	@echo "#########################"
	@echo "##  41: Murex -> Hush  ##"
	@echo "#########################"
	@echo
	murex QR.mx > QR.hsh

QR.es: QR.hsh
	@echo
	@echo "######################"
	@echo "##  42: Hush -> es  ##"
	@echo "######################"
	@echo
	hush QR.hsh > QR.es

QR.boo: QR.es
	@echo
	@echo "#####################"
	@echo "##  43: es -> Boo  ##"
	@echo "#####################"
	@echo
	es QR.es > QR.boo

QR.vhdl: QR.boo
	@echo
	@echo "#######################"
	@echo "##  44: Boo -> VHDL  ##"
	@echo "#######################"
	@echo
	booi QR.boo > QR.vhdl

QR.genie.gs: QR.vhdl
	@echo
	@echo "#########################"
	@echo "##  45: VHDL -> Genie  ##"
	@echo "#########################"
	@echo
	ghdl -a QR.vhdl
	ghdl -e qr
	ghdl -r qr > QR.genie.gs

QR.nix: QR.genie.gs
	@echo
	@echo "########################"
	@echo "##  46: Genie -> Nix  ##"
	@echo "########################"
	@echo
	valac QR.genie.gs
	./QR.genie > QR.nix

QR.xq: QR.nix
	@echo
	@echo "#########################"
	@echo "##  47: Nix -> XQuery  ##"
	@echo "#########################"
	@echo
	nix eval --extra-experimental-features nix-command --raw --file QR.nix > QR.xq

QR.pkl: QR.xq
	@echo
	@echo "#########################"
	@echo "##  48: XQuery -> Pkl  ##"
	@echo "#########################"
	@echo
	basex QR.xq > QR.pkl

QR.koto: QR.pkl
	@echo
	@echo "#######################"
	@echo "##  49: Pkl -> Koto  ##"
	@echo "#######################"
	@echo
	pkl eval QR.pkl > QR.koto

QR.cue: QR.koto
	@echo
	@echo "#######################"
	@echo "##  50: Koto -> CUE  ##"
	@echo "#######################"
	@echo
	koto QR.koto > QR.cue

QR.m2: QR.cue
	@echo
	@echo "############################"
	@echo "##  51: CUE -> Macaulay2  ##"
	@echo "############################"
	@echo
	cue export --out text -e o QR.cue > QR.m2

QR.dart: QR.m2
	@echo
	@echo "#############################"
	@echo "##  52: Macaulay2 -> Dart  ##"
	@echo "#############################"
	@echo
	M2 --script QR.m2 > QR.dart

QR.ank: QR.dart
	@echo
	@echo "########################"
	@echo "##  53: Dart -> Anko  ##"
	@echo "########################"
	@echo
	dart run QR.dart > QR.ank

QR.tengo: QR.ank
	@echo
	@echo "#########################"
	@echo "##  54: Anko -> Tengo  ##"
	@echo "#########################"
	@echo
	anko QR.ank > QR.tengo

QR.ncl: QR.tengo
	@echo
	@echo "###########################"
	@echo "##  55: Tengo -> Nickel  ##"
	@echo "###########################"
	@echo
	tengo QR.tengo > QR.ncl

QR.rhai: QR.ncl
	@echo
	@echo "##########################"
	@echo "##  56: Nickel -> Rhai  ##"
	@echo "##########################"
	@echo
	nickel export --format text QR.ncl > QR.rhai

QR.rs: QR.rhai
	@echo
	@echo "########################"
	@echo "##  57: Rhai -> Rust  ##"
	@echo "########################"
	@echo
	rhai-run QR.rhai > QR.rs

QR.scala: QR.rs
	@echo
	@echo "#########################"
	@echo "##  58: Rust -> Scala  ##"
	@echo "#########################"
	@echo
	rustc QR.rs
	./QR > QR.scala

QR.scm: QR.scala
	@echo
	@echo "###########################"
	@echo "##  59: Scala -> Scheme  ##"
	@echo "###########################"
	@echo
	scalac QR.scala
	scala QR > QR.scm

QR.sci: QR.scm
	@echo
	@echo "############################"
	@echo "##  60: Scheme -> Scilab  ##"
	@echo "############################"
	@echo
	$(SCHEME) QR.scm > QR.sci

QR.sed: QR.sci
	@echo
	@echo "#########################"
	@echo "##  61: Scilab -> sed  ##"
	@echo "#########################"
	@echo
	scilab-cli -nb -f QR.sci > QR.sed

QR.spl: QR.sed
	@echo
	@echo "##############################"
	@echo "##  62: sed -> Shakespeare  ##"
	@echo "##############################"
	@echo
	sed -E -f QR.sed QR.sed > QR.spl

QR.sl: QR.spl
	@echo
	@echo "#################################"
	@echo "##  63: Shakespeare -> S-Lang  ##"
	@echo "#################################"
	@echo
	spl2c < QR.spl > QR.spl.c
	gcc -z muldefs -o QR -I ./vendor/local/include -L ./vendor/local/lib QR.spl.c -lspl -lm
	./QR > QR.sl

QR.nut: QR.sl
	@echo
	@echo "##############################"
	@echo "##  64: S-Lang -> Squirrel  ##"
	@echo "##############################"
	@echo
	slsh QR.sl > QR.nut

QR.sml: QR.nut
	@echo
	@echo "###################################"
	@echo "##  65: Squirrel -> Standard ML  ##"
	@echo "###################################"
	@echo
	squirrel QR.nut > QR.sml

QR.sq: QR.sml
	@echo
	@echo "#################################"
	@echo "##  66: Standard ML -> Subleq  ##"
	@echo "#################################"
	@echo
	polyc -o QR QR.sml
	./QR > QR.sq

QR.ss: QR.sq
	@echo
	@echo "#################################"
	@echo "##  67: Subleq -> SurgeScript  ##"
	@echo "#################################"
	@echo
	ruby vendor/subleq.rb QR.sq > QR.ss

QR.swift: QR.ss
	@echo
	@echo "################################"
	@echo "##  68: SurgeScript -> Swift  ##"
	@echo "################################"
	@echo
	surgescript QR.ss > QR.swift

QR.tcl: QR.swift
	@echo
	@echo "########################"
	@echo "##  69: Swift -> Tcl  ##"
	@echo "########################"
	@echo
	swiftc QR.swift
	./QR > QR.tcl

QR.tcsh: QR.tcl
	@echo
	@echo "#######################"
	@echo "##  70: Tcl -> tcsh  ##"
	@echo "#######################"
	@echo
	tclsh QR.tcl > QR.tcsh

QR.t: QR.tcsh
	@echo
	@echo "########################"
	@echo "##  71: tcsh -> Thue  ##"
	@echo "########################"
	@echo
	tcsh QR.tcsh > QR.t

QR.ts: QR.t
	@echo
	@echo "##############################"
	@echo "##  72: Thue -> TypeScript  ##"
	@echo "##############################"
	@echo
	ruby vendor/thue.rb QR.t > QR.ts

QR.unl: QR.ts
	@echo
	@echo "##################################"
	@echo "##  73: TypeScript -> Unlambda  ##"
	@echo "##################################"
	@echo
	tsc --outFile QR.ts.js QR.ts
	$(JAVASCRIPT) QR.ts.js > QR.unl

QR.v: QR.unl
	@echo
	@echo "###############################"
	@echo "##  74: Unlambda -> Verilog  ##"
	@echo "###############################"
	@echo
	ruby vendor/unlambda.rb QR.unl > QR.v

QR.fish.fish: QR.v
	@echo
	@echo "#################################"
	@echo "##  75: Verilog -> ><> (Fish)  ##"
	@echo "#################################"
	@echo
	iverilog -o QR QR.v
	./QR -vcd-none > QR.fish.fish

QR.hxg: QR.fish.fish
	@echo
	@echo "##################################"
	@echo "##  76: ><> (Fish) -> Hexagony  ##"
	@echo "##################################"
	@echo
	python3 vendor/fish.py QR.fish.fish > QR.hxg

QR.vim: QR.hxg
	@echo
	@echo "#################################"
	@echo "##  77: Hexagony -> Vimscript  ##"
	@echo "#################################"
	@echo
	ruby vendor/hexagony.rb QR.hxg > QR.vim

QR.vb: QR.vim
	@echo
	@echo "#####################################"
	@echo "##  78: Vimscript -> Visual Basic  ##"
	@echo "#####################################"
	@echo
	vim -EsS QR.vim > QR.vb

QR.wasm: QR.vb
	@echo
	@echo "#######################################################"
	@echo "##  79: Visual Basic -> WebAssembly (Binary format)  ##"
	@echo "#######################################################"
	@echo
	echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.vb" /></ItemGroup></Project>' > tmp.vbproj
	DOTNET_NOLOGO=1 dotnet run --project tmp.vbproj > QR.wasm

QR.wat: QR.wasm
	@echo
	@echo "####################################################################"
	@echo "##  80: WebAssembly (Binary format) -> WebAssembly (Text format)  ##"
	@echo "####################################################################"
	@echo
	$(WASI_RUNTIME) QR.wasm > QR.wat

QR.ws: QR.wat
	@echo
	@echo "###################################################"
	@echo "##  81: WebAssembly (Text format) -> Whitespace  ##"
	@echo "###################################################"
	@echo
	wat2wasm QR.wat -o QR.wat.wasm
	$(WASI_RUNTIME) QR.wat.wasm > QR.ws

QR.xslt: QR.ws
	@echo
	@echo "##############################"
	@echo "##  82: Whitespace -> XSLT  ##"
	@echo "##############################"
	@echo
	ruby vendor/whitespace.rb QR.ws > QR.xslt

QR.slashes: QR.xslt
	@echo
	@echo "#######################"
	@echo "##  83: XSLT -> ///  ##"
	@echo "#######################"
	@echo
	xsltproc QR.xslt > QR.slashes

QR.cjam: QR.slashes
	@echo
	@echo "#######################"
	@echo "##  84: /// -> CJam  ##"
	@echo "#######################"
	@echo
	ruby vendor/slashes.rb QR.slashes > QR.cjam

QR.ul: QR.cjam
	@echo
	@echo "#############################"
	@echo "##  85: CJam -> Underload  ##"
	@echo "#############################"
	@echo
	ruby vendor/cjam.rb QR.cjam > QR.ul

QR.bflk: QR.ul
	@echo
	@echo "###################################"
	@echo "##  86: Underload -> Brain-Flak  ##"
	@echo "###################################"
	@echo
	ruby vendor/underload.rb QR.ul > QR.bflk

QR.yab: QR.bflk
	@echo
	@echo "#################################"
	@echo "##  87: Brain-Flak -> Yabasic  ##"
	@echo "#################################"
	@echo
	ruby vendor/brain_flak.rb -A QR.bflk > QR.yab

QR.yorick: QR.yab
	@echo
	@echo "#############################"
	@echo "##  88: Yabasic -> Yorick  ##"
	@echo "#############################"
	@echo
	yabasic QR.yab > QR.yorick

QR.sing: QR.yorick
	@echo
	@echo "##############################"
	@echo "##  89: Yorick -> Singular  ##"
	@echo "##############################"
	@echo
	yorick -batch QR.yorick > QR.sing

QR.input: QR.sing
	@echo
	@echo "##############################"
	@echo "##  90: Singular -> FriCAS  ##"
	@echo "##############################"
	@echo
	Singular -q QR.sing > QR.input

QR.azm: QR.input
	@echo
	@echo "##########################"
	@echo "##  91: FriCAS -> Zoem  ##"
	@echo "##########################"
	@echo
	fricas -nosman < QR.input > /dev/null
	cat QR_fricas.out > QR.azm

QR.ndf: QR.azm
	@echo
	@echo "########################"
	@echo "##  92: Zoem -> Nial  ##"
	@echo "########################"
	@echo
	zoem -i QR.azm > QR.ndf

QR.zsh: QR.ndf
	@echo
	@echo "#######################"
	@echo "##  93: Nial -> zsh  ##"
	@echo "#######################"
	@echo
	nial -defs QR.ndf < /dev/null > QR.zsh

QR.ua: QR.zsh
	@echo
	@echo "#######################"
	@echo "##  94: zsh -> Uiua  ##"
	@echo "#######################"
	@echo
	zsh QR.zsh > QR.ua

QR.bqn: QR.ua
	@echo
	@echo "#######################"
	@echo "##  95: Uiua -> BQN  ##"
	@echo "#######################"
	@echo
	uiua run --no-format QR.ua > QR.bqn

QR.fan: QR.bqn
	@echo
	@echo "#########################"
	@echo "##  96: BQN -> Fantom  ##"
	@echo "#########################"
	@echo
	bqn QR.bqn > QR.fan

QR.golo: QR.fan
	@echo
	@echo "##########################"
	@echo "##  97: Fantom -> Golo  ##"
	@echo "##########################"
	@echo
	fan QR.fan > QR.golo

QR.bal: QR.golo
	@echo
	@echo "#############################"
	@echo "##  98: Golo -> Ballerina  ##"
	@echo "#############################"
	@echo
	golo golo --files QR.golo > QR.bal

QR.yeti: QR.bal
	@echo
	@echo "#############################"
	@echo "##  99: Ballerina -> Yeti  ##"
	@echo "#############################"
	@echo
	bal run --offline QR.bal > QR.yeti

QR.gsp: QR.yeti
	@echo
	@echo "#########################"
	@echo "##  100: Yeti -> Gosu  ##"
	@echo "#########################"
	@echo
	yeti QR.yeti > QR.gsp

QR.fr: QR.gsp
	@echo
	@echo "##########################"
	@echo "##  101: Gosu -> Frege  ##"
	@echo "##########################"
	@echo
	gosu QR.gsp > QR.fr

qr.adb: QR.fr
	@echo
	@echo "#########################"
	@echo "##  102: Frege -> Ada  ##"
	@echo "#########################"
	@echo
	mkdir -p frege-out
	frege -d frege-out QR.fr
	java -cp frege-out:/usr/local/lib/frege.jar QR > qr.adb

QR.als: qr.adb
	@echo
	@echo "#########################"
	@echo "##  103: Ada -> AFNIX  ##"
	@echo "#########################"
	@echo
	gnatmake qr.adb
	./qr > QR.als

QR.aheui: QR.als
	@echo
	@echo "###########################"
	@echo "##  104: AFNIX -> Aheui  ##"
	@echo "###########################"
	@echo
	LANG=C LD_LIBRARY_PATH=/usr/lib/afnix axi QR.als > QR.aheui

QR.ijs: QR.aheui
	@echo
	@echo "#######################"
	@echo "##  105: Aheui -> J  ##"
	@echo "#######################"
	@echo
	ruby vendor/aheui.rb QR.aheui > QR.ijs

QR.a68: QR.ijs
	@echo
	@echo "##########################"
	@echo "##  106: J -> ALGOL 68  ##"
	@echo "##########################"
	@echo
	ijconsole QR.ijs < /dev/null > QR.a68

QR.ante: QR.a68
	@echo
	@echo "#############################"
	@echo "##  107: ALGOL 68 -> Ante  ##"
	@echo "#############################"
	@echo
	a68g --heap 512M QR.a68 > QR.ante

QR.star: QR.ante
	@echo
	@echo "#############################"
	@echo "##  108: Ante -> Starlark  ##"
	@echo "#############################"
	@echo
	ruby vendor/ante.rb QR.ante > QR.star

QR.aj: QR.star
	@echo
	@echo "################################"
	@echo "##  109: Starlark -> AspectJ  ##"
	@echo "################################"
	@echo
	starlark QR.star 2> QR.aj

QR.tl: QR.aj
	@echo
	@echo "############################"
	@echo "##  110: AspectJ -> Teal  ##"
	@echo "############################"
	@echo
	ajc QR.aj
	java QR > QR.tl

QR.asy: QR.tl
	@echo
	@echo "##############################"
	@echo "##  111: Teal -> Asymptote  ##"
	@echo "##############################"
	@echo
	tl run QR.tl > QR.asy

QR.um: QR.asy
	@echo
	@echo "##############################"
	@echo "##  112: Asymptote -> Umka  ##"
	@echo "##############################"
	@echo
	asy QR.asy > QR.um

QR.fst: QR.um
	@echo
	@echo "#######################"
	@echo "##  113: Umka -> F*  ##"
	@echo "#######################"
	@echo
	umka QR.um > QR.fst

QR.dats: QR.fst
	@echo
	@echo "######################"
	@echo "##  114: F* -> ATS  ##"
	@echo "######################"
	@echo
	fstar.exe --cache_checked_modules --cache_dir fst_out QR.fst > /dev/null
	fstar.exe --cache_dir fst_out --odir fst_out --codegen OCaml --custard_main QR.main QR.fst > /dev/null
	ocaml fst_out/Custard.ml > QR.dats

QR.moon: QR.dats
	@echo
	@echo "##############################"
	@echo "##  115: ATS -> MoonScript  ##"
	@echo "##############################"
	@echo
	patscc -o QR QR.dats
	./QR > QR.moon

QR.awk: QR.moon
	@echo
	@echo "##############################"
	@echo "##  116: MoonScript -> Awk  ##"
	@echo "##############################"
	@echo
	moon QR.moon > QR.awk

QR.rego: QR.awk
	@echo
	@echo "########################"
	@echo "##  117: Awk -> Rego  ##"
	@echo "########################"
	@echo
	awk -f QR.awk > QR.rego

QR.wl: QR.rego
	@echo
	@echo "############################"
	@echo "##  118: Rego -> Mathics  ##"
	@echo "############################"
	@echo
	opa eval --format raw -d QR.rego data.qr.x > QR.wl

QR.bash: QR.wl
	@echo
	@echo "############################"
	@echo "##  119: Mathics -> bash  ##"
	@echo "############################"
	@echo
	mathics -q --no-completion -f QR.wl < /dev/null > QR.bash

QR.bc: QR.bash
	@echo
	@echo "#######################"
	@echo "##  120: bash -> bc  ##"
	@echo "#######################"
	@echo
	bash QR.bash > QR.bc

QR.be: QR.bc
	@echo
	@echo "########################"
	@echo "##  121: bc -> Berry  ##"
	@echo "########################"
	@echo
	BC_LINE_LENGTH=4000000 bc -q QR.bc > QR.be

QR.c: QR.be
	@echo
	@echo "#######################"
	@echo "##  122: Berry -> C  ##"
	@echo "#######################"
	@echo
	berry QR.be > QR.c

QR.cpp: QR.c
	@echo
	@echo "#####################"
	@echo "##  123: C -> C++  ##"
	@echo "#####################"
	@echo
	$(CC) -o QR QR.c
	./QR > QR.cpp

QR.pyth: QR.cpp
	@echo
	@echo "########################"
	@echo "##  124: C++ -> Pyth  ##"
	@echo "########################"
	@echo
	$(CXX) -o QR QR.cpp
	./QR > QR.pyth

QR.emmental: QR.pyth
	@echo
	@echo "#############################"
	@echo "##  125: Pyth -> Emmental  ##"
	@echo "#############################"
	@echo
	python3 /opt/pyth/pyth.py -n QR.pyth > QR.emmental

QR.arnoldc: QR.emmental
	@echo
	@echo "################################"
	@echo "##  126: Emmental -> ArnoldC  ##"
	@echo "################################"
	@echo
	ruby vendor/emmental.rb QR.emmental > QR.arnoldc

QR.lfe: QR.arnoldc
	@echo
	@echo "###########################"
	@echo "##  127: ArnoldC -> LFE  ##"
	@echo "###########################"
	@echo
	rm -f QR.class
	java -jar /opt/ArnoldC.jar QR.arnoldc
	java QR > QR.lfe
	rm -f QR.class

QR.joy: QR.lfe
	@echo
	@echo "#######################"
	@echo "##  128: LFE -> Joy  ##"
	@echo "#######################"
	@echo
	lfe QR.lfe > QR.joy

QR.factor: QR.joy
	@echo
	@echo "##########################"
	@echo "##  129: Joy -> Factor  ##"
	@echo "##########################"
	@echo
	joy QR.joy > QR.factor

QR.nbt: QR.factor
	@echo
	@echo "#############################"
	@echo "##  130: Factor -> Numbat  ##"
	@echo "#############################"
	@echo
	/opt/factor/factor QR.factor > QR.nbt

QR.cs: QR.nbt
	@echo
	@echo "#########################"
	@echo "##  131: Numbat -> C#  ##"
	@echo "#########################"
	@echo
	numbat QR.nbt > QR.cs

QR.chef: QR.cs
	@echo
	@echo "#######################"
	@echo "##  132: C# -> Chef  ##"
	@echo "#######################"
	@echo
	echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.cs" /></ItemGroup></Project>' > tmp.csproj
	DOTNET_NOLOGO=1 dotnet run --project tmp.csproj > QR.chef

QR.frink: QR.chef
	@echo
	@echo "##########################"
	@echo "##  133: Chef -> Frink  ##"
	@echo "##########################"
	@echo
	PERL5LIB=vendor/local/lib/perl5 compilechef QR.chef QR.chef.pl
	perl QR.chef.pl > QR.frink

QR.clj: QR.frink
	@echo
	@echo "#############################"
	@echo "##  134: Frink -> Clojure  ##"
	@echo "#############################"
	@echo
	java -cp /opt/frink/frink.jar frink.parser.Frink QR.frink > QR.clj

QR.cmake: QR.clj
	@echo
	@echo "#############################"
	@echo "##  135: Clojure -> CMake  ##"
	@echo "#############################"
	@echo
	clojure QR.clj > QR.cmake

QR.cob: QR.cmake
	@echo
	@echo "###########################"
	@echo "##  136: CMake -> Cobol  ##"
	@echo "###########################"
	@echo
	cmake -P QR.cmake > QR.cob

QR.ring: QR.cob
	@echo
	@echo "##########################"
	@echo "##  137: Cobol -> Ring  ##"
	@echo "##########################"
	@echo
	cobc -O2 -x QR.cob
	./QR > QR.ring

QR.coffee: QR.ring
	@echo
	@echo "#################################"
	@echo "##  138: Ring -> CoffeeScript  ##"
	@echo "#################################"
	@echo
	ring QR.ring > QR.coffee

QR.lisp: QR.coffee
	@echo
	@echo "########################################"
	@echo "##  139: CoffeeScript -> Common Lisp  ##"
	@echo "########################################"
	@echo
	coffee --nodejs --stack_size=100000 QR.coffee > QR.lisp

QR.cr: QR.lisp
	@echo
	@echo "###################################"
	@echo "##  140: Common Lisp -> Crystal  ##"
	@echo "###################################"
	@echo
	clisp QR.lisp > QR.cr

QR.d: QR.cr
	@echo
	@echo "#########################"
	@echo "##  141: Crystal -> D  ##"
	@echo "#########################"
	@echo
	crystal QR.cr > QR.d

QR.dc: QR.d
	@echo
	@echo "####################"
	@echo "##  142: D -> dc  ##"
	@echo "####################"
	@echo
	gdc -o QR QR.d
	./QR > QR.dc

QR.dhall: QR.dc
	@echo
	@echo "########################"
	@echo "##  143: dc -> Dhall  ##"
	@echo "########################"
	@echo
	dc QR.dc > QR.dhall || true

QR.exs: QR.dhall
	@echo
	@echo "############################"
	@echo "##  144: Dhall -> Elixir  ##"
	@echo "############################"
	@echo
	dhall text --file QR.dhall > QR.exs

QR.el: QR.exs
	@echo
	@echo "#################################"
	@echo "##  145: Elixir -> Emacs Lisp  ##"
	@echo "#################################"
	@echo
	elixir QR.exs > QR.el

QR.erl: QR.el
	@echo
	@echo "#################################"
	@echo "##  146: Emacs Lisp -> Erlang  ##"
	@echo "#################################"
	@echo
	emacs -Q --script QR.el > QR.erl

QR.e: QR.erl
	@echo
	@echo "###############################"
	@echo "##  147: Erlang -> Execline  ##"
	@echo "###############################"
	@echo
	escript QR.erl > QR.e

QR.fsx: QR.e
	@echo
	@echo "###########################"
	@echo "##  148: Execline -> F#  ##"
	@echo "###########################"
	@echo
	execlineb QR.e > QR.fsx

QR.false: QR.fsx
	@echo
	@echo "########################"
	@echo "##  149: F# -> FALSE  ##"
	@echo "########################"
	@echo
	echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><EnableDefaultCompileItems>false</EnableDefaultCompileItems></PropertyGroup><ItemGroup><Compile Include="QR.fsx" /></ItemGroup></Project>' > tmp.fsproj
	DOTNET_NOLOGO=1 dotnet run --project tmp.fsproj > QR.false

QR.fnl: QR.false
	@echo
	@echo "############################"
	@echo "##  150: FALSE -> Fennel  ##"
	@echo "############################"
	@echo
	ruby vendor/false.rb QR.false > QR.fnl

QR.fl: QR.fnl
	@echo
	@echo "###########################"
	@echo "##  151: Fennel -> Flex  ##"
	@echo "###########################"
	@echo
	fennel QR.fnl > QR.fl

QR.fish: QR.fl
	@echo
	@echo "#########################"
	@echo "##  152: Flex -> Fish  ##"
	@echo "#########################"
	@echo
	flex -o QR.fl.c QR.fl
	gcc -o QR QR.fl.c
	./QR > QR.fish

QR.fs: QR.fish
	@echo
	@echo "##########################"
	@echo "##  153: Fish -> Forth  ##"
	@echo "##########################"
	@echo
	fish QR.fish > QR.fs

QR.f: QR.fs
	@echo
	@echo "###############################"
	@echo "##  154: Forth -> FORTRAN77  ##"
	@echo "###############################"
	@echo
	gforth QR.fs > QR.f

QR.f90: QR.f
	@echo
	@echo "###################################"
	@echo "##  155: FORTRAN77 -> Fortran90  ##"
	@echo "###################################"
	@echo
	@mv QR.c QR.c.bak
	gfortran -o QR QR.f
	./QR > QR.f90
	@mv QR.c.bak QR.c

QR.gbs: QR.f90
	@echo
	@echo "#######################################"
	@echo "##  156: Fortran90 -> Gambas script  ##"
	@echo "#######################################"
	@echo
	gfortran -o QR QR.f90
	./QR > QR.gbs

QR.g: QR.gbs
	@echo
	@echo "#################################"
	@echo "##  157: Gambas script -> GAP  ##"
	@echo "#################################"
	@echo
	$(GBS) QR.gbs > QR.g

QR.gdb: QR.g
	@echo
	@echo "#######################"
	@echo "##  158: GAP -> GDB  ##"
	@echo "#######################"
	@echo
	gap -q QR.g > QR.gdb

QR.gel: QR.gdb
	@echo
	@echo "################################"
	@echo "##  159: GDB -> GEL (Genius)  ##"
	@echo "################################"
	@echo
	gdb -q -x QR.gdb > QR.gel

QR.plt: QR.gel
	@echo
	@echo "####################################"
	@echo "##  160: GEL (Genius) -> Gnuplot  ##"
	@echo "####################################"
	@echo
	genius QR.gel > QR.plt

QR.go: QR.plt
	@echo
	@echo "##########################"
	@echo "##  161: Gnuplot -> Go  ##"
	@echo "##########################"
	@echo
	gnuplot QR.plt > QR.go

QR.gs: QR.go
	@echo
	@echo "#############################"
	@echo "##  162: Go -> GolfScript  ##"
	@echo "#############################"
	@echo
	go run QR.go > QR.gs

QR.gpt: QR.gs
	@echo
	@echo "#####################################"
	@echo "##  163: GolfScript -> G-Portugol  ##"
	@echo "#####################################"
	@echo
	ruby vendor/golfscript.rb QR.gs > QR.gpt

QR.grass: QR.gpt
	@echo
	@echo "################################"
	@echo "##  164: G-Portugol -> Grass  ##"
	@echo "################################"
	@echo
	mv QR.c QR.c.bak
	gpt -t QR.c QR.gpt
	gcc -o QR QR.c
	./QR > QR.grass
	mv QR.c.bak QR.c

QR.janet: QR.grass
	@echo
	@echo "###########################"
	@echo "##  165: Grass -> Janet  ##"
	@echo "###########################"
	@echo
	ruby vendor/grass.rb QR.grass > QR.janet

QR.groovy: QR.janet
	@echo
	@echo "############################"
	@echo "##  166: Janet -> Groovy  ##"
	@echo "############################"
	@echo
	janet QR.janet > QR.groovy

QR.gz: QR.groovy
	@echo
	@echo "###########################"
	@echo "##  167: Groovy -> Gzip  ##"
	@echo "###########################"
	@echo
	groovy QR.groovy > QR.gz

QR.io: QR.gz
	@echo
	@echo "#######################"
	@echo "##  168: Gzip -> Io  ##"
	@echo "#######################"
	@echo
	gzip -cd QR.gz > QR.io

QR.hs: QR.io
	@echo
	@echo "##########################"
	@echo "##  169: Io -> Haskell  ##"
	@echo "##########################"
	@echo
	io QR.io > QR.hs

QR.pi: QR.hs
	@echo
	@echo "#############################"
	@echo "##  170: Haskell -> Picat  ##"
	@echo "#############################"
	@echo
	rm -f QR.o
	ghc QR.hs
	./QR > QR.pi

QR.hx: QR.pi
	@echo
	@echo "##########################"
	@echo "##  171: Picat -> Haxe  ##"
	@echo "##########################"
	@echo
	picat QR.pi > QR.hx

QR.clp: QR.hx
	@echo
	@echo "##########################"
	@echo "##  172: Haxe -> CLIPS  ##"
	@echo "##########################"
	@echo
	haxe -main QR -neko QR.n
	neko QR.n > QR.clp

QR.icn: QR.clp
	@echo
	@echo "##########################"
	@echo "##  173: CLIPS -> Icon  ##"
	@echo "##########################"
	@echo
	clips -f2 QR.clp > QR.icn

QR.i: QR.icn
	@echo
	@echo "#############################"
	@echo "##  174: Icon -> INTERCAL  ##"
	@echo "#############################"
	@echo
	icont -s QR.icn
	./QR > QR.i

QR.wren: QR.i
	@echo
	@echo "#############################"
	@echo "##  175: INTERCAL -> Wren  ##"
	@echo "#############################"
	@echo
	@mv QR.c QR.c.bak
	ick -bfOc QR.i
	gcc -std=c99 -static QR.c -I /usr/include/ick-* -o QR -lick
	./QR > QR.wren
	@mv QR.c.bak QR.c

QR.j: QR.wren
	@echo
	@echo "###########################"
	@echo "##  176: Wren -> Jasmin  ##"
	@echo "###########################"
	@echo
	wren_cli QR.wren > QR.j

QR.purs: QR.j
	@echo
	@echo "#################################"
	@echo "##  177: Jasmin -> PureScript  ##"
	@echo "#################################"
	@echo
	jasmin QR.j
	java QR > QR.purs

QR.elm: QR.purs
	@echo
	@echo "##############################"
	@echo "##  178: PureScript -> Elm  ##"
	@echo "##############################"
	@echo
	purs compile -o /opt/purs/out QR.purs '/opt/purs/lib/*/src/**/*.purs'
	node /opt/purs/run.mjs > QR.elm

QR.arr: QR.elm
	@echo
	@echo "#########################"
	@echo "##  179: Elm -> Pyret  ##"
	@echo "#########################"
	@echo
	cp QR.elm /opt/elm/src/QR.elm
	cd /opt/elm; elm make src/QR.elm --output=/usr/local/share/quine-relay/QR.elm.js
	node -e 'require("./QR.elm.js").Elm.QR.init().ports.o.subscribe(s=>process.stdout.write(s))' > QR.arr

QR.res: QR.arr
	@echo
	@echo "##############################"
	@echo "##  180: Pyret -> ReScript  ##"
	@echo "##############################"
	@echo
	pyretc QR.arr QR.jarr
	NODE_PATH=/opt/b05/node_modules node QR.jarr > QR.res

QR.wisp: QR.res
	@echo
	@echo "#############################"
	@echo "##  181: ReScript -> Wisp  ##"
	@echo "#############################"
	@echo
	bsc QR.res > QR.res.js
	node QR.res.js > QR.wisp

QR.imba: QR.wisp
	@echo
	@echo "#########################"
	@echo "##  182: Wisp -> Imba  ##"
	@echo "#########################"
	@echo
	wisp < QR.wisp > QR.wisp.js
	node QR.wisp.js > QR.imba

QR.dfy: QR.imba
	@echo
	@echo "##########################"
	@echo "##  183: Imba -> Dafny  ##"
	@echo "##########################"
	@echo
	imba QR.imba > QR.dfy

QR.jl: QR.dfy
	@echo
	@echo "###########################"
	@echo "##  184: Dafny -> Julia  ##"
	@echo "###########################"
	@echo
	dafny build -o dafny-out/QR QR.dfy
	DOTNET_ROLL_FORWARD=Major dotnet dafny-out/QR.dll > QR.jl

QR.mac: QR.jl
	@echo
	@echo "############################"
	@echo "##  185: Julia -> Maxima  ##"
	@echo "############################"
	@echo
	julia QR.jl > QR.mac

QR.gri: QR.mac
	@echo
	@echo "##########################"
	@echo "##  186: Maxima -> Gri  ##"
	@echo "##########################"
	@echo
	maxima -q --init-mac=QR.mac > QR.gri

QR.logo: QR.gri
	@echo
	@echo "###########################"
	@echo "##  187: Gri -> UCBLogo  ##"
	@echo "###########################"
	@echo
	gri QR.gri > QR.logo

QR.java: QR.logo
	@echo
	@echo "############################"
	@echo "##  188: UCBLogo -> Java  ##"
	@echo "############################"
	@echo
	ucblogo QR.logo > QR.java

QR.st: QR.java
	@echo
	@echo "##################################"
	@echo "##  189: Java -> GNU Smalltalk  ##"
	@echo "##################################"
	@echo
	javac QR.java
	java QR > QR.st

QR.js: QR.st
	@echo
	@echo "########################################"
	@echo "##  190: GNU Smalltalk -> JavaScript  ##"
	@echo "########################################"
	@echo
	gst QR.st > QR.js

QR.jq: QR.js
	@echo
	@echo "#############################"
	@echo "##  191: JavaScript -> Jq  ##"
	@echo "#############################"
	@echo
	$(JAVASCRIPT) QR.js > QR.jq

QR.jsfuck: QR.jq
	@echo
	@echo "#########################"
	@echo "##  192: Jq -> JSFuck  ##"
	@echo "#########################"
	@echo
	jq -r -n -f QR.jq > QR.jsfuck

QR.kt: QR.jsfuck
	@echo
	@echo "#############################"
	@echo "##  193: JSFuck -> Kotlin  ##"
	@echo "#############################"
	@echo
	ulimit -s unlimited && $(JAVASCRIPT) --stack_size=100000 QR.jsfuck > QR.kt

QR.txrlisp: QR.kt
	@echo
	@echo "##########################"
	@echo "##  194: Kotlin -> TXR  ##"
	@echo "##########################"
	@echo
	kotlinc QR.kt -include-runtime -d QR.jar
	kotlin QR.jar > QR.txrlisp

QR.gravity: QR.txrlisp
	@echo
	@echo "###########################"
	@echo "##  195: TXR -> Gravity  ##"
	@echo "###########################"
	@echo
	txr --lisp QR.txrlisp > QR.gravity

QR.kg: QR.gravity
	@echo
	@echo "#############################"
	@echo "##  196: Gravity -> Klong  ##"
	@echo "#############################"
	@echo
	gravity -q QR.gravity > QR.kg

QR.gsl: QR.kg
	@echo
	@echo "########################################################"
	@echo "##  197: Klong -> GSL (Generator Scripting Language)  ##"
	@echo "########################################################"
	@echo
	kg QR.kg < /dev/null > QR.gsl

QR.sd7: QR.gsl
	@echo
	@echo "########################################################"
	@echo "##  198: GSL (Generator Scripting Language) -> Seed7  ##"
	@echo "########################################################"
	@echo
	gsl -q QR.gsl > QR.sd7

QR.curry: QR.sd7
	@echo
	@echo "###########################"
	@echo "##  199: Seed7 -> Curry  ##"
	@echo "###########################"
	@echo
	s7 -q QR.sd7 > QR.curry

QR.nc: QR.curry
	@echo
	@echo "##########################"
	@echo "##  200: Curry -> nesC  ##"
	@echo "##########################"
	@echo
	pakcs --nocypm :load QR.curry :save :quit
	./QR > QR.nc

QR.ll: QR.nc
	@echo
	@echo "#############################"
	@echo "##  201: nesC -> LLVM asm  ##"
	@echo "#############################"
	@echo
	nescc -gcc=gcc-14 -o QR QR.nc
	./QR > QR.ll

QR.red: QR.ll
	@echo
	@echo "###############################"
	@echo "##  202: LLVM asm -> REDUCE  ##"
	@echo "###############################"
	@echo
	@mv QR.bc QR.bc.bak
	llvm-as QR.ll
	lli QR.bc > QR.red
	@mv QR.bc.bak QR.bc

QR.lol: QR.red
	@echo
	@echo "##############################"
	@echo "##  203: REDUCE -> LOLCODE  ##"
	@echo "##############################"
	@echo
	redcsl -w -b < QR.red > /dev/null
	cat QR_reduce.out > QR.lol

QR.lua: QR.lol
	@echo
	@echo "###########################"
	@echo "##  204: LOLCODE -> Lua  ##"
	@echo "###########################"
	@echo
	lci QR.lol > QR.lua

qr.li: QR.lua
	@echo
	@echo "##########################"
	@echo "##  205: Lua -> Lisaac  ##"
	@echo "##########################"
	@echo
	lua5.3 QR.lua > qr.li

QR_ec.ec: qr.li
	@echo
	@echo "#########################"
	@echo "##  206: Lisaac -> eC  ##"
	@echo "#########################"
	@echo
	lisaac -gcc -Wno-implicit-function-declaration qr.li > /dev/null
	./qr > QR_ec.ec

QR.cd: QR_ec.ec
	@echo
	@echo "########################"
	@echo "##  207: eC -> CDuce  ##"
	@echo "########################"
	@echo
	ecp -c QR_ec.ec -o QR_ec.sym
	ecc -c QR_ec.ec -o QR_ec.c
	ecs -console QR_ec.sym QR_ec.imp -o QR_ec.main.ec
	ecp -c QR_ec.main.ec -o QR_ec.main.sym
	ecc -c QR_ec.main.ec -o QR_ec.main.c
	gcc -std=gnu17 -w -o QR_ec QR_ec.c QR_ec.main.c -lecereCOM
	./QR_ec > QR.cd

QR.aplus.a: QR.cd
	@echo
	@echo "########################"
	@echo "##  208: CDuce -> A+  ##"
	@echo "########################"
	@echo
	cduce QR.cd > QR.aplus.a

QR.m4: QR.aplus.a
	@echo
	@echo "#####################"
	@echo "##  209: A+ -> M4  ##"
	@echo "#####################"
	@echo
	a+ QR.aplus.a > QR.m4 2> /dev/null < /dev/null

QR.mk: QR.m4
	@echo
	@echo "###########################"
	@echo "##  210: M4 -> Makefile  ##"
	@echo "###########################"
	@echo
	m4 QR.m4 > QR.mk

QR.mzn: QR.mk
	@echo
	@echo "#################################"
	@echo "##  211: Makefile -> MiniZinc  ##"
	@echo "#################################"
	@echo
	make -f QR.mk > QR.mzn

QR.mod: QR.mzn
	@echo
	@echo "#################################"
	@echo "##  212: MiniZinc -> Modula-2  ##"
	@echo "#################################"
	@echo
	minizinc --solver COIN-BC --soln-sep '' QR.mzn > QR.mod

QR.il: QR.mod
	@echo
	@echo "#############################"
	@echo "##  213: Modula-2 -> MSIL  ##"
	@echo "#############################"
	@echo
	gm2 -fiso QR.mod -o QR
	./QR > QR.il

QR.php: QR.il
	@echo
	@echo "########################"
	@echo "##  214: MSIL -> PHP  ##"
	@echo "########################"
	@echo
	ilasm QR.il
	mono QR.exe > QR.php

QR.png: QR.php
	@echo
	@echo "########################"
	@echo "##  215: PHP -> Piet  ##"
	@echo "########################"
	@echo
	php QR.php > QR.png

QR.mustache: QR.png
	@echo
	@echo "#############################"
	@echo "##  216: Piet -> Mustache  ##"
	@echo "#############################"
	@echo
	npiet QR.png > QR.mustache

QR.asm: QR.mustache
	@echo
	@echo "#############################"
	@echo "##  217: Mustache -> NASM  ##"
	@echo "#############################"
	@echo
	mustache QR.mustache QR.mustache > QR.asm

QR.neko: QR.asm
	@echo
	@echo "#########################"
	@echo "##  218: NASM -> Neko  ##"
	@echo "#########################"
	@echo
	nasm -felf QR.asm
	ld -m elf_i386 -o QR QR.o
	./QR > QR.neko

QR.5c: QR.neko
	@echo
	@echo "###########################"
	@echo "##  219: Neko -> Nickle  ##"
	@echo "###########################"
	@echo
	nekoc QR.neko
	neko QR.n > QR.5c

QR.nim: QR.5c
	@echo
	@echo "##########################"
	@echo "##  220: Nickle -> Nim  ##"
	@echo "##########################"
	@echo
	nickle QR.5c > QR.nim

QR.m: QR.nim
	@echo
	@echo "###############################"
	@echo "##  221: Nim -> Objective-C  ##"
	@echo "###############################"
	@echo
	nim compile QR.nim
	./QR > QR.m

QR.ml: QR.m
	@echo
	@echo "#################################"
	@echo "##  222: Objective-C -> OCaml  ##"
	@echo "#################################"
	@echo
	gcc -o QR QR.m
	./QR > QR.ml

QR.fal: QR.ml
	@echo
	@echo "############################"
	@echo "##  223: OCaml -> Falcon  ##"
	@echo "############################"
	@echo
	ocaml QR.ml > QR.fal

QR.vala: QR.fal
	@echo
	@echo "###########################"
	@echo "##  224: Falcon -> Vala  ##"
	@echo "###########################"
	@echo
	falcon QR.fal > QR.vala

QR.mid: QR.vala
	@echo
	@echo "###########################"
	@echo "##  225: Vala -> Velato  ##"
	@echo "###########################"
	@echo
	valac QR.vala
	./QR > QR.mid

QR.coco: QR.mid
	@echo
	@echo "##############################"
	@echo "##  226: Velato -> Coconut  ##"
	@echo "##############################"
	@echo
	mono vendor/local/bin/Vlt.exe /s QR.mid
	mono QR.exe > QR.coco

QR.octave: QR.coco
	@echo
	@echo "##############################"
	@echo "##  227: Coconut -> Octave  ##"
	@echo "##############################"
	@echo
	coconut -q -r QR.coco > QR.octave

QR.ook: QR.octave
	@echo
	@echo "###########################"
	@echo "##  228: Octave -> Ook!  ##"
	@echo "###########################"
	@echo
	mv QR.m QR.m.bak
	octave -qf QR.octave > QR.ook
	mv QR.m.bak QR.m

QR.gp: QR.ook
	@echo
	@echo "############################"
	@echo "##  229: Ook! -> PARI/GP  ##"
	@echo "############################"
	@echo
	ruby vendor/ook-to-bf.rb QR.ook QR.ook.bf
	ruby vendor/bf.rb QR.ook.bf > QR.gp

QR.gleam: QR.gp
	@echo
	@echo "#############################"
	@echo "##  230: PARI/GP -> Gleam  ##"
	@echo "#############################"
	@echo
	gp -f -q QR.gp > QR.gleam

QR.roc: QR.gleam
	@echo
	@echo "#########################"
	@echo "##  231: Gleam -> Roc  ##"
	@echo "#########################"
	@echo
	mkdir -p qrgleam/src
	cp QR.gleam qrgleam/src/qr.gleam
	printf 'name = "qr"\nversion = "1.0.0"\n' > qrgleam/gleam.toml
	(cd qrgleam; gleam run --no-print-progress) > QR.roc

QR.inko: QR.roc
	@echo
	@echo "########################"
	@echo "##  232: Roc -> Inko  ##"
	@echo "########################"
	@echo
	roc build --output qrroc QR.roc
	./qrroc > QR.inko

qr.kk: QR.inko
	@echo
	@echo "#########################"
	@echo "##  233: Inko -> Koka  ##"
	@echo "#########################"
	@echo
	inko run QR.inko > qr.kk

QR.chpl: qr.kk
	@echo
	@echo "###########################"
	@echo "##  234: Koka -> Chapel  ##"
	@echo "###########################"
	@echo
	koka -v0 -o qrkoka qr.kk
	chmod +x qrkoka
	./qrkoka > QR.chpl

QR.pony: QR.chpl
	@echo
	@echo "###########################"
	@echo "##  235: Chapel -> Pony  ##"
	@echo "###########################"
	@echo
	chpl -o qrchpl QR.chpl
	./qrchpl > QR.pony

QR.odin: QR.pony
	@echo
	@echo "#########################"
	@echo "##  236: Pony -> Odin  ##"
	@echo "#########################"
	@echo
	mkdir -p qrpony
	cp QR.pony qrpony/main.pony
	ponyc -V0 -b qrpony.out -o . qrpony
	./qrpony.out > QR.odin

QR.rep: QR.odin
	@echo
	@echo "#################################"
	@echo "##  237: Odin -> rep (librep)  ##"
	@echo "#################################"
	@echo
	odin run QR.odin -file > QR.rep

QR.gambit.scm: QR.rep
	@echo
	@echo "##########################################"
	@echo "##  238: rep (librep) -> Gambit Scheme  ##"
	@echo "##########################################"
	@echo
	rep QR.rep > QR.gambit.scm

QR.chicken.scm: QR.gambit.scm
	@echo
	@echo "############################################"
	@echo "##  239: Gambit Scheme -> Chicken Scheme  ##"
	@echo "############################################"
	@echo
	gsi QR.gambit.scm > QR.chicken.scm

QR.chez.ss: QR.chicken.scm
	@echo
	@echo "##########################################"
	@echo "##  240: Chicken Scheme -> Chez Scheme  ##"
	@echo "##########################################"
	@echo
	csi -q -s QR.chicken.scm > QR.chez.ss

QR.p: QR.chez.ss
	@echo
	@echo "####################################"
	@echo "##  241: Chez Scheme -> Parser 3  ##"
	@echo "####################################"
	@echo
	chezscheme --script QR.chez.ss > QR.p

QR.pas: QR.p
	@echo
	@echo "###############################"
	@echo "##  242: Parser 3 -> Pascal  ##"
	@echo "###############################"
	@echo
	parser3 QR.p > QR.pas

QR.pl: QR.pas
	@echo
	@echo "#############################"
	@echo "##  243: Pascal -> Perl 5  ##"
	@echo "#############################"
	@echo
	fpc QR.pas
	./QR > QR.pl

QR.pl6: QR.pl
	@echo
	@echo "#############################"
	@echo "##  244: Perl 5 -> Perl 6  ##"
	@echo "#############################"
	@echo
	perl QR.pl > QR.pl6

qr_mercury.m: QR.pl6
	@echo
	@echo "##############################"
	@echo "##  245: Perl 6 -> Mercury  ##"
	@echo "##############################"
	@echo
	perl6 QR.pl6 > qr_mercury.m

QR.maude: qr_mercury.m
	@echo
	@echo "#############################"
	@echo "##  246: Mercury -> Maude  ##"
	@echo "#############################"
	@echo
	mmc --make qr_mercury > /dev/null
	./qr_mercury > QR.maude

QR.pike: QR.maude
	@echo
	@echo "##########################"
	@echo "##  247: Maude -> Pike  ##"
	@echo "##########################"
	@echo
	maude -no-banner -no-advise -allow-files file QR.maude < /dev/null > /dev/null
	cat QR_maude.out > QR.pike

QR.lgt: QR.pike
	@echo
	@echo "############################"
	@echo "##  248: Pike -> Logtalk  ##"
	@echo "############################"
	@echo
	pike QR.pike > QR.lgt

QR.ps: QR.lgt
	@echo
	@echo "##################################"
	@echo "##  249: Logtalk -> PostScript  ##"
	@echo "##################################"
	@echo
	swilgt -q -g "logtalk_load('QR.lgt'),halt" < /dev/null > QR.ps

QR.agda: QR.ps
	@echo
	@echo "###############################"
	@echo "##  250: PostScript -> Agda  ##"
	@echo "###############################"
	@echo
	gs -dNODISPLAY -q QR.ps > QR.agda

QR.prolog: QR.agda
	@echo
	@echo "###########################"
	@echo "##  251: Agda -> Prolog  ##"
	@echo "###########################"
	@echo
	agda --compile --compile-dir=agda_out QR.agda > /dev/null
	./agda_out/QR > QR.prolog

QR.acl2: QR.prolog
	@echo
	@echo "###########################"
	@echo "##  252: Prolog -> ACL2  ##"
	@echo "###########################"
	@echo
	swipl -q -t qr -f QR.prolog > QR.acl2

QR.pr: QR.acl2
	@echo
	@echo "###################################"
	@echo "##  253: ACL2 -> Promela (Spin)  ##"
	@echo "###################################"
	@echo
	acl2 < QR.acl2 > /dev/null
	cat QR_acl2.out > QR.pr

QR.rail: QR.pr
	@echo
	@echo "###################################"
	@echo "##  254: Promela (Spin) -> Rail  ##"
	@echo "###################################"
	@echo
	spin -T QR.pr > QR.rail

QR.kpl: QR.rail
	@echo
	@echo "###########################"
	@echo "##  255: Rail -> Kipple  ##"
	@echo "###########################"
	@echo
	ruby vendor/rail.rb QR.rail > QR.kpl

QR.beatnik: QR.kpl
	@echo
	@echo "##############################"
	@echo "##  256: Kipple -> Beatnik  ##"
	@echo "##############################"
	@echo
	ruby vendor/kipple.rb QR.kpl > QR.beatnik

QR.glass: QR.beatnik
	@echo
	@echo "#############################"
	@echo "##  257: Beatnik -> Glass  ##"
	@echo "#############################"
	@echo
	ruby vendor/beatnik.rb QR.beatnik > QR.glass

QR.taxi: QR.glass
	@echo
	@echo "##########################"
	@echo "##  258: Glass -> Taxi  ##"
	@echo "##########################"
	@echo
	ruby vendor/glass.rb QR.glass > QR.taxi

QR.dft: QR.taxi
	@echo
	@echo "##############################"
	@echo "##  259: Taxi -> Deadfish~  ##"
	@echo "##############################"
	@echo
	taxi QR.taxi > QR.dft

QR.lout: QR.dft
	@echo
	@echo "##############################"
	@echo "##  260: Deadfish~ -> Lout  ##"
	@echo "##############################"
	@echo
	ruby vendor/deadfish_tilde.rb QR.dft > QR.lout

QR.tex: QR.lout
	@echo
	@echo "##############################"
	@echo "##  261: Lout -> Plain TeX  ##"
	@echo "##############################"
	@echo
	lout -s -p6p12p QR.lout 2>/dev/null | tr -d '\014' | grep . > QR.tex

QR.mp: QR.tex
	@echo
	@echo "##################################"
	@echo "##  262: Plain TeX -> MetaPost  ##"
	@echo "##################################"
	@echo
	rm -f QR.out QR.log
	tex -interaction=batchmode QR.tex >/dev/null
	cat QR.out > QR.mp
	rm -f QR.out QR.log

QR.inf: QR.mp
	@echo
	@echo "#################################"
	@echo "##  263: MetaPost -> Inform 6  ##"
	@echo "#################################"
	@echo
	rm -f QR.out QR.log
	mpost -interaction=batchmode QR.mp >/dev/null
	cat QR.out > QR.inf
	rm -f QR.out QR.log

QR.ink: QR.inf
	@echo
	@echo "############################"
	@echo "##  264: Inform 6 -> Ink  ##"
	@echo "############################"
	@echo
	rm -f QR.z8
	inform6 -v8 QR.inf QR.z8 >/dev/null
	dfrotz -m -q -r cm -w 240 -h 200 QR.z8 | tail -n +2 > QR.ink
	rm -f QR.z8

QR.t3.t: QR.ink
	@echo
	@echo "##########################"
	@echo "##  265: Ink -> TADS 3  ##"
	@echo "##########################"
	@echo
	inklecate -p QR.ink > QR.t3.t

QR.tal: QR.t3.t
	@echo
	@echo "#############################"
	@echo "##  266: TADS 3 -> Uxntal  ##"
	@echo "#############################"
	@echo
	rm -f QR.out QR.t3
	t3make -q -a -FI /usr/share/frobtads/tads3/include -FI /usr/local/share/frobtads/tads3/include -FL /usr/share/frobtads/tads3/lib -FL /usr/local/share/frobtads/tads3/lib -o QR.t3 system.tl QR.t3.t
	frob -i plain -p -s0 QR.t3 >/dev/null
	cat QR.out > QR.tal
	rm -f QR.out QR.t3

QR.mms: QR.tal
	@echo
	@echo "###########################"
	@echo "##  267: Uxntal -> MMIX  ##"
	@echo "###########################"
	@echo
	uxnasm QR.tal QR.rom
	uxncli QR.rom > QR.mms
	rm -f QR.rom

QR.s65: QR.mms
	@echo
	@echo "#############################"
	@echo "##  268: MMIX -> 6502 asm  ##"
	@echo "#############################"
	@echo
	mmixal -b 2000000 -o QR.mmo QR.mms
	mmix QR.mmo > QR.s65
	rm -f QR.mmo

QR.arm64.s: QR.s65
	@echo
	@echo "##################################"
	@echo "##  269: 6502 asm -> ARM64 asm  ##"
	@echo "##################################"
	@echo
	xa -o QR.o65 QR.s65
	python3 vendor/run6502.py QR.o65 > QR.arm64.s

QR.z80: QR.arm64.s
	@echo
	@echo "#################################"
	@echo "##  270: ARM64 asm -> Z80 asm  ##"
	@echo "#################################"
	@echo
	rm -f QR
	aarch64-linux-gnu-gcc -nostdlib -static -o QR QR.arm64.s
	qemu-aarch64 ./QR > QR.z80
	rm -f QR

QR.rv.s: QR.z80
	@echo
	@echo "##################################"
	@echo "##  271: Z80 asm -> RISC-V asm  ##"
	@echo "##################################"
	@echo
	z80asm QR.z80 -o QR.z80.bin
	python3 vendor/runz80.py QR.z80.bin > QR.rv.s

QR.bsh: QR.rv.s
	@echo
	@echo "####################################"
	@echo "##  272: RISC-V asm -> BeanShell  ##"
	@echo "####################################"
	@echo
	rm -f QR
	riscv64-linux-gnu-gcc -nostdlib -static -o QR QR.rv.s
	qemu-riscv64 ./QR > QR.bsh
	rm -f QR

QR.bef: QR.bsh
	@echo
	@echo "#################################"
	@echo "##  273: BeanShell -> Befunge  ##"
	@echo "#################################"
	@echo
	bsh QR.bsh > QR.bef
	-@stty echo

QR.Blc: QR.bef
	@echo
	@echo "############################"
	@echo "##  274: Befunge -> BLC8  ##"
	@echo "############################"
	@echo
	cfunge QR.bef > QR.Blc

QR.bf: QR.Blc
	@echo
	@echo "##############################"
	@echo "##  275: BLC8 -> Brainfuck  ##"
	@echo "##############################"
	@echo
	ruby vendor/blc.rb < QR.Blc > QR.bf

QR.ksh: QR.bf
	@echo
	@echo "#############################"
	@echo "##  276: Brainfuck -> ksh  ##"
	@echo "#############################"
	@echo
	ruby vendor/bf.rb QR.bf > QR.ksh

QR.lazy: QR.ksh
	@echo
	@echo "##########################"
	@echo "##  277: ksh -> Lazy K  ##"
	@echo "##########################"
	@echo
	ksh QR.ksh > QR.lazy

QR.ls: QR.lazy
	@echo
	@echo "#################################"
	@echo "##  278: Lazy K -> LiveScript  ##"
	@echo "#################################"
	@echo
	lazyk QR.lazy > QR.ls

QR.py: QR.ls
	@echo
	@echo "#################################"
	@echo "##  279: LiveScript -> Python  ##"
	@echo "#################################"
	@echo
	@mv QR.c QR.c.bak
	lsc QR.ls > QR.py
	@mv QR.c.bak QR.c

QR.R: QR.py
	@echo
	@echo "########################"
	@echo "##  280: Python -> R  ##"
	@echo "########################"
	@echo
	python3 QR.py > QR.R

QR.ratfor: QR.R
	@echo
	@echo "########################"
	@echo "##  281: R -> Ratfor  ##"
	@echo "########################"
	@echo
	R --slave -f QR.R > QR.ratfor

QR.rc: QR.ratfor
	@echo
	@echo "#########################"
	@echo "##  282: Ratfor -> rc  ##"
	@echo "#########################"
	@echo
	ratfor -o QR.ratfor.f QR.ratfor
	gfortran -o QR QR.ratfor.f
	./QR > QR.rc

QR.rexx: QR.rc
	@echo
	@echo "#######################"
	@echo "##  283: rc -> REXX  ##"
	@echo "#######################"
	@echo
	rc QR.rc > QR.rexx

QR2.rb: QR.rexx
	@echo
	@echo "#########################"
	@echo "##  284: REXX -> Ruby  ##"
	@echo "#########################"
	@echo
	rexx ./QR.rexx > QR2.rb

clean:
	@mv QR.rb quine-relay.rb
	rm -f qr QR qr.* QR.* QR2.rb *.class gst.im
	@mv quine-relay.rb QR.rb
