# Proof: clean standalone build & full 284-step run, November 18, 2026

These are the exact uncached build log, step-by-step execution log, and payload profile from the clean Ubuntu 26.04 Docker verification backing [RECORDS.md](../RECORDS.md).

- **Environment:** Clean standalone `Dockerfile` build (`FROM ubuntu:26.04`, `--no-cache`), zero stand-ins.
- **Commands to reproduce from scratch:**
  ```sh
  docker build --no-cache -t qr284 .
  docker run --rm qr284
  ```
- **Result:** All **284 steps** (**273 distinct Tier-1 languages**) built cleanly from `ubuntu:26.04` and executed consecutively on their real compilers, assemblers, VMs, and interpreters. Step 284 (`REXX`) printed `QR2.rb`, `diff -s QR.rb QR2.rb` reported `Files QR.rb and QR2.rb are identical`, and `sha256sum --quiet -c SHA256SUMS` passed.
- **`QR.rb` size:** `42,680` bytes
- **SHA-256 of `QR.rb` and `QR2.rb`:** `9ce6dbe31564079cb8e7bec5830e06a02b8cb7c651b7a48e0f6970aaeceb509a`
- **Clean `docker build --no-cache` time:** `4,189 s` (**69 minutes 49 seconds**, zero cached layers)
- **Full 284-step verification lap time:** `2,377 s` (**39 minutes 37 seconds**)

| File | Contents |
|---|---|
| `RESULT.txt` | Generator summary, clean `--no-cache` build duration (`4189 s`), `PASSED` verdict, lap duration (`2377 s`), and finish timestamp |
| `build.log` | Complete uncached `docker build --no-cache --progress=plain -t qr284 .` output from `FROM ubuntu:26.04` |
| `run.log` | Complete step-by-step execution log (`1: Ruby -> SNOBOL4` through `284: REXX -> Ruby` + `diff -s QR.rb QR2.rb`) |
| `zones.csv` | Payload byte size, backslash/quote/newline counts, and max line length across all 247 `CodeGen` groups |
