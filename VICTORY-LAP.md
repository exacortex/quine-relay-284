# Victory Lap: Scaling Quine Relay to 284 Steps & 273 Distinct Languages

> **One 42,680-byte Ruby file (`QR.rb`) passes consecutively through 284 real compilers, assemblers, virtual machines, proof assistants, shells, typesetters, computer algebra systems, and esoteric interpreters — spanning 273 distinct Tier-1 languages — and prints itself back out, byte for byte (`9ce6dbe3...eb509a`).**

---

## 1. The Arc: From 128 -> 151 -> 157 -> The 250 MB Wall -> 284

Yusuke Endoh's ([`mame/quine-relay`](https://github.com/mame/quine-relay)) 128-step Uroboros quine stood as one of programming's great recreational landmarks since April 2018. In November 2026, we set out to cross **256 distinct languages** under strict, publicly auditable rules — keeping all 128 of Endoh's Ubuntu 26.04 steps intact, restoring 17 of the 20 languages Ubuntu had retired over the previous decade, and adding modern systems languages, interactive theorem provers, array languages, hardware ISAs, interactive-fiction engines, and canonical esolangs.

Our first milestones (`151` steps / `143` distinct languages, then `157` steps) fit comfortably inside Endoh's existing architecture (~3 MB peak corridor). To scale past 256, we partitioned 130+ candidate languages into **21 parallel 6-language batches (`B01`–`B21`)**, verifying each batch independently in Docker on top of the 157-step base.

Every single batch passed in isolation. Then we merged all 21 batches into one loop — and **everything exploded**:

- Intermediate source files blew past **250+ MB** (`C++` alone hit **167 MB**; `XSLT -> B17` hit **82.7 MB**; `Common Lisp..Clojure` hit **35 MB**).
- Node/V8 crashed with `Fatal process out of memory: Zone::Expand` parsing a >200 MB `JSFuck` AST.
- JVM compilers (`javac`, `groovyc`, `Clojure`, `Jasmin`, `Fantom`, `Ballerina`, `Gosu`, `Frege`, `ArnoldC`) shattered against the 16-bit `CONSTANT_Utf8` (`65,535` B) and method-bytecode (`65,535` B) classfile ceilings.
- `6502` and `Z80` assemblers overflowed their 16-bit **64 KB hardware address spaces**.
- Basser `Lout` overflowed its 16-bit signed galley coordinate (`SHORT_MAX = 32,767`), `PAKCS` (`Curry`) exhausted SWI-Prolog's heap at ~903 KB, GNU `make` tripped Linux's `MAX_ARG_STRLEN = 131,072` B `execve` ceiling, and `Lazy K` blew its combinator reduction stack.

Getting from a crashed 250 MB merge to a clean, reproducible **39-minute 37-second** 284-step lap (`1.14 GB` total group output, `94.5 MB` quarantined single-step peak, `7.30–9.41 MB` main corridor) required uncovering the **exact discrete mathematics of nested quoting** and re-architecting how code and data travel around a closed compiler loop.

---

## 2. The New Math We Uncovered (and Machine-Checked in `Lean 4` & `Rocq`)

Because **`Lean 4`** (step 30) and **`Rocq`** (step 29) are themselves compilers inside the relay, we formalized and machine-checked **seven core theorem suites** inside the `qr284` container itself using **Lean 4.35.0** and **Rocq 8.20.1 + `coqchk`** ([`proof/formal/`](proof/formal/), `0 sorry`, `0 Admitted`, `Axioms: <none>`).

### 2.1 The Eigen-Functional $\Phi = S + Q + 2$ and Conservation Law $\Psi = B - S$

Model a program's text by its state vector $(B, S, Q) \in \mathbb{N}^3$: byte length $B$, backslashes $S$, and double-quotes $Q$. Wrapping that text in a standard C/POSIX string literal ($`\` \mapsto `\\`$, $`"` \mapsto `\"`$, plus $w_0$ bytes of wrapper code including $2$ outer quotes) applies the affine operator:

$$\mathcal{E}_{w_0}(B, S, Q) = (B + S + Q + w_0,\; 2S + Q,\; Q + 2).$$

Although the homogeneous part is a non-normal Jordan shear-doubling block, two exact invariants diagonalize its behavior for all $k \ge 0$:

