(*
  QuineRelayTheorems.v
  Constructive Formal Proofs for Cyclic Multi-Language Quine Relays
  Verified with Rocq / Coq 8.20.1 (OCaml 5.4.0) + coqchk inside the qr284 Ubuntu 26.04 container.
  Zero external axioms, zero Admitted, zero warnings.
*)

From Coq Require Import Arith PeanoNat ZArith Lia List Bool.
Import ListNotations.

Module QuineRelay.

(* ========================================================================= *)
(* 1. Affine State-Space Dynamics of Nested C/POSIX String Escaping          *)
(* ========================================================================= *)

Record EscState : Type := mkEsc {
  bytes  : nat;
  bslash : nat;
  dquote : nat
}.

Definition escStep (w0 : nat) (s : EscState) : EscState :=
  mkEsc (bytes s + bslash s + dquote s + w0)
        (2 * bslash s + dquote s)
        (dquote s + 2).

Fixpoint iterEsc (w0 k : nat) (s : EscState) : EscState :=
  match k with
  | 0    => s
  | S k' => escStep w0 (iterEsc w0 k' s)
  end.

Definition phi (s : EscState) : nat :=
  bslash s + dquote s + 2.

Theorem iterEsc_dquote : forall w0 k s,
  dquote (iterEsc w0 k s) = dquote s + 2 * k.
Proof.
  intros w0 k s. induction k as [| k IH]; simpl; lia.
Qed.

Theorem phi_escStep : forall w0 s,
  phi (escStep w0 s) = 2 * phi s.
Proof.
  intros w0 s. unfold phi, escStep; simpl; lia.
Qed.

Theorem phi_iterEsc : forall w0 k s,
  phi (iterEsc w0 k s) = (2 ^ k) * phi s.
Proof.
  intros w0 k s. induction k as [| k IH].
  - simpl. lia.
  - simpl iterEsc. rewrite phi_escStep, IH. simpl Nat.pow. lia.
Qed.

Theorem byte_bslash_conservation : forall w0 k s,
  bytes (iterEsc w0 k s) + bslash s = bytes s + bslash (iterEsc w0 k s) + k * w0.
Proof.
  intros w0 k s. induction k as [| k IH].
  - simpl. lia.
  - simpl iterEsc. unfold escStep; simpl. lia.
Qed.

Lemma two_pow_ge_succ : forall k, 2 ^ k >= k + 1.
Proof.
  induction k as [| k IH]; simpl; lia.
Qed.

Theorem iterEsc_bslash_closed : forall w0 k s,
  bslash (iterEsc w0 k s) + dquote s + 2 * k + 2 =
    (2 ^ k) * (bslash s + dquote s + 2).
Proof.
  intros w0 k s.
  pose proof (phi_iterEsc w0 k s) as Hphi.
  pose proof (iterEsc_dquote w0 k s) as Hq.
  unfold phi in Hphi. lia.
Qed.

Theorem iterEsc_bytes_closed : forall w0 k s,
  bytes (iterEsc w0 k s) + bslash s + dquote s + 2 * k + 2 =
    bytes s + k * w0 + (2 ^ k) * (bslash s + dquote s + 2).
Proof.
  intros w0 k s.
  pose proof (byte_bslash_conservation w0 k s) as Hcons.
  pose proof (iterEsc_bslash_closed w0 k s) as Hbs.
  lia.
Qed.

(* ========================================================================= *)
(* 2. Zero-Backslash Delimiter Reset Theorem (Forth 126 PARSE vs S-escaped)  *)
(* ========================================================================= *)

Definition parseStep (wp qp : nat) (s : EscState) : EscState :=
  mkEsc (bytes s + wp) 0 qp.

Theorem parse_reset_saves_exponential : forall w0 k s,
  bytes (iterEsc w0 k (escStep w0 s)) =
    bytes (iterEsc w0 k (parseStep w0 2 s)) +
      (2 ^ (k + 1) - 1) * (bslash s + dquote s).
