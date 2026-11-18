/-
  QuineRelayTheorems.lean
  Formal Machine-Checked Theorems for Cyclic Multi-Language Quine Relays
  Verified with Lean 4 (v4.35.0) inside the qr284 Ubuntu 26.04 container.
  Zero external axioms, zero `sorry`, zero warnings.
-/

namespace QuineRelay

/-!
## 1. Affine State-Space Dynamics of Nested C/POSIX String Escaping

A program state `s : EscState` tracks payload byte length `bytes` (`B`),
backslash count `bslash` (`S`), and double-quote count `dquote` (`Q`).
Wrapping `s` in a C/POSIX string literal (`\` -> `\\`, `"` -> `\"`) with
constant wrapper overhead `w0` bytes and `2` outer delimiter quotes applies `escStep w0`.
-/

structure EscState where
  bytes  : Nat
  bslash : Nat
  dquote : Nat
deriving Repr, DecidableEq

/-- Single C/POSIX string-escaping transducer step. -/
def escStep (w0 : Nat) (s : EscState) : EscState :=
  { bytes  := s.bytes + s.bslash + s.dquote + w0
  , bslash := 2 * s.bslash + s.dquote
  , dquote := s.dquote + 2 }

/-- `k`-fold composition of C/POSIX string-escaping steps. -/
def iterEsc (w0 : Nat) : Nat → EscState → EscState
  | 0,     s => s
  | k + 1, s => escStep w0 (iterEsc w0 k s)

/-- Exponential eigen-functional `Phi(s) = S + Q + 2`. -/
def phi (s : EscState) : Nat :=
  s.bslash + s.dquote + 2

/-- Theorem 1a (Quote Linear Growth): Every escaping layer adds exactly 2 quotes. -/
theorem iterEsc_dquote (w0 k : Nat) (s : EscState) :
    (iterEsc w0 k s).dquote = s.dquote + 2 * k := by
  induction k with
  | zero => simp [iterEsc]
  | succ k ih =>
    simp [iterEsc, escStep, ih]
    omega

/-- Lemma: `phi` is an exact multiplicative eigen-functional with eigenvalue 2. -/
theorem phi_escStep (w0 : Nat) (s : EscState) :
    phi (escStep w0 s) = 2 * phi s := by
  simp [phi, escStep]
  omega

/-- Theorem 1b (Exponential Doubling Law): `Phi(iterEsc k s) = 2^k * Phi(s)`. -/
theorem phi_iterEsc (w0 k : Nat) (s : EscState) :
    phi (iterEsc w0 k s) = 2 ^ k * phi s := by
  induction k with
  | zero => simp [iterEsc]
  | succ k ih =>
    calc phi (iterEsc w0 (k + 1) s)
      _ = 2 * phi (iterEsc w0 k s) := phi_escStep w0 _
      _ = 2 * (2 ^ k * phi s)      := by rw [ih]
      _ = (2 ^ k * 2) * phi s      := by rw [← Nat.mul_assoc, Nat.mul_comm 2 (2 ^ k)]
      _ = 2 ^ (k + 1) * phi s      := by rw [← Nat.pow_succ]

/-- Theorem 1c (Byte-Backslash Conservation Law):
    `B - S` grows strictly linearly by `k * w0`, independent of quote count `Q`.
    Stated over `Nat` without truncated subtraction: `B_k + S_0 = B_0 + S_k + k * w0`. -/
theorem byte_bslash_conservation (w0 k : Nat) (s : EscState) :
    (iterEsc w0 k s).bytes + s.bslash = s.bytes + (iterEsc w0 k s).bslash + k * w0 := by
  induction k with
  | zero => simp [iterEsc]
  | succ k ih =>
    simp [iterEsc, escStep, Nat.succ_mul]
    omega

theorem two_pow_ge_succ (k : Nat) : 2 ^ k ≥ k + 1 := by
  induction k with
  | zero => decide
  | succ k ih =>
    rw [Nat.pow_succ]
    omega

/-- Theorem 1d (Exact Closed-Form k-Step Ladder Equations for Backslashes & Bytes): -/
theorem iterEsc_bslash_closed (w0 k : Nat) (s : EscState) :
    (iterEsc w0 k s).bslash + s.dquote + 2 * k + 2 =
      2 ^ k * (s.bslash + s.dquote + 2) := by
  have hphi := phi_iterEsc w0 k s
  have hq   := iterEsc_dquote w0 k s
  unfold phi at hphi
  omega

theorem iterEsc_bytes_closed (w0 k : Nat) (s : EscState) :
    (iterEsc w0 k s).bytes + s.bslash + s.dquote + 2 * k + 2 =
      s.bytes + k * w0 + 2 ^ k * (s.bslash + s.dquote + 2) := by
  have hcons := byte_bslash_conservation w0 k s
  have hbs   := iterEsc_bslash_closed w0 k s
  omega

/-!
## 2. The Zero-Backslash Delimiter Reset Theorem (Forth `126 PARSE ...~` vs `S\" ...\"`)
-/

def parseStep (wp qp : Nat) (s : EscState) : EscState :=
  { bytes  := s.bytes + wp
  , bslash := 0
  , dquote := qp }

/-- Theorem 2a (Zero-Residual Exponential Collapse Identity):
    Replacing `escStep w0` with `parseStep w0 2` at the base of a `k`-step escaping
    ladder reduces the top-of-ladder byte size by EXACTLY `(2^(k+1) - 1) * (S_0 + Q_0)`. -/
theorem parse_reset_saves_exponential (w0 k : Nat) (s : EscState) :
    (iterEsc w0 k (escStep w0 s)).bytes =
      (iterEsc w0 k (parseStep w0 2 s)).bytes +
        (2 ^ (k + 1) - 1) * (s.bslash + s.dquote) := by
  have he := iterEsc_bytes_closed w0 k (escStep w0 s)
  have hp := iterEsc_bytes_closed w0 k (parseStep w0 2 s)
  have hk := two_pow_ge_succ k
  dsimp only [escStep, parseStep] at he hp ⊢
  have hinner : 2 * s.bslash + s.dquote + (s.dquote + 2) + 2 = 2 * (s.bslash + s.dquote) + 4 := by
    omega
  have hpow : 2 ^ k * 2 = 2 ^ (k + 1) := (Nat.pow_succ 2 k).symm
  rw [hinner, Nat.mul_add, ← Nat.mul_assoc, hpow] at he
  have h1 : 2 ^ (k + 1) ≥ 1 := by
    rw [← hpow]
    omega
  have hsub : (2 ^ (k + 1) - 1) * (s.bslash + s.dquote) + (s.bslash + s.dquote) =
              2 ^ (k + 1) * (s.bslash + s.dquote) := by
    calc (2 ^ (k + 1) - 1) * (s.bslash + s.dquote) + (s.bslash + s.dquote)
      _ = (2 ^ (k + 1) - 1 + 1) * (s.bslash + s.dquote) := by rw [Nat.add_mul, Nat.one_mul]
      _ = 2 ^ (k + 1) * (s.bslash + s.dquote) := by rw [Nat.sub_add_cancel h1]
  omega

theorem forth_cpp_ladder_collapse_witness :
    let s0 : EscState := { bytes := 493376, bslash := 20674, dquote := 118 }
    (2 ^ 13 - 1) * (s0.bslash + s0.dquote) = 170307272 ∧
    (iterEsc 64 12 (escStep 64 s0)).bytes > 170000000 ∧
    (iterEsc 64 12 (parseStep 64 14 s0)).bytes < 2500000 := by
  decide

/-!
## 3. Adjacent-Swap Ordering Theorem (Peak Invariance & Total-Bytes Minimization)

For two consecutive fixed-ratio steps with growth factors `x` and `y` wrapping a
downstream payload of size `L > 0`:
- Peak size `x * (y * L) = y * (x * L)` is invariant under swapping `x` and `y`.
- Placing the larger ratio `x` closer to the seed (`x` outer, `y` inner) yields
  strictly smaller intermediate + outer sum `x * y * L + y * L < y * x * L + x * L`
  whenever `x > y` and `L > 0`.
-/

theorem swap_peak_invariant (x y L : Nat) :
    x * (y * L) = y * (x * L) := by
  rw [← Nat.mul_assoc, Nat.mul_comm x y, Nat.mul_assoc]

theorem swap_front_heavy_minimizes_sum (x y L : Nat) (hxy : x > y) (hL : L > 0) :
    x * (y * L) + y * L < y * (x * L) + x * L := by
  have hpeak : x * (y * L) = y * (x * L) := swap_peak_invariant x y L
  have hlt   : y * L < x * L := Nat.mul_lt_mul_of_pos_right hxy hL
  omega

/-!
## 4. Interleaved Re-Pair Assembly Compression & 64 KB Hardware ROM Bounds
-/

def litAsm (b x : Nat) : Nat := 3 * x + b

theorem adjacent_litAsm_overflows_64k (b1 b2 x : Nat) (hx : x ≥ 7282) :
    litAsm b2 (litAsm b1 x) > 65536 := by
  unfold litAsm
  omega

def iterInterleavedAsm : Nat → (Nat → Nat) → Nat → Nat
  | 0,     _,    x => x
  | t + 1, pair, x => iterInterleavedAsm t pair (pair x)

theorem interleaved_asm_invariant (t M : Nat) (pair : Nat → Nat)
    (h_contr : ∀ y, y ≤ M → pair y ≤ M) (x0 : Nat) (hx0 : x0 ≤ M) :
    iterInterleavedAsm t pair x0 ≤ M := by
  induction t generalizing x0 with
  | zero => exact hx0
  | succ t ih =>
    exact ih (pair x0) (h_contr x0 hx0)

/-!
## 5. Exact Base-78 3-Digit LZ78 Dictionary Capacity (`Kotlin -> JSFuck`)

`Kotlin` draws safe printable ASCII symbols from the 84-byte window `42..125`
(excluding 6 characters to leave radix `78`, using `q * 78` and `/ 6084` where `6084 = 78^2`).
2 digits (`78^2 = 6,084`) saturate below 7K phrases, whereas 3 digits (`78^3 = 474,552`)
accommodate the exact `474,551 = 78^3 - 1` dictionary cap!
-/

theorem base78_lz78_capacity_exact :
    78 ^ 2 = 6084 ∧ 78 ^ 3 = 474552 ∧ 78 ^ 3 - 1 = 474551 ∧ 78 ^ 2 < 474551 := by
  decide

/-!
## 6. Lexer-Aware `ABBREV` Pre-Escape Soundness (`QR.rb.gen.rb` Fixed-Point Safety)
-/

inductive TokKind where
  | StrLit : List Nat → TokKind   -- `"..."` (interprets hex escapes back to bytes)
  | RawLit : List Nat → TokKind   -- `%q(...)` (preserves backslash-x literally)
  | OpTok  : List Nat → TokKind   -- Ruby syntax / operators (invalid if hex-escaped)
deriving Repr, DecidableEq

def preEscapeByte (inKeys : Nat → Bool) (b : Nat) : Nat :=
  if inKeys b then b + 256 else b

def unescapeStrByte (b : Nat) : Nat :=
  if b ≥ 256 then b - 256 else b

theorem unescape_preEscape_byte (inKeys : Nat → Bool) (b : Nat) (hb : b < 256) :
    unescapeStrByte (preEscapeByte inKeys b) = b := by
  unfold preEscapeByte unescapeStrByte
  cases inKeys b with
  | false =>
    simp only [Bool.false_eq_true, ↓reduceIte]
    have hlt : ¬ (b ≥ 256) := by omega
    simp [hlt]
  | true =>
    simp only [↓reduceIte]
    have hge : b + 256 ≥ 256 := by omega
    simp [hge]

def evalEscapedTok (inKeys : Nat → Bool) : TokKind → Option TokKind
  | TokKind.StrLit bs =>
      some (TokKind.StrLit (bs.map (fun b => unescapeStrByte (preEscapeByte inKeys b))))
  | TokKind.RawLit bs =>
      some (TokKind.RawLit (bs.map (preEscapeByte inKeys)))
  | TokKind.OpTok bs =>
      if bs.any inKeys then none else some (TokKind.OpTok bs)

theorem strLit_map_roundtrip (inKeys : Nat → Bool) :
    (bs : List Nat) → (∀ b ∈ bs, b < 256) →
    bs.map (fun b => unescapeStrByte (preEscapeByte inKeys b)) = bs
  | [], _ => rfl
  | b :: rest, h8 => by
    have hb : b < 256 := h8 b List.mem_cons_self
    have hr : ∀ x ∈ rest, x < 256 := fun x hx => h8 x (List.mem_cons_of_mem b hx)
    simp [unescape_preEscape_byte inKeys b hb, strLit_map_roundtrip inKeys rest hr]

theorem rawLit_map_safe (inKeys : Nat → Bool) :
    (bs : List Nat) → (∀ b ∈ bs, inKeys b = false) →
    bs.map (preEscapeByte inKeys) = bs
  | [], _ => rfl
  | b :: rest, hsafe => by
    have hb : inKeys b = false := hsafe b List.mem_cons_self
    have hr : ∀ x ∈ rest, inKeys x = false := fun x hx => hsafe x (List.mem_cons_of_mem b hx)
    simp [preEscapeByte, hb, rawLit_map_safe inKeys rest hr]

theorem opTok_any_false (inKeys : Nat → Bool) :
    (bs : List Nat) → (∀ b ∈ bs, inKeys b = false) → bs.any inKeys = false
  | [], _ => rfl
  | b :: rest, hsafe => by
    have hb : inKeys b = false := hsafe b List.mem_cons_self
    have hr : ∀ x ∈ rest, inKeys x = false := fun x hx => hsafe x (List.mem_cons_of_mem b hx)
    simp [List.any, hb, opTok_any_false inKeys rest hr]

theorem abbrev_op_syntax_error :
    evalEscapedTok (fun b => b == 0x7e) (TokKind.OpTok [0x3d, 0x7e]) = none := by
  decide

theorem abbrev_safe_token_identity (inKeys : Nat → Bool) (tok : TokKind)
    (h_ok : match tok with
            | TokKind.StrLit bs => ∀ b ∈ bs, b < 256
            | TokKind.RawLit bs => ∀ b ∈ bs, inKeys b = false
            | TokKind.OpTok  bs => ∀ b ∈ bs, inKeys b = false) :
    evalEscapedTok inKeys tok = some tok := by
  cases tok with
  | StrLit bs =>
      simp [evalEscapedTok, strLit_map_roundtrip inKeys bs h_ok]
  | RawLit bs =>
      simp [evalEscapedTok, rawLit_map_safe inKeys bs h_ok]
  | OpTok bs =>
      simp [evalEscapedTok, opTok_any_false inKeys bs h_ok]

/-!
## 7. N-Step Uroboros Quine Relay Closure Theorem
-/

structure Stage (Code : Type) where
  enc   : Code → Code
  run   : Code → Code
  sound : ∀ target, run (enc target) = target

def wrapChain {Code : Type} : List (Stage Code) → Code → Code
  | [],        target => target
  | s :: rest, target => s.enc (wrapChain rest target)

def execChain {Code : Type} : List (Stage Code) → Code → Code
  | [],        prog => prog
  | s :: rest, prog => execChain rest (s.run prog)

theorem exec_wrap_id {Code : Type} (stages : List (Stage Code)) (target : Code) :
    execChain stages (wrapChain stages target) = target := by
  induction stages with
  | nil => rfl
  | cons s rest ih =>
    simp [wrapChain, execChain, s.sound, ih]

theorem uroboros_cycle_closure {Code : Type}
    (run0 : Code → Code) (stages : List (Stage Code)) (seed : Code)
    (h_quine : run0 seed = wrapChain stages seed) :
    execChain stages (run0 seed) = seed := by
  rw [h_quine]
  exact exec_wrap_id stages seed

end QuineRelay
