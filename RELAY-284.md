# Quine Relay — 284 steps / 272 distinct languages

A fork of Yusuke Endoh's (mame) [Quine Relay](https://github.com/mame/quine-relay), scaled from 128 steps (123 distinct languages) past our **256-distinct-language** goal to **284 steps (272 distinct Tier-1 languages)** — verified end-to-end in a single Ubuntu 26.04 Docker run on November 17, 2026.

## Why 284 steps cannot be a naive splice

In a quine relay, every language wraps the entire remainder of the loop as data. Any step that expands its payload by a constant factor $k > 1$ (byte arrays, hex escapes, quote/backslash doubling) multiplies *every* outer step's input. Worse, mame's base relay contains **two backslash-doubling ladders**:

1. **Upper ladder (`Scilab` .. `Verilog`, steps ~61–75):** each escaping layer roughly doubles `\` and `"`.
2. **Middle ladder (`JSFuck` -> `Kotlin` -> `Gravity` -> …):** JavaScript AST/string encoding and shell/JVM wrappers compound growth and hit hard 16-bit/24-bit VM limits.

When we first merged all 21 individually-verified 6-language batches (`B01`–`B21`) onto the 157-step base, intermediate files exploded past **250+ MB** (`C++` alone reached **167 MB**, `B17` under `XSLT` reached **82.7 MB** by itself), crashing compilers, overflowing 64 KB JVM constant pools, exhausting 64 KB 8-bit CPU ROMs, and hitting V8's `Zone::Expand` AST limit.

## Key architectural techniques that brought 284 steps home

### 1. Zero-backslash Forth (`126 PARSE`) + chunked Fortran 90 subroutines
Base `Forth` used `S\" ...\"`, which escapes every `\` and `"` and feeds directly into `C++` -> `C` -> `Bash` -> `Ada` -> the upper ladder. Replacing `S\"` with tilde-delimited `126 PARSE ...~` (`0` backslashes, `14` quotes total, `<= 71` columns for fixed-form FORTRAN 77) and splitting Fortran 90 into 500-call subroutines (`s0..sN`) shrank `CommonLisp..Clojure` **45×** (`35 MB -> 781 KB`) and `C++` **73×** (`167 MB -> 2.29 MB`).

### 2. 3-byte base-84 LZ78 in `Kotlin` + `TXR` relocation
At 284 steps, `JSFuck` (step 193) originally expanded a 3.28 MB `JavaScript` program into >200 MB of `[][(![]+[])...]` AST nodes, hitting V8's `Zone::Expand` out-of-memory ceiling. Moving `TXR` immediately after `Kotlin` and upgrading `Kotlin`'s compressor to a **3-byte base-84 LZ78 dictionary** (`84^3 = 592,704` codepoints, `474,551` dictionary slots) kept `QR.kt` at ~516 KB and `QR.jsfuck` at ~45 MB (~9 seconds in Node/V8).

### 3. Self-reading comment decoders (`Shakespeare`, `Boo`, `Curry`, and `SNOBOL4..BCPL`)
- **`Shakespeare` -> `S-Lang`:** Instead of generating 150+ MB of Elizabethan theatrical prose for `spl2c` + `gcc`, `QR.spl` is a genuine 18 KB Shakespeare play whose characters speak a **342-byte S-Lang decoder** followed by ` #:` payload lines that S-Lang reads from its own `QR.sl` source file.
- **Historical front chain (`Ruby` -> `SNOBOL4` -> `Simula` -> `Oberon` -> `Euphoria` -> `ALGOL 60` -> `BCPL`):** Placed immediately after `Ruby`, each classic compiler compiles a tiny constant-size comment decoder (`~200–600 bytes` of code) that decodes the comment lines of its own source file, stepping smoothly down from 54.7 MB to the 9.95 MB clean corridor.

### 4. Interleaved Re-Pair compression across 6 CPU/VM assemblies
Adjacent literal assemblers (`BYTE "..."` + `.byte N` per quote/newline) multiply assembly source size ~2.5× per step and overflow 64 KB address spaces on 8-bit CPUs (`6502` and `Z80`). Interleaving dictionary pair-compressing assemblers with literal assemblers (`Uxntal` -> `MMIX` -> `6502 asm` -> `ARM64 asm` -> `Z80 asm` -> `RISC-V asm`) and relocating `BeanShell -> Befunge -> BLC8 -> Brainfuck -> ksh -> Lazy K -> LiveScript` right after `RISC-V asm` (~55 KB payload) kept every ROM and stack well inside hardware bounds.