1. **Exponential Eigen-Doubling Law (`phi_iterEsc`):** Define $\Phi(S, Q) := S + Q + 2$. Under $\mathcal{E}_{w_0}$,
   $$\Phi(\mathcal{E}_{w_0}(B, S, Q)) = (2S + Q) + (Q + 2) + 2 = 2(S + Q + 2) = 2\Phi(S, Q) \implies \Phi_k = 2^k \Phi_0.$$
2. **Byte-Backslash Linear Conservation Law (`byte_bslash_conservation`):** Define $\Psi(B, S) := B - S$. Under $\mathcal{E}_{w_0}$,
   $$\Psi(\mathcal{E}_{w_0}(B, S, Q)) = (B + S + Q + w_0) - (2S + Q) = (B - S) + w_0 \implies B_k - S_k = B_0 - S_0 + k w_0.$$

Every single byte of exponential growth in $B_k$ is **1-for-1 identical** to $S_k - S_0$, regardless of $Q_0$! And across our real 284-step [`proof/zones.csv`](proof/zones.csv), real compilers obey this discrete dynamical system **to the exact single byte**:

| Ladder Slice (inner -> outer) | Measured $S_{\text{outer}}$ | Predicted $2 S_{\text{inner}} + Q_{\text{inner}} + d$ | Wrapper Conservation $\Delta(B - S) = w_0$ |
|---|---|---|---|
| **Upper Ladder:** `Swift -> SurgeScript` | `531,124` | `2(248,964) + 33,196 + 0 = 531,124` (**exact**) | `110,981` B (Subleq decimal expansion) |
| **Upper Ladder:** `SurgeScript -> Standard ML` | `1,108,674` | `2(531,124) + 46,426 + 0 = 1,108,674` (**exact**) | `133` B (`Standard ML` wrapper) |
| **Upper Ladder:** `Standard ML -> Squirrel` | `2,263,782` | `2(1,108,674) + 46,434 + 0 = 2,263,782` (**exact**) | `424,009` B (`S-Lang` dictionary code) |
| **Logic Ladder:** `Agda -> PostScript` | `6,798` | `2(2,939) + 920 + 0 = 6,798` (**exact**) | `292` B (`PostScript` wrapper) |
| **Logic Ladder:** `PostScript -> Logtalk` | `13,596` | `2(6,798) + 0 = 13,596` (**exact** — `PS` uses `(...)`!) | `12` B (`Logtalk` wrapper) |
| **Logic Ladder:** `Logtalk -> Pike` | `28,125` | `2(13,596) + 922 + 11 = 28,125` (**exact**, `11` `\n`s) | `82` B (`Pike` wrapper) |
| **Logic Ladder:** `Pike -> Maude` | `57,174` | `2(28,125) + 924 + 0 = 57,174` (**exact**) | `22` B (`Maude` wrapper) |
| **Logic Ladder:** `Maude -> Mercury` | `115,274` | `2(57,174) + 926 + 0 = 115,274` (**exact**) | `365` B (`Mercury` wrapper) |
| **Logic Ladder:** `Mercury -> Perl 6` | `231,480` | `2(115,274) + 932 + 0 = 231,480` (**exact**) | `151` B (`Perl 6` wrapper) |

