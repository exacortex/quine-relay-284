# Quine Relay Records *(ARCHIVED — 284 WITHDRAWN)*

> [!CAUTION]
> **Withdrawn:** `exacortex/quine-relay-284` is **not** a valid record — several steps violated Yusuke Endoh's no-cheating rules.
> For the active, strictly audited leaderboard and rules, see **[exacortex/quine-relay-256/RECORDS.md](https://github.com/exacortex/quine-relay-256/blob/main/RECORDS.md)**.

---

These were the earlier draft rules before adopting Yusuke Endoh's three no-cheating rules and dropping Tier 2.

## Leaderboard *(superseded — see [quine-relay-256/RECORDS.md](https://github.com/exacortex/quine-relay-256/blob/main/RECORDS.md))*

| Relay | Tier 1 (distinct languages) | Tier 2 (relay steps) | Status | Date |
|---|---|---|---|---|
| [exacortex/quine-relay-256](https://github.com/exacortex/quine-relay-256) *(active replacement)* | **256** | **256** | Strictly under mame's no-cheating rules, clean Ubuntu 26.04 Docker proof + Malbolge Unshackled | 2026-11-21 |
| ~~[exacortex/quine-relay-284](https://github.com/exacortex/quine-relay-284)~~ *(this repo — WITHDRAWN)* | ~~273~~ | ~~284~~ | **Withdrawn** — violated no-cheating rules | 2026-11-18 |
| ~~[exacortex/quine-relay-151](https://github.com/exacortex/quine-relay-151)~~ *(not counted)* | ~~143~~ | ~~151~~ | **Not counted** — BASIC step wrote temp file + `cat` | 2026-11-13 |
| [mame/quine-relay](https://github.com/mame/quine-relay) | 123 | 128 | mame's CI, Ubuntu 26.04 | 2026 |

To add a relay, open a pull request that edits this table and links to your proof (see "How to claim a record" below).

## Tier 1: distinct languages

Each language counts once. A language counts only if it has its own name and its own grammar or spec.

- Implementations of the same language count once. (Guile, Chez, and Chicken are all Scheme — counted once.)
- Versions of a language count once. (FORTRAN77 and Fortran90 are both Fortran.) Raku is the one exception: it was renamed from Perl 6 in 2019 and is its own language now.
- Encodings and word swaps of another language don't count. (Ook! is Brainfuck. JSFuck is JavaScript. WebAssembly binary and text are one language.)
- File formats that aren't programs don't count. (Gzip.)
- Different CPU/VM instruction sets *do* count separately when each has its own ISA and assembler/runtime (x86-64 NASM, ARM64, RISC-V, 6502, Z80, MMIX, Uxntal, Parrot PASM, LLVM IR, JVM Jasmin, .NET MSIL).
- A language with its own name that compiles to another one *does* count. (TypeScript, CoffeeScript, Genie, Hy, Coconut, Racket, PureScript, Elm, Gleam, MoonScript, Teal, YueScript.)

[LANGUAGES.md](LANGUAGES.md) shows how each of our 284 steps is counted, with the explicit reason for all 11 merges (`284 - 11 = 273` distinct Tier 1 languages).

## Tier 2: relay steps

Steps are counted the way mame counts them, plus a limited number of extra implementations. mame's 128 historical steps are grandfathered as-is; every step added beyond them must:

1. Run on its **own interpreter or compiler**: a different program, not the same one with a different flag.
2. Have **its own source text**. Two steps can't run the same program.
3. Be **verified for real** (see below).
4. Stay within the **family cap**: at most 3 steps per language, counting the first one.

Not allowed for new steps: version-only copies (Python 3.12 and 3.13), the same binary twice, and steps that only pass the text along (`cat`, `base64`, a plain `echo`).

## How to claim a record

A claim needs all of these:

1. **A public repo** with the seed program, a `Dockerfile` that installs every language, and a list of steps tagged `T1` or `T2 only` (like [LANGUAGES.md](LANGUAGES.md)).
2. **A full run in Docker** built from that `Dockerfile` with zero stand-ins. Every step runs on its real interpreter or compiler, in order, in one image.
3. **A closed loop.** The last step's output must be byte-for-byte identical to the seed. Publish the SHA-256 of both files.
4. **The logs** of the build and the run, committed to the repo.
5. **Credit** to Yusuke Endoh's Quine Relay if you build on it, with its MIT license kept as-is.

Anyone should be able to repeat the run with `docker build` and `docker run`. If they can't, the claim doesn't stand.

## Side records

| Record | mame's 128 | quine-relay-151 | This repo (284) |
|---|---|---|---|
| Distinct languages (Tier 1) | 123 | 143 | **273** |
| Relay steps (Tier 2) | 128 | 151 | **284** |
| Smallest seed per step | 106.8 B (13,664 ÷ 128) | **98.5 B** (14,868 ÷ 151) | 150.3 B (42,680 ÷ 284) |
| Typical main corridor payload | ~1.15 MB front (`27.9 KB` median, `4.69 MB` `Ook!`) | ~3 MB (`~4.7 MB` `Ook!`) | **~7.3–9.4 MB** (`94.5 MB` `Glass`/`Taxi`, `1.14 GB` group sum) |
| Retired mame languages restored | — | 2 | **17 of 20** |
