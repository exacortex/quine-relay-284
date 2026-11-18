# Independent audit of Quine Relay 284

**Commit audited:** `b094c53` (Nov 18, 2026) · **Auditor:** Claude (Anthropic), working for the repo owner · **Date:** Nov 18, 2026

**Claim under test:** 284 relay steps across 273 distinct languages, built from the published `Dockerfile` (`FROM ubuntu:26.04`, `--no-cache`) and run end to end, with step 284 printing a `QR2.rb` byte-identical to `QR.rb`.

## Verdict

**The claim holds on every check that can be run outside a full Docker lap.** We could not do the full 284-step lap ourselves (the audit machine can't reach Docker Hub or many of the download sites in the Dockerfile). For that part we checked the committed logs against the published sources, and they agree.

All five problems from the Nov 17 audit of `4be869e` are fixed in `b094c53` (see the last section).

## 1. Seed and sources

| Check | Result |
|---|---|
| `QR.rb` size | 42,680 bytes |
| `sha256(QR.rb)` | `9ce6dbe31564079cb8e7bec5830e06a02b8cb7c651b7a48e0f6970aaeceb509a`, same as `SHA256SUMS` and `proof/README.md` |
| `QR.rb` rebuilt from `src/` | byte-identical |
| `Makefile`, `README.md`, `LANGUAGES.md` rebuilt from `src/` | byte-identical |
| `Dockerfile` rebuilt from `src/` | identical except line 1. `Dockerfile.gen.rb` writes the host's own Ubuntu version (`FROM ubuntu:$VERSION_ID`), and our host was 24.04 |
| `proof/zones.csv` rebuilt independently | all 246 generator rows match in byte count (our own extractor, `scripts/dump_steps.rb`) |

`wasm-tmpl.dat` needs `wat2wasm`. We used the `wabt` npm package (`scripts/wat2wasm-node.js`), and the seed still rebuilt byte-for-byte.

## 2. Build log (`proof/build.log`)

- Every one of the 45 `FROM`/`RUN`/`COPY` steps in the published `Dockerfile` appears in the log, in order, with the same command text (`scripts/cmp_build.py`). The only differences are Docker's `docker.io/library/` prefix and trailing spaces.
- Only one step is `CACHED`: the base image `FROM ubuntu:26.04`. That is normal with `--no-cache`, which rebuilds layers but reuses an image it has already pulled. The other 49 build entries show `DONE` with fresh timings, real `apt`, `pip`, `cargo` and `curl` output, and compiler warnings.
- Cosmetic: the `FROM` line shows `[ 1/75]` while every other step shows `/45`. BuildKit can label a shared base-image step with the step count of an earlier build that loaded the same image. It does not mean the log was pieced together. Every numbered step `2/45`–`45/45` is present exactly once.

## 3. Run log (`proof/run.log`)

- 284 step headers (`##  N: A -> B  ##`), in the same order as `LANGUAGES.md`.
- Ends with `diff -s QR.rb QR2.rb` → `Files QR.rb and QR2.rb are identical`.
- Counts in `LANGUAGES.md`: 273 `T1` + 11 `T2 only` = 284. Scheme family = Scheme, Chicken Scheme, Chez Scheme (cap of 3 holds; Gambit was replaced by Rockstar).

## 4. Esolang steps on their original interpreters

These are the steps where the relay once used its own interpreter, which gives the most room for a hidden shortcut. For each one we took the step's exact full-size program from the generator, ran it on the original upstream interpreter, and compared the output byte-for-byte with what the generator says the next step's program must be. stdin was `/dev/null`, as in `docker run` without `-i`.

| Step | Interpreter used here | Program in | Output | Result | sha256 of output |
|---|---|---|---|---|---|
| 77 Hexagony | `m-ender/hexagony` @ `b674f59` (`interpreter.rb`) | 6,346,711 B | 2,375,282 B | **match** | `70bf31a1…5375971` |
| 126 Emmental | `catseye/Emmental` reference (Haskell, built with GHC) | 1,973,024 B | 1,772,824 B | **match** | `88eaee46…cfd7c63d` |
| 255 Rail | `TryItOnline/rail` @ `04b7259` (C++) | 665,596 B | 665,576 B | **match** | `bab41f28…6b80c388` |
| 256 Kipple | `cipple-0.2.1.c` from `graue/esofiles` @ `07dce2d` | 665,576 B | 65,234,873 B | **match** | `3e9c7e76…fb36ac72` |
| 258 Glass | Gregor Richards' `glass-0.12` C++ (from `graue/esofiles`) | 665,314 B | 94,546,636 B | **match** | `a3d2c461…0422a1e4` |
| 258 Glass | repo's own `vendor/glass.rb` | 665,314 B | 94,546,636 B | **match** | same |

The Rail program now starts with `$ 'main'`, the entry point the real interpreter needs. That was the open question in the Nov 17 audit.

`glass-0.12` needs `-std=gnu++98 -include cstring -include cstdlib -include cstdio -fpermissive` to build with a modern g++. We changed no source.

**Not compared against a third-party implementation:** the 6502 and Z80 runners (`vendor/run6502.py`, `vendor/runz80.py`). Both are self-made. Their input is assembled by the real `xa65` and `z80asm`, but the CPU emulation is the repo's own.

## 5. Small notes (not problems)

- **Kipple waits on stdin.** `cipple` reads stdin as Kipple's input stack. `docker run --rm qr284` gives it `/dev/null` and it finishes in under a second. `docker run -it` would leave it waiting at step 256. Changing the rule to `cipple QR.kpl < /dev/null > QR.beatnik` makes the step safe either way.
- **Some numbers in RELAY-284.md and RECORDS.md are stale.** They describe earlier merges, and today's files are mostly smaller. None of them affects the record. See [MATH-CHECK.md](MATH-CHECK.md).

## 6. The Nov 17 problem list, rechecked

| # | Nov 17 (commit `4be869e`) | Nov 18 (commit `b094c53`) |
|---|---|---|
| 1 | Rail program had no `$ 'main'`, ran only on `vendor/rail.rb` | Fixed: official interpreter, output matches |
| 2 | Proof build came from `FROM qr157:latest` with every layer cached | Fixed: build.log is a `--no-cache` build of the published Dockerfile from `ubuntu:26.04` |
| 3 | 284 steps but a 3-per-family cap gave 283 (4 Schemes) | Fixed: Gambit → Rockstar, 3 Schemes |
| 4 | README said 17 retired languages, RECORDS said 19 | Fixed: 17 of 20 everywhere |
| 5 | Glass, Kipple, Emmental, Hexagony on self-made interpreters only | Fixed: all now match upstream interpreters (table above) |

## How to repeat this audit

Scripts are in [`scripts/`](scripts/). Group numbers like `022.out` are the order `dump_steps.rb` writes groups in (innermost first) for this commit.

```sh
cd src
for f in lazyk-boot blc-boot grass-boot wasm-tmpl; do ruby $f.dat.gen.rb; done   # wasm-tmpl needs wat2wasm
ruby QR.rb.gen.rb && sha256sum ../QR.rb                       # rebuild the seed
ruby ../audit/scripts/dump_steps.rb "$PWD" /tmp/steps          # every group's exact output
python3 ../audit/scripts/analyze.py ../proof/zones.csv /tmp/steps
python3 ../audit/scripts/cmp_build.py ../Dockerfile ../proof/build.log
# build rail, cipple, glass-0.12, catseye/Emmental, clone m-ender/hexagony into $INTERP, then:
STEPS=/tmp/steps INTERP=$INTERP REPO=$PWD/.. ../audit/scripts/rerun5.sh
```

The full lap still needs Docker: `docker build --no-cache -t qr284 . && docker run --rm qr284`.