Proof.
  intros w0 k s.
  pose proof (iterEsc_bytes_closed w0 k (escStep w0 s)) as He.
  pose proof (iterEsc_bytes_closed w0 k (parseStep w0 2 s)) as Hp.
  pose proof (two_pow_ge_succ k) as Hk.
  simpl in He, Hp.
  replace (k + 1) with (S k) by lia.
  simpl Nat.pow.
  nia.
Qed.

(* ========================================================================= *)
(* 3. Adjacent-Swap Ordering Theorem (Peak Invariance & Sum Minimization)    *)
(* ========================================================================= *)

Theorem swap_peak_invariant : forall x y L : nat,
  x * (y * L) = y * (x * L).
Proof.
  intros x y L. nia.
Qed.

Theorem swap_front_heavy_minimizes_sum : forall x y L : nat,
  x > y -> L > 0 ->
  x * (y * L) + y * L < y * (x * L) + x * L.
Proof.
  intros x y L Hxy HL. nia.
Qed.

(* ========================================================================= *)
(* 4. Interleaved Re-Pair Assembly Compression & 64 KB Hardware ROM Bounds   *)
(* ========================================================================= *)

Definition litAsmZ (b x : Z) : Z := (3 * x + b)%Z.

Theorem adjacent_litAsm_overflows_64k : forall b1 b2 x : Z,
  (b1 >= 0 -> b2 >= 0 -> x >= 7282 -> litAsmZ b2 (litAsmZ b1 x) > 65536)%Z.
Proof.
  intros b1 b2 x Hb1 Hb2 Hx. unfold litAsmZ. lia.
Qed.

Fixpoint iterInterleavedAsm (t : nat) (pair : nat -> nat) (x : nat) : nat :=
  match t with
  | 0    => x
  | S t' => iterInterleavedAsm t' pair (pair x)
  end.

Theorem interleaved_asm_invariant : forall t M pair,
  (forall y, y <= M -> pair y <= M) ->
  forall x0, x0 <= M -> iterInterleavedAsm t pair x0 <= M.
Proof.
  induction t as [| t IH]; intros M pair Hcontr x0 Hx0.
  - simpl. exact Hx0.
  - simpl. apply IH; [exact Hcontr | apply Hcontr; exact Hx0].
Qed.

(* ========================================================================= *)
(* 5. Exact Base-78 3-Digit LZ78 Capacity & Forth->C++ 13-Step Witness       *)
(* ========================================================================= *)

Theorem base78_lz78_capacity_exact :
  (78 ^ 2 = 6084 /\ 78 ^ 3 = 474552 /\ 78 ^ 3 - 1 = 474551 /\ 78 ^ 2 < 474551)%Z.
Proof.
  simpl; lia.
Qed.

Theorem forth_cpp_13step_savings_witness :
  ((2 ^ 13 - 1) * (20674 + 118) = 170307272 /\ 170307272 > 167000000)%Z.
Proof.
  simpl; lia.
Qed.

(* ========================================================================= *)
(* 6. Lexer-Aware `ABBREV` Pre-Escape Soundness (`QR.rb.gen.rb` Safety)      *)
(* ========================================================================= *)

Inductive TokKind : Type :=
  | StrLit : list nat -> TokKind
  | RawLit : list nat -> TokKind
  | OpTok  : list nat -> TokKind.

Definition preEscapeByte (inKeys : nat -> bool) (b : nat) : nat :=
  if inKeys b then b + 256 else b.

Definition unescapeStrByte (b : nat) : nat :=
  if 256 <=? b then b - 256 else b.

Lemma unescape_preEscape_byte : forall inKeys b,
  b < 256 -> unescapeStrByte (preEscapeByte inKeys b) = b.
Proof.
  intros inKeys b Hb. unfold preEscapeByte, unescapeStrByte.
  destruct (inKeys b).
  - assert (Hge : 256 <=? b + 256 = true) by (apply Nat.leb_le; lia).
    rewrite Hge. lia.
  - assert (Hlt : 256 <=? b = false) by (apply Nat.leb_gt; lia).
    rewrite Hlt. reflexivity.
Qed.

