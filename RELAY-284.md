# Quine Relay — 284 steps / 273 distinct languages

A fork of Yusuke Endoh's (mame) [Quine Relay](https://github.com/mame/quine-relay), scaled from 128 steps (123 distinct languages) past our **256-distinct-language** goal to **284 steps (273 distinct Tier-1 languages)** — verified end-to-end from a clean Ubuntu 26.04 `Dockerfile` build in November 2026.

## Why 284 steps cannot be a naive splice

In a quine relay, every language wraps the entire remainder of the loop as data. Any step that expands its payload by a constant factor $k > 1$ (byte arrays, hex escapes, quote/backslash doubling) multiplies *every* outer step's input. Worse, mame's base relay contains **two backslash-doubling ladders**:

1. **Upper ladder (`Scilab` .. `Verilog`, steps ~61–75):** each escaping layer roughly doubles `\` and `"`.
2. **Middle ladder (`JSFuck` -> `Kotlin` -> `Gravity` -> …):** JavaScript AST/string encoding and shell/JVM wrappers compound growth and hit hard 16-bit/24-bit VM limits.

When we first merged all 21 individually-verified 6-language batches (`B01`–`B21`) onto the base relay (initial merge attempt), intermediate files exploded past **250+ MB** (`C++` alone reached **167 MB**, `B17` under `XSLT` reached **82.7 MB** by itself), crashing compilers, overflowing 64 KB JVM constant pools, exhausting 64 KB 8-bit CPU ROMs, and hitting V8's `Zone::Expand` AST limit.

## Key architectural techniques that brought 284 steps home

### 1. Zero-backslash Forth (`126 PARSE`) + chunked Fortran 90 subroutines
Base `Forth` used `S\" ...\"`, which escapes every `\` and `"` and feeds directly into `C++` -> `C` -> `Bash` -> `Ada` -> the upper ladder. Replacing `S\"` with tilde-delimited `126 PARSE ...~` (`0` backslashes, `14` quotes total, `<= 71` columns for fixed-form FORTRAN 77) and splitting Fortran 90 into 500-call subroutines (`s0..sN`) shrank the first merge's `CommonLisp..Clojure` **45×** (`35 MB -> 781 KB`, now **`655–659 KB`**) and `C++` **73×** (`167 MB -> 2.29 MB`, now **`1.97 MB`**).

### 2. 3-digit base-78 LZ78 in `Kotlin` + `TXR` relocation
At 284 steps, `JSFuck` (step 193) originally expanded a 3.28 MB `JavaScript` program into >200 MB of `[][(![]+[])...]` AST nodes, hitting V8's `Zone::Expand` out-of-memory ceiling. Moving `TXR` immediately after `Kotlin` and upgrading `Kotlin`'s compressor to a **3-digit base-78 LZ78 dictionary** (`q*78`, `/6084 = 78^2`, giving `78^3 = 474,552` codewords for `474,551` dictionary slots drawn from the 84-character ASCII window `42..125`) brought `QR.txrlisp` to **`1.91 MB`** and `QR.kt` down to **`269 KB`** (~9 seconds in Node/V8 for `JSFuck`).

### 3. Self-reading comment decoders (`Shakespeare`, `Boo`, `Curry`, and `SNOBOL4..BCPL`)
- **`Shakespeare` -> `S-Lang`:** Instead of generating 150+ MB of Elizabethan theatrical prose for `spl2c` + `gcc`, `QR.spl` is a genuine ~18 KB Shakespeare play whose characters speak a **342-byte S-Lang decoder** followed by ` #:` payload lines that S-Lang reads from its own `QR.sl` source file.
- **Historical front chain (`Ruby` -> `SNOBOL4` -> `Simula` -> `Oberon` -> `Euphoria` -> `ALGOL 60` -> `BCPL`):** Placed immediately after `Ruby`, each classic compiler compiles a tiny constant-size comment decoder (`~200–600 bytes` of code) that decodes the comment lines of its own source file, stepping smoothly down from **`52.4 MB`** (`QR.sno`) to **`10.4 MB`** (`BCPL`), feeding the **`9.41 -> 7.30 MB`** raw-string corridor.

