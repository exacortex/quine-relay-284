# Formal Machine-Checked Proofs (`Lean 4` & `Rocq / Coq`)

Because `Lean 4` (step 30) and `Rocq` (step 29) are themselves active compilers inside the 284-step relay, we use the exact theorem provers installed in the `qr284` Ubuntu 26.04 container (`Lean v4.35.0` and `Rocq / Coq v8.20.1` + `coqchk`) to formally machine-check **seven core theorem suites** governing cyclic multi-language quine relays — with **zero external axioms, zero `sorry`, and zero `Admitted`**.

## Files

| File | Proof Assistant | Contents |
|---|---|---|
| [`QuineRelayTheorems.lean`](QuineRelayTheorems.lean) | **Lean 4.35.0** | Complete constructive proofs of Suites 1–7 (`0 sorry`, `0 warnings`, pure Lean 4 core) |
| [`QuineRelayTheorems.v`](QuineRelayTheorems.v) | **Rocq / Coq 8.20.1** | Complete constructive proofs of Suites 1–7 verified by both `coqc` and the independent kernel checker `coqchk` (`Axioms: <none>`) |
| [`PROOF_CHECK.log`](PROOF_CHECK.log) | Both kernels | Recorded verification output from `lean`, `coqc`, and `coqchk -silent -o QuineRelayTheorems` |

## Theorem Suites Verified

1. **Affine Escape Dynamics, Eigen-Doubling & Byte-Backslash Conservation (`escStep`, `iterEsc`)**
   - **`phi_escStep` / `phi_iterEsc`:** Proves $\Phi(S, Q) := S + Q + 2$ is an exact multiplicative eigen-functional of C/POSIX string escaping ($`\` \mapsto `\\`$, $`"` \mapsto `\"`$, $+2$ outer quotes) with eigenvalue $\lambda = 2$:
     $$\Phi(\mathcal{E}_{w_0}^k(s)) = 2^k \Phi(s).$$
   - **`byte_bslash_conservation`:** Proves the linear conservation law $\Psi(B, S) := B - S$, showing $B_k + S_0 = B_0 + S_k + k w_0$ for all $k \ge 0$ completely independent of quote count $Q_0$ — every byte of exponential payload growth is 1-to-1 accounted for by $S_k - S_0$.
   - **`iterEsc_bslash_closed` / `iterEsc_bytes_closed`:** Exact closed-form $k$-step ladder equations for $S_k$ and $B_k$.

2. **Zero-Residual Delimiter Reset Identity (`parse_reset_saves_exponential`, `forth_cpp_ladder_collapse_witness`)**
   - Proves that replacing an escaping wrapper $\mathcal{E}_{w_0}$ at the base of a $k$-step escaping ladder with a zero-backslash delimiter-parsed transducer $\mathcal{P}_{w_0, 2}$ (such as Forth's `126 PARSE ...~`) saves **exact** homogeneous exponential bytes with zero constant residual:
     $$B\bigl(\mathcal{E}_{w_0}^k(\mathcal{E}_{w_0}(s))\bigr) - B\bigl(\mathcal{E}_{w_0}^k(\mathcal{P}_{w_0, 2}(s))\bigr) = (2^{k+1} - 1)(S_0 + Q_0).$$
   - Instantiated on the 13-step `Forth -> ... -> C++` ladder ($S_0 = 20{,}674$, $Q_0 = 118$), proves $(2^{13} - 1)(20{,}674 + 118) = 170{,}307{,}272$ bytes saved (`> 170 MB` vs `< 2.5 MB`).

3. **Adjacent-Swap Ratio Ordering (`swap_peak_invariant`, `swap_front_heavy_minimizes_sum`)**
   - Formalizes the exchange argument for fixed-ratio relays: swapping adjacent ratios $x > y$ leaves peak payload $x y L$ invariant while strictly decreasing intermediate + outer sum $(x y + y)L < (x y + x)L$ whenever $x > y$ and $L > 0$, proving high-expansion steps belong immediately after the seed (`Ruby`).

4. **Interleaved Re-Pair Assembly Contraction & 64 KB ROM Bounds (`adjacent_litAsm_overflows_64k`, `interleaved_asm_invariant`)**
   - Proves two consecutive $3\times$ literal byte-emitting assemblers exceed the 65,536-byte 16-bit address space (`6502` / `Z80`) for any payload $x \ge 7{,}282$, while interleaving contractive pair-dictionary assemblers preserves $x_{2t} \le M$ across all horizons $t \in \mathbb{N}$.

5. **Exact Base-78 3-Digit LZ78 Dictionary Capacity (`base78_lz78_capacity_exact`)**
   - Verifies $78^2 = 6{,}084 < 474{,}551 = 78^3 - 1 < 78^3 = 474{,}552$, matching `Kotlin`'s 3-digit base-78 coder (`q * 78`, `/ 6084`) over the 84-character ASCII window `42..125` (with 6 characters excluded).

6. **Lexer-Aware `ABBREV` Pre-Escape Soundness (`abbrev_op_syntax_error`, `abbrev_safe_token_identity`)**
   - Models `QR.rb.gen.rb`'s byte-level `\xHH` pre-escaping across `StrLit` (`"..."`), `RawLit` (`%q(...)`), and `OpTok` (Ruby operators), proving why `~` (`0x7e`) inside `=~` (`OpTok [0x3d, 0x7e]`) produces `none` (`SyntaxError`) while `StrLit` unescaping and `ABBREV`-free `RawLit`/`OpTok` tokens preserve exact semantics.

7. **$N$-Step Uroboros Quine Relay Cycle Closure (`exec_wrap_id`, `uroboros_cycle_closure`)**
   - Proves by structural induction on arbitrary transducer lists $[T_1, \dots, T_N]$ that stagewise soundness ($\forall p,\, \text{run}_i(\text{enc}_i(p)) = p$) plus seed self-application ($\text{run}_0(\text{seed}) = \text{wrapChain}(\text{stages}, \text{seed})$) implies exact byte-for-byte cycle closure (`QR2.rb = QR.rb`).

## Reproduce in < 15 Seconds

```sh
docker run --rm -v "$PWD/proof/formal:/work" -w /work qr284 bash -c '
  set -eo pipefail
  lean --version && lean QuineRelayTheorems.lean
  coqc --version | head -n 2 && coqc QuineRelayTheorems.v
  coqchk -silent -o QuineRelayTheorems
  rm -f *.vo *.vok *.vos *.glob .*.aux
'
```