Definition evalEscapedTok (inKeys : nat -> bool) (t : TokKind) : option TokKind :=
  match t with
  | StrLit bs => Some (StrLit (map (fun b => unescapeStrByte (preEscapeByte inKeys b)) bs))
  | RawLit bs => Some (RawLit (map (preEscapeByte inKeys) bs))
  | OpTok bs  => if @existsb nat inKeys bs then None else Some (OpTok bs)
  end.

Theorem abbrev_op_syntax_error :
  evalEscapedTok (fun b => Nat.eqb b 126) (OpTok [61; 126]) = None.
Proof.
  reflexivity.
Qed.

Lemma strLit_map_roundtrip : forall inKeys bs,
  (forall b, In b bs -> b < 256) ->
  map (fun b => unescapeStrByte (preEscapeByte inKeys b)) bs = bs.
Proof.
  intros inKeys bs H8. induction bs as [| b rest IH].
  - reflexivity.
  - simpl. rewrite unescape_preEscape_byte by (apply H8; left; reflexivity).
    rewrite IH by (intros x Hx; apply H8; right; exact Hx).
    reflexivity.
Qed.

Lemma rawLit_map_safe : forall inKeys bs,
  (forall b, In b bs -> inKeys b = false) ->
  map (preEscapeByte inKeys) bs = bs.
Proof.
  intros inKeys bs Hsafe. induction bs as [| b rest IH].
  - reflexivity.
  - simpl. unfold preEscapeByte at 1.
    rewrite Hsafe by (left; reflexivity).
    rewrite IH by (intros x Hx; apply Hsafe; right; exact Hx).
    reflexivity.
Qed.

Lemma opTok_existsb_false : forall (inKeys : nat -> bool) (bs : list nat),
  (forall b, In b bs -> inKeys b = false) ->
  @existsb nat inKeys bs = false.
Proof.
  intros inKeys bs Hsafe. induction bs as [| b rest IH].
  - reflexivity.
  - simpl. rewrite Hsafe by (left; reflexivity).
    simpl. apply IH. intros x Hx; apply Hsafe; right; exact Hx.
Qed.

Theorem abbrev_safe_token_identity : forall inKeys tok,
  (match tok with
   | StrLit bs => forall b, In b bs -> b < 256
   | RawLit bs => forall b, In b bs -> inKeys b = false
   | OpTok  bs => forall b, In b bs -> inKeys b = false
   end) ->
  evalEscapedTok inKeys tok = Some tok.
Proof.
  intros inKeys [bs | bs | bs] Hok; simpl.
  - rewrite (strLit_map_roundtrip inKeys bs Hok). reflexivity.
  - rewrite (rawLit_map_safe inKeys bs Hok). reflexivity.
  - rewrite (opTok_existsb_false inKeys bs Hok). reflexivity.
Qed.

(* ========================================================================= *)
(* 7. N-Step Uroboros Quine Relay Closure Theorem                            *)
(* ========================================================================= *)

Record Stage (Code : Type) : Type := mkStage {
  enc   : Code -> Code;
  run   : Code -> Code;
  sound : forall target, run (enc target) = target
}.

Fixpoint wrapChain {Code : Type} (stages : list (Stage Code)) (target : Code) : Code :=
  match stages with
  | []        => target
  | s :: rest => enc Code s (wrapChain rest target)
  end.

Fixpoint execChain {Code : Type} (stages : list (Stage Code)) (prog : Code) : Code :=
  match stages with
  | []        => prog
  | s :: rest => execChain rest (run Code s prog)
  end.

Theorem exec_wrap_id : forall {Code : Type} (stages : list (Stage Code)) (target : Code),
  execChain stages (wrapChain stages target) = target.
Proof.
  intros Code stages target.
  induction stages as [| s rest IH].
  - reflexivity.
  - simpl. rewrite (sound Code s). exact IH.
Qed.

Theorem uroboros_cycle_closure : forall {Code : Type}
  (run0 : Code -> Code) (stages : list (Stage Code)) (seed : Code),
  run0 seed = wrapChain stages seed ->
  execChain stages (run0 seed) = seed.
Proof.
  intros Code run0 stages seed Hquine.
  rewrite Hquine. apply exec_wrap_id.
Qed.

End QuineRelay.