### 5. Breaking 16-bit, 24-bit, and heap limits across 30+ compilers & VMs
- **JVM 64 KB `CONSTANT_Utf8` & method bytecode limits:** Chunked literals/methods in `Java`, `Groovy`, `Clojure`, `Jasmin`, `AspectJ` (`^N^` RLE), `ArnoldC` (`m0..mN` methods), `Fantom`, `Golo`, `Ballerina`, `Yeti`, `Gosu`, and `Frege`.
- **WebAssembly LEB128:** Upgraded WASM data-segment sizing from 2-byte to dynamic 4-byte LEB128 (supporting payloads up to 256 MB).
- **Lout 16-bit `SHORT_MAX`:** Paginated `QR.lout` into 40-line `@NP` pages so vertical galleys never overflow 32,767 internal units.
- **Compiler & runtime heaps/buffers:** Zero-allocation 50 MB LZ77 buffer in `C`, raised `Lazy K` `RDSTACK_SIZE` to `10,000,000`, `a68g --heap 512M` for `ALGOL 68`, `List.iter print_string` over chunked `%pstring` literals in `Rocq`, `${file >QR_m,...}` in GNU `Makefile` (bypassing `MAX_ARG_STRLEN`), and 200-statement subroutines in `Ratfor`.
- **Single-scope Ruby hygiene in `QR.rb`:** All `Code` expressions evaluate in one shared Ruby scope inside `QR.rb`; outer compressors that bind Ruby locals before evaluating `(PREV)` (`Java_`) were isolated from inner compressors (`Kotlin`'s `m00z..m00n` locals).

## The 21 language batches (`157 -> 284`)

| Theme | Languages added |
|---|---|
| **Base 151 & 157** | BASIC (bwBASIC), ChucK, dash, groff, Hy, Jsonnet, newLISP, NQP, PicoLisp, Racket, SQL (SQLite), xonsh, mksh, BusyBox ash, yash, Elvish, VHDL, Genie, XQuery, Koto, Macaulay2, Coconut, Anko, Tengo, Rhai, rep (librep), Chez Scheme, Chicken Scheme, Gambit Scheme |
| **mame retirees (B01–B03)** | Maxima, GNU Smalltalk, UCBLogo, Gri, Julia, Dafny, A+, Boo, CDuce, Falcon, eC, Lisaac, Curry, nesC, Parrot asm (PASM), GSL, Seed7, AspectC++ |
| **JVM & JS targets (B04–B05)** | Fantom, Frege, Golo, Gosu, Ballerina, Yeti, ReScript, PureScript, Elm, Imba, Pyret, Wisp |
| **Modern shells (B06)** | PowerShell, Nushell, Ion, YSH (Oils), Murex, Hush, es |
| **Modern systems (B07–B08)** | Zig, Odin, V, Hare, C3, Nelua, Pony, Chapel, Inko, Koka, Roc, Gleam |
| **Proof, logic & rules (B09–B10)** | Agda, Idris 2, Lean 4, Rocq, F*, ACL2, CLIPS, Picat, Mercury, Maude, Logtalk, Dart |
| **Array & CAS/math (B11–B12)** | J, K (ngn/k), BQN, Uiua, Nial, Klong, FriCAS, Singular, REDUCE, Frink, Mathics, Numbat |
| **Scripting (B13–B14)** | Janet, Io, Wren, Berry, Gravity, Umka, MoonScript, Teal, YueScript, Arturo, Ring, TXR |
| **Historical & paradigms (B15–B16)** | SNOBOL4, Simula, Oberon, Euphoria, ALGOL 60, BCPL, Pyth, Emmental, ArnoldC, LFE, Joy, Factor |
| **Typesetting & IF (B17)** | Lout, Plain TeX, MetaPost, Inform 6, Ink, TADS 3 |
| **Assembly & tiny VMs (B18)** | Uxntal, MMIX, 6502 asm, ARM64 asm, Z80 asm, RISC-V asm |
| **Esolangs & config (B19–B21)** | ><> (Fish), Hexagony, ///, CJam, Underload, Brain-Flak, Rail, Kipple, Beatnik, Glass, Taxi, Deadfish~, Nix, Pkl, CUE, Nickel, Starlark, Rego |

## Credits & License

Original Quine Relay design, uroboros generator, and MIT license: **Yusuke Endoh (@mametter)** and contributors.
284-language extension, corridor architecture, and verification: **Drawn With Code (@exacortex / @rasteia)**, MIT license.