*(Notice `PostScript -> Logtalk`: because PostScript strings use `(...)` delimiters instead of `"..."`, `PostScript` escapes `\` -> `\\` without escaping `"`, switching the recurrence cleanly from $2S + Q$ to $2S$!)*

### 2.2 The Zero-Residual Delimiter Reset Identity (Why `126 PARSE` Collapsed `C++` 73×)

What happens when we replace an escaping wrapper $\mathcal{E}_{w_0}$ at the bottom of a $k$-step ladder with a zero-backslash delimiter-parsed transducer $\mathcal{P}_{w_0, 2}(B, S, Q) = (B + w_0, 0, 2)$ (such as replacing Forth's `S\" ...\"` with tilde-delimited `126 PARSE ...~` plus chunked Fortran 90)?

When we first derived this by hand, we carried a $+ (2^{k+1} - 4)$ wrapper remainder. **Lean 4's `omega` solver rejected our remainder** and revealed a cleaner truth (`parse_reset_saves_exponential`): because $\Phi(0, 2) = 4$ matches the $+4$ constant in $\Phi(\mathcal{E}_{w_0}(s)) = 2(S_0 + Q_0) + 4$, all wrapper constants **cancel identically to zero** for every $k \ge 0$:

$$B\bigl(\mathcal{E}_{w_0}^k(\mathcal{E}_{w_0}(s))\bigr) - B\bigl(\mathcal{E}_{w_0}^k(\mathcal{P}_{w_0, 2}(s))\bigr) = (2^{k+1} - 1)(S_0 + Q_0).$$

Across a 13-step escaping ladder with $S_0 + Q_0 = 20{,}792$, $(2^{13} - 1) \times 20{,}792 = \mathbf{170{,}307{,}272}$ **bytes** (`> 170 MB` wiped out in one stroke!). In our real relay, `C++` dropped from `167 MB` (first merge) to **`1.97 MB`** today, and `Common Lisp..Clojure` dropped from `35 MB` to **`655–659 KB`**.

*(Fun meta-bug while proving this in Rocq: writing ``Forth `126 PARSE` vs `S\"` `` inside a Coq `(* ... *)` comment caused Coq 8.20.1's own lexer to fail with `Syntax Error: Lexer: Unterminated string` — because Coq's nested comment parser tracks `"` string literals inside comments! Even the proof assistant's lexer proved why unescaped quotes are treacherous.)*

### 2.3 Loop Telescoping ($\prod r_k = 1$), Spike Containment, & Front-Heavy Ordering

Around any closed relay of $n$ steps with size ratios $r_k = L_k / L_{k+1}$, the product telescopes to unity: $\prod_{k=1}^n r_k = 1$ (verified to `1.000000000000001` across all 247 groups in [`tools/verify_invariants.py`](tools/verify_invariants.py)). Two structural design laws follow:

1. **Local Spike Containment ($r_G r_V \approx 1$):** Wordy esolangs with huge expansion factors ($r_V \gg 1$) must be preceded immediately by a compact generator ($r_G \approx 1/r_V$) so their product cancels locally instead of multiplying all 200+ upstream files:
   - `Glass` (`665 KB`) -> `Taxi` (`94.5 MB`, $r_G = 0.0070$) -> `Deadfish~` (`94.5 MB -> 582 KB`, $r_V = 162$): a **94.5 MB spike** quarantined inside two steps!
   - `Kipple` (`666 KB`) -> `Beatnik` (`65.2 MB`, $r_G = 0.0102$, Scrabble-scored words) -> `Glass` (`665 KB`, $r_V = 98$): a **65.2 MB spike** quarantined inside one step!
   - `///` (`2.37 MB`) -> `CJam -> Underload -> Brain-Flak` (`38.8 MB -> 1.30 MB`): a **38.8 MB spike** quarantined inside three steps!
2. **Front-Heavy Ratio Ordering (`swap_front_heavy_minimizes_sum`):** Under fixed step ratios, peak size is permutation-invariant, while total bytes written per lap ($\sum L_k = 1.14\text{ GB}$) is strictly minimized by placing the steepest steady-ratio steps right after `Ruby` (`SNOBOL4 -> Simula -> Oberon -> Euphoria -> ALGOL 60 -> BCPL`, stepping smoothly from `52.4 MB` down to `10.4 MB`, feeding the `9.41 -> 7.30 MB` raw-string corridor where 47 group outputs have **zero** backslashes!).

---

## 3. Favorite Engineering Puzzles Solved Along the Way

### 3.1 Conquering All 6 Languages `mame` Marked *"Not Suitable for Quine Relay"*
In [`mame/quine-relay` commit `900c941`](https://github.com/mame/quine-relay/commit/900c941162ae69fb9a87d98e1da7da85d0d8d3ce) (Sept 2, 2026), Yusuke Endoh staged a spare-language pool (`src/code-gen-pool.rb`) and explicitly listed six candidates as *"Excluded: not suitable for quine relay"*: **`Elm`**, **`Coq` (`Rocq`)**, **`Agda`**, **`ChucK`**, **`bwBASIC`**, and **`Numbat`**. Every single one now runs for real in `quine-relay-284`:
- **`Elm` (step 179):** Pure browser/TEA architecture with no `stdout` port in `elm make` — solved by compiling `Elm` to JS and driving its PureScript/Node harness cleanly.
- **`Rocq` (step 29):** Extraction to OCaml choked on multi-megabyte single string ASTs — solved via `List.iter print_string` over chunked `%pstring` literals compiled by `coqc` + `ocamlopt`.
- **`Agda` (step 251):** MAlonzo GHC backend hits quadratic memory blowup on monolithic string literals — solved at the ~673 KB post-Perl5 corridor with `Data.Text.IO.putStr`.
- **`ChucK` (step 10):** Audio synthesis VM meant to run real-time DSP graphs — solved in `--silent` mode using `chout <= "..."` stream chunks without an audio device.
- **`BASIC (bwBASIC)` (step 9):** Classic line-numbered interpreter with strict line-width limits — solved with `OPTION TERMINAL NONE` and chunked `PRINT` lines.
- **`Numbat` (step 131):** Scientific unit-dimensional language — solved with pure `print(...)` string emission at 662 KB.

### 3.2 `Shakespeare`: Turning 150 MB of Theater into an 18 KB Play
In a 128-step relay, `QR.spl` is `3.45 MB` of `Thou art the sum of a warm sunny summer's day...` arithmetic. At 284 steps (`~7.3 MB` corridor), naive `Shakespeare` balloons past **150 MB** and hangs `spl2c` + `gcc`. Instead, our `QR.spl` is a brisk **18 KB** Elizabethan drama whose characters speak a **342-byte `S-Lang` self-decoder**, followed by ` #:` comment lines carrying the compressed payload. `S-Lang` opens its own source file (`QR.sl`) and decodes those comment lines directly — keeping AST compilation $O(1)$! The same self-reading comment-decoder architecture powers the historical front chain (`SNOBOL4`, `Simula`, `Oberon`, `Euphoria`, `ALGOL 60`, `BCPL`), `Boo`, and `Curry`.

### 3.3 Fitting 284 Languages Through 64 KB 8-Bit `6502` and `Z80` CPUs
Two consecutive literal assemblers (`.byte 34, ...` at $\ge 3\times$ source expansion) blow past the **65,536-byte** 16-bit address space whenever input exceeds `7,282` bytes (`adjacent_litAsm_overflows_64k`). By interleaving on-CPU **Re-Pair byte-pair dictionary decompressors** with literal assemblers (`Uxntal -> MMIX -> 6502 asm -> ARM64 asm -> Z80 asm -> RISC-V asm`), the assembled machine-code ROMs are tiny:
- **`QR.o65` (`xa65` MOS 6502 binary):** **`45,083` bytes** (expands to `149,485` B of `ARM64` assembly in `3.7 s` on Mike Naberezny's upstream `py65` 6502 MPU!).
- **`QR.z80.bin` (`z80asm` Zilog Z80 binary):** **`32,039` bytes** — less than half of 64 KB! — expanding to `339,973` B of `RISC-V` assembly in `0.20 s` on the upstream `z80` C-core emulator!

### 3.4 Official Upstream Esolangs: `Hexagony`, `Rail`, `Kipple`, `Glass`, `Rockstar`
- **`Hexagony` (step 77):** Runs directly on Martin Büttner's canonical `m-ender/hexagony` (`interpreter.rb`) using a zero-backslash `<`/`/`/`>` **boustrophedon snake** across the hexagonal grid — turning `6.35 MB` of `><>` (`Fish`) output into `2.38 MB` of `Vimscript` with zero edge-wrap traps.
- **`Kotlin -> JSFuck` (steps 191–194):** Upgrading `Kotlin`'s LZ78 encoder to a **3-digit base-78 code** (`q * 78`, `/ 6084 = 78^2`, giving $78^3 = 474{,}552$ codewords for a `474,551`-entry dictionary drawn from the 84-char ASCII window `42..125`) shrank `QR.kt` down to **`269 KB`** so `JSFuck` runs cleanly in Node/V8 in ~9 seconds.
- **`Glass` + `Kipple` -> `Curry` (`PAKCS` Heap Rescue):** Early numeric `N>i` `Kipple` + `<34>` `Glass` encodings inflated `QR.curry` past `1.04 MB`, crashing SWI-Prolog's heap inside `PAKCS` at byte `903,168`. Switching `Glass` to compact `~`-escapes (`~q`, `~b`, `~n`, `~l`, `~r`, `~~`) and `Kipple` to safe ASCII `i<"..."` spans shrank `QR.kpl` 15× (`~666 KB`) and brought `Curry` safely down to `645 KB`.
- **Basser `Lout` 16-bit Galley Pagination:** `Lout` stores vertical galley heights in a signed 16-bit C `short` (`SHORT_MAX = 32,767`). Emitting `@NP` page breaks every 40 lines kept every galley well inside 16-bit bounds.
- **The `QR.rb.gen.rb` `ABBREV` Metaprogramming Trap:** `QR.rb.gen.rb` globally escapes every character in `ABBREV.keys` (`~`, `` ` ``, `K`, `J`, `Y`, `H`, `^`, `X`, `Z`, `G`, `U`, `!`) to `\xHH` across the inner Ruby code before macro compression. Writing `b20c =~ /.../` inside a Ruby generator turned `=~` into `=\x7e` — a Ruby `SyntaxError` on Step 1! Formalized in Suite 6 (`abbrev_op_syntax_error` & `abbrev_safe_token_identity`), replacing `=~` with `.index(...)` and negated classes `/[^...]/` with positive hex ranges eliminated the hazard completely.
- **WSL2 / Ubuntu 26.04 `update-shells` `sync` Lock:** Ubuntu 26.04's `/usr/sbin/update-shells` calls `/usr/bin/sync` five times per shell install, stalling indefinitely on WSL2/overlayfs `syncfs` superblock locks during `docker build --no-cache`. Diverting `/usr/bin/sync -> /bin/true` via `dpkg-divert` during build stages `[2..44]` and restoring `/usr/bin/sync` in final stage `[45/45]` made `--no-cache` builds 100% deterministic (`4,189 s`).

---

## 4. Independent Adversarial Verification & Reproducibility

Every extraordinary claim deserves an adversarial check. Across two audit rounds ([`audit/AUDIT.md`](audit/AUDIT.md), [`audit/MATH-CHECK.md`](audit/MATH-CHECK.md)), every gap was closed:

1. **Clean `--no-cache` Ubuntu 26.04 Build + Full 284-Step Run:** [`proof/build.log`](proof/build.log) (`4,189 s`) and [`proof/run.log`](proof/run.log) (`2,377 s`, ending with `Files QR.rb and QR2.rb are identical`).
2. **Byte-for-Byte Upstream Esolang & CPU Verification:**
   - `Hexagony` on `m-ender/hexagony` (`2,375,282 B` match)
   - `Emmental` on Chris Pressey's Haskell `catseye/Emmental` (`1,772,824 B` match)
   - `Rail` on `TryItOnline/rail` C++ (`665,576 B` match, `$ 'main'` entry point)
   - `Kipple` on `cipple 0.2.1` C & Rune Berge's `Kipple.jar` (`65,234,873 B` match)
   - `Glass` on Gregor Richards' `glass-0.12` C++ & `vendor/glass.rb` (`94,546,636 B` match)
   - `6502 asm` (`xa65`) on Mike Naberezny's `py65 1.2.0` (`149,485 B` match, [`audit/scripts/verify_6502_z80.py`](audit/scripts/verify_6502_z80.py))
   - `Z80 asm` (`z80asm`) on `z80 1.2.0` C core (`339,973 B` match, [`audit/scripts/verify_6502_z80.py`](audit/scripts/verify_6502_z80.py))
3. **Mechanical Rulebook, Invariant, & Formal Theorem Checks:**
   - `python3 tools/verify_invariants.py` — checks all 284 steps, Tier-1/Tier-2 counts (`273` + `11`), strict family cap $\le 3$ (`dash=3`, `Scheme=3`, `Rockstar` replacing `Gambit`), loop product $\prod r_k = 1$, and exact integer escape recurrences.
   - `lean proof/formal/QuineRelayTheorems.lean` & `coqc proof/formal/QuineRelayTheorems.v && coqchk -silent -o QuineRelayTheorems` — machine-checks all 7 mathematical theorem suites with zero axioms.

## Read More

- **Full Scientific Paper (PDF & LaTeX):** [`paper/uroboros_284_paper.pdf`](paper/uroboros_284_paper.pdf) ([`paper/uroboros_284_paper.tex`](paper/uroboros_284_paper.tex))
- **Short Payload-Growth Technical Note:** [`paper/payload-growth.md`](paper/payload-growth.md)
- **Machine-Checked `Lean 4` & `Rocq` Proofs:** [`proof/formal/`](proof/formal/)
- **Independent Audit & Math Check:** [`audit/AUDIT.md`](audit/AUDIT.md) · [`audit/MATH-CHECK.md`](audit/MATH-CHECK.md)
- **Architectural Summary & Batch Map:** [`RELAY-284.md`](RELAY-284.md) · [`RECORDS.md`](RECORDS.md) · [`LANGUAGES.md`](LANGUAGES.md)
