# Helper Tools

Small standalone utilities used alongside `src/`:

- `langs_png.py` — Renders `langs.png` (`284-Language Uroboros Quine`) using Python `pycairo` + `rsvg-convert` without needing the Ruby `cairo`/`rsvg2` gems.
- `dupcheck.rb` — Verifies that every `CodeGen` class in `src/code-gen.rb` uses a unique intermediate filename (`QR.*`) and unique class name so `make` never drops a dependency.
- `zonemap.rb` — Evaluates the composed relay in a single pass to emit `zones.csv` (bytes, backslashes, quotes, newlines, and max line length at every step).
- `squash-installs.rb` — Squashes consecutive `RUN` directives from `src/extra-installs/*.txt` into subshell-isolated layers so `Dockerfile` stays well below Docker's overlay2 max layer depth.
- `verify_invariants.py` — Mechanically audits `QR.rb`, `SHA256SUMS`, `LANGUAGES.md`, `Makefile`, `proof/run.log`, and `proof/zones.csv` (Tier-1/Tier-2 counts, strict `<= 3` family caps, closed-loop ratio product, and exact integer affine escape recurrences).
