# Proof: full 284-step run, November 17, 2026

These are the exact logs and payload profile from the Docker verification lap backing [RECORDS.md](../RECORDS.md).

- **Environment:** Docker on Ubuntu 26.04 (`Resolute Raccoon`), zero stand-ins.
- **Commands to reproduce from scratch:**
  ```sh
  docker build -t qr284 .
  docker run --rm qr284
  ```
- **Result:** All **284 steps** (272 distinct Tier-1 languages) executed consecutively on their real compilers, assemblers, VMs, and interpreters. Step 284 (`REXX`) printed `QR2.rb`, `diff -s QR.rb QR2.rb` reported `Files QR.rb and QR2.rb are identical`, and `sha256sum --quiet -c SHA256SUMS` passed.
- **`QR.rb` size:** `40,660` bytes
- **SHA-256 of `QR.rb` and `QR2.rb`:** `f6c73b482c42d99c696a527d300d0b52f8789e56dd504341dc8a6ea36f8c228a`
- **Verification lap time:** `2,279 s` (**37 minutes 59 seconds**)

| File | Contents |
|---|---|
| `RESULT.txt` | Generator summary, `PASSED` verdict, lap duration (`2279 s`), and finish timestamp |
| `build.log` | Docker image build output |
| `run.log` | Complete step-by-step execution log (`1: Ruby -> SNOBOL4` through `284: REXX -> Ruby` + `diff -s QR.rb QR2.rb`) |
| `zones.csv` | Payload byte size, backslash/quote/newline counts, and max line length across all 247 `CodeGen` groups |
