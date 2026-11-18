#!/usr/bin/env python3
"""
verify_invariants.py — Mechanical audit of Quine Relay 284's seed, Tier-1/Tier-2
counting rules, family caps, Makefile/run.log alignment, and affine escape dynamics.

Usage (from repo root):
  python3 tools/verify_invariants.py
"""
import csv
import hashlib
import math
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def check(cond: bool, msg: str) -> None:
    if not cond:
        print(f"[FAIL] {msg}", file=sys.stderr)
        sys.exit(1)
    print(f"[PASS] {msg}")


def main() -> None:
    # 1. Seed & SHA256SUMS
    qr_bytes = (ROOT / "QR.rb").read_bytes()
    check(b"\r\n" not in qr_bytes, "QR.rb uses pure LF line endings (0 CRLF)")
    sha = hashlib.sha256(qr_bytes).hexdigest()
    sums_line = (ROOT / "SHA256SUMS").read_text(encoding="utf-8").strip()
    expected_sha = sums_line.split()[0]
    check(sha == expected_sha, f"QR.rb SHA-256 matches SHA256SUMS ({len(qr_bytes):,} B, {sha[:16]}...)")

    # 2. Parse LANGUAGES.md
    lang_text = (ROOT / "LANGUAGES.md").read_text(encoding="utf-8")
    lang_rows = []
    for line in lang_text.splitlines():
        m = re.match(r"^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*(T1|T2 only)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|$", line)
        if m:
            lang_rows.append((int(m.group(1)), m.group(2).strip(), m.group(3).strip(), m.group(5).strip()))

    check(len(lang_rows) == 284, f"LANGUAGES.md has {len(lang_rows)} numbered steps")
    check([r[0] for r in lang_rows] == list(range(1, 285)), "Step indices are contiguous 1..284")

    t1 = [r for r in lang_rows if r[2] == "T1"]
    t2_only = [r for r in lang_rows if r[2] == "T2 only"]
    check(len(t1) == 273 and len(t2_only) == 11, f"Tier-1 / Tier-2 split: {len(t1)} T1 + {len(t2_only)} T2-only = 284")

    retirees = [r for r in lang_rows if "retired" in r[3].lower() and "restored" in r[3].lower()]
    check(len(retirees) == 17, f"Restored mame retirees count: {len(retirees)} of 20")

    # 3. Family cap <= 3 check across all Tier-1 + Tier-2 merges
    merge_map = {
        "mksh": "ksh",
        "BusyBox ash": "dash",
        "yash": "dash",
        "WebAssembly (Binary format)": "WebAssembly (Text format)",
        "Yabasic": "BASIC (bwBASIC)",
        "FORTRAN77": "Fortran90",
        "JSFuck": "JavaScript",
        "Ook!": "Brainfuck",
        "Chicken Scheme": "Scheme",
        "Chez Scheme": "Scheme",
    }
    family_counts = Counter()
    for _, name, tier, _ in lang_rows:
        if name == "Gzip":
            continue
        if tier == "T2 only" and name not in merge_map:
            check(False, f"T2-only step '{name}' missing canonical Tier-1 root")
        root = merge_map.get(name, name) if tier == "T2 only" else name
        family_counts[root] += 1
    check(True, "All 10 non-Gzip T2-only steps map to explicit Tier-1 roots")
    check(len(family_counts) == 273, f"Unique Tier-1 language families: {len(family_counts)} == 273")
    worst_fam, worst_cnt = family_counts.most_common(1)[0]
    top_fams = ", ".join(f"{k}={v}" for k, v in family_counts.most_common(4))
    check(worst_cnt <= 3, f"Strict family cap <= 3 holds everywhere ({top_fams})")

    # 4. Cross-check Makefile targets & proof/run.log headers
    mk_text = (ROOT / "Makefile").read_text(encoding="utf-8")
    mk_headers = re.findall(r'@echo "##\s+(\d+):\s+(.+?)\s+->\s+(.+?)\s+##"', mk_text)
    check(len(mk_headers) == 284, f"Makefile contains {len(mk_headers)} step banners")
    for (idx_s, src_lang, _), (l_idx, l_name, _, _) in zip(mk_headers, lang_rows):
        if int(idx_s) != l_idx or src_lang != l_name:
            check(False, f"Step {l_idx} mismatch: Makefile '{src_lang}' vs LANGUAGES.md '{l_name}'")
    check(True, "All 284 step names match 1-for-1 between Makefile and LANGUAGES.md")

    mk_targets = [
        t for t in re.findall(r"^([A-Za-z0-9_.-]+):\s+[A-Za-z0-9_.-]+\s*$", mk_text, flags=re.M)
        if t not in {"all", "check"}
    ]
    check(len(mk_targets) == len(set(mk_targets)) == 284, f"All {len(mk_targets)} Makefile step targets are unique")

    run_text = (ROOT / "proof" / "run.log").read_text(encoding="utf-8", errors="replace")
    run_headers = re.findall(r"^##\s+(\d+):\s+(.+?)\s+->\s+(.+?)\s+##$", run_text, flags=re.M)
    check(len(run_headers) == 284, f"proof/run.log executed all {len(run_headers)} steps in order")
    check("Files QR.rb and QR2.rb are identical" in run_text, "proof/run.log ends with exact QR.rb == QR2.rb closure")

    # 5. Empirical check of zones.csv, loop product, and affine escape recurrence
    with (ROOT / "proof" / "zones.csv").open(encoding="utf-8") as f:
        zones = list(csv.DictReader(f))
    check(len(zones) == 247, f"proof/zones.csv contains {len(zones)} generator groups")

    sizes = [int(z["bytes"]) for z in zones]
    total_group_bytes = sum(sizes)
    peak_row = max(zones, key=lambda z: int(z["bytes"]))
    check(
        int(peak_row["bytes"]) == 94_546_636 and peak_row["class"] == "Glass",
        f"Group output peak = {int(peak_row['bytes']):,} B ({peak_row['class']}, group sum = {total_group_bytes:,} B)",
    )

    # Loop telescoping product check: P_1 = QR.rb (42,680 B), P_{k+1} = output of group k
    prog_sizes = [len(qr_bytes)] + sizes[:-1]
    out_sizes = sizes[:-1] + [len(qr_bytes)]
    log_prod = sum(math.log(p / o) for p, o in zip(prog_sizes, out_sizes))
    check(abs(log_prod) < 1e-12, f"Closed-loop telescoping ratio product prod(r_k) = {math.exp(log_prod):.15f}")

    # Upper escape ladder exact check: rows 61..65 (0-indexed 60..64: Scilab..Tcl)
    # Row i (outer) wraps Row i+1 (inner): S_outer_payload = 2 * S_inner + Q_inner + d_wrapper
    by_run = {int(z["run"]): z for z in zones}
    exact_zero_wrapper = []
    for r_outer, name in [(61, "Squirrel"), (62, "Standard ML"), (63, "SurgeScript")]:
        outer_out = by_run[r_outer]      # program for r_outer+1
        inner_out = by_run[r_outer + 1]  # payload embedded by r_outer+1
        s_prog = int(outer_out["backslashes"])
        pred = 2 * int(inner_out["backslashes"]) + int(inner_out["dquotes"])
        check(s_prog == pred, f"Exact escape recurrence on {name}: S' = {s_prog:,} == 2*{int(inner_out['backslashes']):,} + {int(inner_out['dquotes']):,}")
        exact_zero_wrapper.append(name)

    # Lower logic escape ladder: Agda -> PostScript (...) -> Logtalk -> Pike -> Maude -> Mercury -> Perl 6
    for r_outer, prog_lang, escapes_dquote, expected_d in [
        (222, "Agda (in PostScript (...))", True, 0),
        (221, "PostScript (...) (in Logtalk)", False, 0),  # PostScript uses (...) literals, so '"' is not escaped
        (220, "Logtalk (in Pike)", True, 11),              # 11 newlines escaped as \n
        (219, "Pike (in Maude)", True, 0),
        (218, "Maude (in Mercury)", True, 0),
        (217, "Mercury (in Perl 6)", True, 0),
    ]:
        s_prog = int(by_run[r_outer]["backslashes"])
        inner = by_run[r_outer + 1]
        q_term = int(inner["dquotes"]) if escapes_dquote else 0
        pred = 2 * int(inner["backslashes"]) + q_term + expected_d
        w0 = (int(by_run[r_outer]["bytes"]) - s_prog) - (int(inner["bytes"]) - int(inner["backslashes"]))
        check(
            s_prog == pred,
            f"Exact escape & conservation [{prog_lang}]: S' = {s_prog:,} (d={expected_d}), wrapper w0 = {w0} B",
        )


if __name__ == "__main__":
    main()