### 4. Interleaved Re-Pair compression across 6 CPU/VM assemblies
Adjacent literal assemblers (`BYTE "..."` + `.byte N` per quote/newline) multiply assembly source size ~3–4.8× per step and overflow 64 KB address spaces on 8-bit CPUs (`6502` and `Z80`). Interleaving dictionary pair-compressing assemblers with literal assemblers (`Uxntal` -> `MMIX` -> `6502 asm` -> `ARM64 asm` -> `Z80 asm` -> `RISC-V asm`, with assembled ROMs `QR.o65 = 45.1 KB` and `QR.z80.bin = 32.0 KB`) and relocating `BeanShell -> Befunge -> BLC8 -> Brainfuck -> ksh -> Lazy K -> LiveScript` right after `RISC-V asm` (**`71.6 KB`** output, **`58.4 KB`** after `BeanShell..Brainfuck`) kept every ROM and stack well inside hardware bounds.

### 5. Official reference interpreters for esolangs & strict 3-per-family compliance
- **`Hexagony`, `Rail`, `Kipple`, `Taxi`, `Rockstar`:** Run directly on their canonical upstream interpreters (`m-ender/hexagony` using a zero-backslash `<`/`/`/`>` boustrophedon snake, Jonathon Duerig's C++ `TryItOnline/rail`, Jannis Harder's C `cipple` verified byte-for-byte against Rune Berge's `Kipple.jar`, `BigZaphod/Taxi`, and Dylan Beattie's `Rockstar v2.0.15`), while `Glass` and `Emmental` are verified byte-for-byte against Gregor Richards' `glass-0.12` C++ and Chris Pressey's `catseye/Emmental`.
- **Strict family cap (max 3):** `Gambit Scheme` from the intermediate 157 base was replaced by `Rockstar`, keeping Scheme at 3 implementations (`Scheme`, `Chicken Scheme`, `Chez Scheme`) and bringing the relay to **284 steps / 273 distinct Tier-1 languages** with zero family-cap exceptions.

