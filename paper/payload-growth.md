# Why long quine relays blow up, and how a 284-step relay stays under 100 MB

*A short technical note on the Quine Relay 284 repo, commit `b094c53`. Every number here is measured from that commit with the scripts in [`audit/scripts/`](../audit/scripts/). Nothing is taken from the repo's own write-up without being rechecked.*

## Summary

A quine relay is a loop of programs. Program 1 prints program 2, program 2 prints program 3, and the last one prints program 1 again. Each program has to carry every later program inside it as data. This note models how that data grows, proves three results about it, and checks them against the real files of the 284-step relay.

1. **Escape ladder (exact).** A run of $m$ steps that each use C-style escaping multiplies the backslash count by $2^m$. The relay's real files follow this formula to the byte for four steps in a row.
2. **Placement rule.** If every step grows its payload by a fixed factor, the largest file does not depend on the order of the steps, but the total bytes written per lap does. The total is smallest when the steps that grow the most go first, right after the seed. The rule the project worked out by trial matches this.
3. **Special-character cost.** Each quote or backslash a step adds in the middle of the loop costs $2^e$ bytes later, where $e$ is the number of escaping steps that wrap it. With 6 escaping steps at the front, a corridor step that adds one quote pays for it 64 times over. This is why the middle of the relay has to be written with raw strings.

We also record a simple identity: around a closed loop, the product of every step's size ratio is exactly 1. So any growth has to be paid back by a step that compresses. In this relay a few "generator" steps do that work.

## 1. Setup

Number the steps $1,\dots,n$ in run order. Step $k$ runs program $P_k$ and prints $P_{k+1}$. The loop closes: $P_{n+1} = P_1$ (`QR.rb`). Write $L_k = |P_k|$ for the size in bytes.

`proof/zones.csv` lists, for each of the 247 generator groups, the exact text the group prints: its size, backslashes, double quotes, single quotes, newlines and longest line. We rebuilt every row independently (`audit/scripts/dump_steps.rb`) and all 246 non-seed rows match byte for byte. All data below comes from those rows. A row covers one step, except where several mame-style steps share a generator class. Those groups are counted as one step here.

**Step ratio.** Define $r_k = L_k / L_{k+1}$, the size of a step's program over the size of what it prints. $r_k > 1$ means the program is bigger than its output, because it wraps, escapes or spells out its payload. $r_k < 1$ means the program computes a bigger output than itself, so it acts as a generator.

## 2. The loop identity

**Proposition 1.** For any closed relay, $\prod_{k=1}^{n} r_k = 1$.

*Proof.* The product telescopes: $\prod_k L_k/L_{k+1} = L_1/L_{n+1} = 1$, since $P_{n+1}=P_1$. ∎

The statement is trivial, but it has a real consequence. Growth is never free. Every factor of 10 that a wordy language adds has to be cancelled by a factor of 10 of compression somewhere else in the loop. In the 284 relay:

| Step (group run #) | Program | Prints | Ratio $r_k$ |
|---|---|---|---|
| Deadfish~ (232) | 94.5 MB | 582 KB | 162 |
| Beatnik (229) | 65.2 MB | 665 KB | 98 |
| Underload group (78) | 38.8 MB | 1.30 MB | 30 |
| Glass (230) | 665 KB | 94.5 MB | 0.0070 |
| Kipple (228) | 665 KB | 65.2 MB | 0.0102 |
| /// (75) | 2.37 MB | 38.8 MB | 0.061 |
| Ruby (1, the seed) | 42.7 KB | 52.4 MB | 0.0008 |

Each very wordy language sits right after a generator that cancels it. Glass builds the 94.5 MB Taxi program from a 665 KB program, and the Taxi and Deadfish~ steps then shrink it back to 582 KB. The big files stay local: they show up in one or two steps instead of spreading outward.

**Corollary (containment).** Suppose step $V$ has ratio $r_V \gg 1$ and the step just before it is a generator $G$ with $r_G \approx 1/r_V$. Then $L_j$ for every $j < G$ is the same, to first order, as if $V$ and $G$ were both removed. Without $G$, every earlier file would be $r_V$ times larger. In this relay that means about 229 files would each be 162 times larger. *Proof:* $L_j = L_{k} \prod_{i=j}^{k-1} r_i$ for any $j<k$, and $r_G r_V \approx 1$. ∎

## 3. The escape ladder

C-style string escaping writes `\` as `\\` and `"` as `\"`. Let a payload have $b$ backslashes and $q$ double quotes. After one escaping step it has

$$b' = 2b + q + d,\qquad q' = q + d_q,$$

where $d, d_q$ are the few backslashes and quotes the step's own wrapper adds.

**Theorem 1 (ladder).** After $m$ escaping steps in a row with no wrapper characters ($d = d_q = 0$), a payload that started with $(b_0, q_0)$ has

$$b_m = 2^m b_0 + (2^m - 1)\,q_0, \qquad q_m = q_0.$$

*Proof.* By induction. For $m=0$ the formula holds. If $b_m = 2^m b_0 + (2^m-1)q_0$, then $b_{m+1} = 2b_m + q_0 = 2^{m+1}b_0 + (2^{m+1}-2)q_0 + q_0 = 2^{m+1}b_0 + (2^{m+1}-1)q_0$. ∎

The file grows by $b + q$ bytes at each escaping step, so the size gained over the ladder is $\sum_{i<m}(b_i + q_0) = (2^m - 1)(b_0+q_0)$. Escaping alone takes a payload of size $L$ with special-character count $s=b+q$ to $L + (2^m-1)s$. The growth is exponential in $m$, and the base is how many special characters you start with.

**Measured.** The upper ladder (Swift → SurgeScript → Standard ML → Squirrel, group rows 61–64) matches the one-step formula $b' = 2b+q$ with the wrapper adding 0 backslashes at three of the four steps:

| Escaping step | Backslashes in its program | $2b+q$ from the payload it embeds | Wrapper's own |
|---|---|---|---|
| Swift | 248,964 | 248,960 | 4 |
| SurgeScript | 531,124 | 531,124 | 0 |
| Standard ML | 1,108,674 | 1,108,674 | 0 |
| Squirrel | 2,263,782 | 2,263,782 | 0 |

(Reproduce: `python3 audit/scripts/ladder_check.py proof/zones.csv 61 64`.) Four steps take 107,883 backslashes to 2,263,782, a factor of 21. A fifth step at that point would have added another 2.3 million.

**What this says about the Forth fix.** RELAY-284.md says that changing Forth from `S\" ...\"` (an escaping string) to a `126 PARSE ...~` delimiter string helped a lot. Theorem 1 explains it. Taking one escaping step out of a ladder of $m$ divides the backslash count of every file outside it by about 2. It does not explain a 45× drop by itself. The larger drops in RELAY-284.md also depend on the Fortran chunking and on layers that are no longer in the tree, so we can't recheck them (see the [math check](../audit/MATH-CHECK.md)).

## 4. Order matters for the total, not the peak

Use the simplest growth model: each step multiplies by a fixed ratio, $L_k = r_k L_{k+1}$, for the steps between the seed and the end of the chain ($k = 2,\dots,n$), with $L_{n+1}$ fixed.

**Theorem 2.** (a) The largest of these files, $L_2 = L_{n+1}\prod_{k=2}^{n} r_k$, is the same for every order of the steps. (b) The total bytes per lap, $T = \sum_{k=2}^{n} L_k$, is smallest when the ratios are sorted from largest at the front ($k=2$) to smallest at the end.

*Proof.* (a) A product does not depend on order. (b) $L_k = L_{n+1}\prod_{i=k}^{n} r_i$, so the ratio at position $i$ multiplies the files $L_2,\dots,L_i$, which is $i-1$ files. Swap two neighbours with ratios $x$ at position $i$ and $y$ at $i+1$. Only $L_{i+1}$ changes. It goes from $y\,L_{i+2}$ to $x\,L_{i+2}$, and every other file keeps the same product. So the swap lowers $T$ exactly when it moves the larger ratio to the smaller index. Repeating this sort gives the claim. ∎

So reordering alone can't shrink the biggest file. Only changing an encoding (a smaller $r_k$) or adding a generator can. What reordering does change is how many files carry each step's growth. This matches the rule the project found by trial in the 151 and 157 builds: *escaping languages and long-line languages go at the front (right after Ruby): their growth doesn't compound.*

**Measured.** The relay's front chain (Ruby → SNOBOL4 → Simula → Oberon → Euphoria → ALGOL 60 → BCPL, rows 1–7) is where the files are largest: 52.4, 33.4, 23.7, 18.7, 15.5, 12.5 and 10.4 MB. It then flattens into a corridor of 9.4 → 7.3 MB (rows 8–60). These front steps have the largest steady ratios in the relay, $r_k$ = 1.57, 1.41, 1.27, 1.21, 1.25 and 1.20 for SNOBOL4 through BCPL, and they sit exactly where Theorem 2 says they should, at the front. A ratio at position $i$ multiplies $i-1$ files. A 1.57× step at position 2 inflates one file. The same step at position 240 would inflate 239.

## 5. Special characters in the corridor

Theorem 2 treats the ratios as fixed. Escaping steps are different: what they cost depends on how many special characters their input holds, and that depends on everything inside them. Say step $k$'s wrapper adds $d_k$ special characters. Let $e(k)$ be the number of C-style escaping steps that wrap step $k$'s program, meaning escaping steps $i$ with $i < k$, between $k$ and the seed.

**Theorem 3.** Ignoring quotes turning into backslashes (which only adds to the count), the number of backslashes contributed to the largest file $P_2$ by the wrapper characters is at least $\sum_k d_k\, 2^{e(k)}$.

*Proof.* Each of the $d_k$ characters is copied, without loss, into every outer program. Each of the $e(k)$ escaping steps at least doubles it (Theorem 1 with $b_0 \ge 1$). ∎

With $E$ escaping steps placed at the front, every corridor step has $e(k) = E$, so each special character it adds costs at least $2^E$ bytes in the largest file. That gives the design rule "no backslash doubling in the middle": corridor steps must print with raw strings, delimiter strings or quote doubling, so that $d_k = 0$ for backslashes. In the 284 relay, 47 of the 247 group outputs contain zero backslashes, and 110 contain fewer than 100. The 8 MB corridor works only because of this.

## 6. Hard limits that are just arithmetic

These limits from RELAY-284.md hold for the stated reasons. We checked each one against the source spec:

- A 4-byte unsigned LEB128 length holds $4 \times 7 = 28$ bits, so at most $2^{28} - 1 = 268{,}435{,}455$ bytes. That is the "up to 256 MB" (MiB) for WebAssembly data segments.
- A JVM `CONSTANT_Utf8` entry has a 2-byte length, so at most 65,535 bytes. That's why the long literals in Java, Groovy, Clojure, Jasmin and similar steps are chunked.
- Linux caps a single argument at `MAX_ARG_STRLEN` = 32 pages × 4096 = 131,072 bytes. That's why the Makefile step writes its payload with `${file ...}`.
- Lout's `SHORT_MAX` is a C `short`: 32,767.
- Kotlin's dictionary coder writes each code as 3 digits in **base 78** (it uses `q*78` and `/6084 = 78²`). That gives $78^3 = 474{,}552$ codes, and the coder caps the dictionary at index 474,551, which fits exactly. RELAY-284.md calls this "base-84, $84^3 = 592{,}704$". The 84 is the width of the printable character window (characters 42–125) the digits are drawn from, not the base.

## 7. What this note does not show

- It does not prove the relay is the *smallest* possible. Theorem 2 gives the best order only in the fixed-ratio model. Real escaping costs depend on order (Theorem 3), and finding the best order in general is a hard search problem we did not try to solve.
- Numbers that describe earlier, failed merges (167 MB C++, 250+ MB total, 82.7 MB XSLT) are not in this commit and could not be rechecked.
- File sizes *inside* a multi-step group (for example the JSFuck program inside the JavaScript > jq > JSFuck group) are not in `zones.csv`. They need a real run to measure.

## Reproduce

```sh
cd src && ruby lazyk-boot.dat.gen.rb && ruby blc-boot.dat.gen.rb && ruby grass-boot.dat.gen.rb && ruby wasm-tmpl.dat.gen.rb   # needs wat2wasm
ruby ../audit/scripts/dump_steps.rb "$PWD" /tmp/steps      # every group's exact output, ~1 min
python3 ../audit/scripts/analyze.py ../proof/zones.csv /tmp/steps   # cross-check vs zones.csv, peaks, totals
python3 ../audit/scripts/ladder_check.py ../proof/zones.csv 61 64   # Theorem 1 on real data
```

Credit: the relay structure, generator design and most of the code are Yusuke Endoh's [mame/quine-relay](https://github.com/mame/quine-relay) (MIT).
