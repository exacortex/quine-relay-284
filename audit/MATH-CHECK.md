# Math check: every number in RELAY-284.md and RECORDS.md

Checked against commit `b094c53` on Nov 18, 2026. "Measured" values come from `proof/zones.csv`, which we rebuilt independently (all 246 generator rows match byte for byte; see [AUDIT.md](AUDIT.md)). Sizes use 1 MB = 1,000,000 bytes.

**Status key:** ✅ correct · 🟡 right idea, number is stale or a little off · ⚪ can't be checked from this commit

## Counts and records (RECORDS.md, LANGUAGES.md, README.md)

| Claim | Says | Measured / worked out | Status |
|---|---|---|---|
| Relay steps | 284 | 284 steps in Makefile, LANGUAGES.md, proof/run.log | ✅ |
| Distinct languages | 284 − 11 = 273 | 273 T1 + 11 T2-only in LANGUAGES.md | ✅ |
| New steps vs mame | 156 = 151 T1 + 5 T2-only | 128 + 156 = 284 | ✅ |
| Net new distinct | +150 (bwBASIC shares BASIC with Yabasic) | 123 + 150 = 273 | ✅ |
| mame's distinct count | 123 | 128 − 5 (Wasm binary, FORTRAN77, Gzip, JSFuck, Ook!) | ✅ |
| Family cap ≤ 3 | Scheme = Scheme, Chicken, Chez | 3 | ✅ |
| Retired mame languages restored | 17 of 20 | 17 rows tagged "retired … restored" | ✅ |
| Seed per step, mame | 106.8 B (13,664 ÷ 128) | 106.75 | ✅ |
| Seed per step, 151 | 98.5 B (14,868 ÷ 151) | 98.46, still the record holder | ✅ |
| Seed per step, 284 | 150.3 B (42,680 ÷ 284) | 150.28; QR.rb is 42,680 B | ✅ |
| Largest single file | "94.7 MB single-step Taxi/Glass" | 94,546,636 B = **94.5 MB** (90.2 MiB); proof/RESULT.txt has the right byte count | 🟡 label |
| Corridor size | "~8.6–9.9 MB" | rows 8–60 run **9.41 → 7.30 MB** | 🟡 |
| Bytes written per lap | (not claimed) | 1,141,515,132 B ≈ **1.14 GB** across the 247 group outputs | new |

## Growth and compression numbers (RELAY-284.md)

| Claim | Says | Measured / worked out | Status |
|---|---|---|---|
| Upper ladder doubles `\` per step | "roughly doubles" | Exactly $b' = 2b + q$ at Squirrel, Standard ML, SurgeScript (wrapper adds 0) and Swift (adds 4). See [paper §3](../paper/payload-growth.md#3-the-escape-ladder) | ✅ |
| Front chain | "~55 MB down to ~9.9 MB" | QR.sno 52.4 MB → BCPL prints 10.4 MB → K prints 9.4 MB | 🟡 (52 MB, not 55) |
| C++ shrink | 167 MB → 2.29 MB, 73× | 167 / 2.29 = 72.9 ✅ arithmetic. QR.cpp is now **1.97 MB** (C's output, row 111) | 🟡 stale (now smaller) |
| Common Lisp..Clojure shrink | 35 MB → 781 KB, 45× | 35 / 0.781 = 44.8 ✅ arithmetic. Rows 122–125 are now **655–659 KB** | 🟡 stale (now smaller) |
| "Before" sizes (167 MB, 35 MB, 250+ MB, 82.7 MB XSLT) | historical | Not in this commit | ⚪ |
| Kotlin coder | "3-byte base-84 LZ78, 84³ = 592,704 codepoints, 474,551 slots" | Code uses **base 78** (`q*78`, `/6084` = 78²): 78³ = 474,552 codes, so the 474,551 cap fits exactly. 84 is the width of the character window (chars 42–125) | 🟡 wording |
| Kotlin sizes | "QR.txrlisp ~1.3 MB → ~515 KB", "QR.kt ~516 KB" | Kotlin prints **1.91 MB** (QR.txrlisp); QR.kt is **269 KB** | 🟡 stale |
| QR.jsfuck | ~45 MB, ~9 s | Inside the JavaScript > jq > JSFuck group; not in zones.csv | ⚪ |
| Literal assemblers grow ~2.5× per step | ~2.5× | RISC-V (still literal) is 4.75× (340 KB program → 71.6 KB output). The old adjacent layout isn't in this commit | ⚪ |
| Payload after RISC-V | "~55 KB" | RISC-V prints 71.6 KB; BeanShell group prints 58.4 KB | 🟡 close |
| WASM 4-byte LEB128 | up to 256 MB | 4 × 7 = 28 bits → 2²⁸ − 1 = 268,435,455 B = 256 MiB | ✅ |
| JVM constant limit | 64 KB | `CONSTANT_Utf8` length is u2 → 65,535 B | ✅ |
| Lout SHORT_MAX | 32,767 | C `short` max | ✅ |
| MAX_ARG_STRLEN | 131,072 | 32 × 4096 | ✅ |

## Suggested text fixes

1. RECORDS.md "94.7 MB" → "94.5 MB".
2. RECORDS.md corridor "~8.6–9.9 MB" → "~7.3–9.4 MB".
3. RELAY-284.md Kotlin: "3-digit base-78 LZ78 code (78³ = 474,552 codes) drawn from an 84-character window".
4. RELAY-284.md: mark the 167 MB / 35 MB / 250 MB figures as "first merge attempt" and give today's sizes (C++ 1.97 MB, Common Lisp..Clojure ~0.66 MB, QR.kt 269 KB, QR.txrlisp 1.91 MB, QR.sno 52.4 MB).

None of these change the record. They are stale or loose labels on numbers that have since gone down.