### 6. Breaking 16-bit, 24-bit, and heap limits across 30+ compilers & VMs
- **JVM 64 KB `CONSTANT_Utf8` & method bytecode limits:** Chunked literals/methods in `Java`, `Groovy`, `Clojure`, `Jasmin`, `AspectJ` (`^N^` RLE), `ArnoldC` (`m0..mN` methods), `Fantom`, `Golo`, `Ballerina`, `Yeti`, `Gosu`, and `Frege`.
- **WebAssembly LEB128:** Upgraded WASM data-segment sizing from 2-byte to dynamic 4-byte LEB128 (supporting payloads up to 256 MB).
- **Lout 16-bit `SHORT_MAX`:** Paginated `QR.lout` into 40-line `@NP` pages so vertical galleys never overflow 32,767 internal units.
- **Compiler & runtime heaps/buffers:** Zero-allocation 50 MB LZ77 buffer in `C`, raised `Lazy K` `RDSTACK_SIZE` to `10,000,000`, `a68g --heap 512M` for `ALGOL 68`, `List.iter print_string` over chunked `%pstring` literals in `Rocq`, `${file >QR_m,...}` in GNU `Makefile` (bypassing `MAX_ARG_STRLEN`), and 200-statement subroutines in `Ratfor`.
- **Single-scope Ruby hygiene in `QR.rb`:** All `Code` expressions evaluate in one shared Ruby scope inside `QR.rb`; outer compressors that bind Ruby locals before evaluating `(PREV)` (`Java_`) were isolated from inner compressors (`Kotlin`'s `m00z..m00n` locals).

## The 21 language batches (`157 -> 284`)

| Theme | Languages added |
|---|---|
| **Base 151 & 157** | BASIC (bwBASIC), ChucK, dash, groff, Hy, Jsonnet, newLISP, NQP, PicoLisp, Racket, SQL (SQLite), xonsh, mksh, BusyBox ash, yash, Elvish, VHDL, Genie, XQuery, Koto, Macaulay2, Coconut, Anko, Tengo, Rhai, rep (librep), Chez Scheme, Chicken Scheme |
| **mame retirees + Seed7 (B01–B03)** | Maxima, GNU Smalltalk, UCBLogo, Gri, Julia, Dafny, A+, Boo, CDuce, Falcon, eC, Lisaac, Curry, nesC, Parrot asm (PASM), GSL, AspectC++ *(17 restored retirees)* + Seed7 *(new)* |
| **JVM & JS targets (B04–B05)** | Fantom, Frege, Golo, Gosu, Ballerina, Yeti, ReScript, PureScript, Elm, Imba, Pyret, Wisp |
| **Modern shells (B06)** | PowerShell, Nushell, Ion, YSH (Oils), Murex, Hush, es |
| **Modern systems (B07–B08)** | Zig, Odin, V, Hare, C3, Nelua, Pony, Chapel, Inko, Koka, Roc, Gleam |
| **Proof, logic & rules (B09–B10)** | Agda, Idris 2, Lean 4, Rocq, F*, ACL2, CLIPS, Picat, Mercury, Maude, Logtalk, Dart |
| **Array & CAS/math (B11–B12)** | J, K (ngn/k), BQN, Uiua, Nial, Klong, FriCAS, Singular, REDUCE, Frink, Mathics, Numbat |
| **Scripting (B13–B14)** | Janet, Io, Wren, Berry, Gravity, Umka, MoonScript, Teal, YueScript, Arturo, Ring, TXR |
| **Historical & paradigms (B15–B16)** | SNOBOL4, Simula, Oberon, Euphoria, ALGOL 60, BCPL, Pyth, Emmental, ArnoldC, LFE, Joy, Factor |
| **Typesetting & IF (B17)** | Lout, Plain TeX, MetaPost, Inform 6, Ink, TADS 3 |
| **Assembly & tiny VMs (B18)** | Uxntal, MMIX, 6502 asm, ARM64 asm, Z80 asm, RISC-V asm |
| **Esolangs & config (B19–B21)** | ><> (Fish), Hexagony, ///, CJam, Underload, Brain-Flak, Rail, Kipple, Beatnik, Glass, Taxi, Deadfish~, Rockstar, Nix, Pkl, CUE, Nickel, Starlark, Rego |

## Papers, Formal Proofs & Victory Lap

- **[VICTORY-LAP.md](VICTORY-LAP.md)** — Full engineering & mathematics showcase of the push from 128 to 284.
- **[paper/uroboros_284_paper.pdf](paper/uroboros_284_paper.pdf)** ([LaTeX source](paper/uroboros_284_paper.tex)) — Complete scientific paper with affine transfer-matrix dynamics, formal theorems, compiler ceiling taxonomy, and 284-step empirical telemetry.
- **[paper/payload-growth.md](paper/payload-growth.md)** — Concise technical note on loop telescoping, escape ladders, and front-heavy ratio ordering.
- **[proof/formal/](proof/formal/)** — Machine-checked constructive proofs in **Lean 4.35.0** and **Rocq 8.20.1 + `coqchk`** (`0 sorry`, `0 Admitted`, `0 axioms`).
- **[audit/AUDIT.md](audit/AUDIT.md)** & **[tools/verify_invariants.py](tools/verify_invariants.py)** — Independent upstream interpreter & CPU emulator audit + mechanical rulebook verifier.

## Credits & License

Original Quine Relay design, uroboros generator, and MIT license: **Yusuke Endoh (@mametter)** and contributors.
284-language extension, corridor architecture, and verification: **Drawn With Code (@exacortex / @rasteia)**, MIT license.
