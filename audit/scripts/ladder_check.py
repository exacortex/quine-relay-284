"""Check the escape-ladder law b_out = 2*b_in + q_in + own on proof/zones.csv.
Row k of zones.csv is the text step k prints. A C-style escaping step k embeds
row k (its own output) as a string literal, so its program (row k-1) holds
2*b + q backslashes from the payload plus a few of its own."""
import csv, sys
Z = list(csv.DictReader(open(sys.argv[1])))
lo, hi = int(sys.argv[2]), int(sys.argv[3])   # inclusive run range, outer..inner
rows = {int(r['run']): r for r in Z}
print(f"{'run':>4} {'step (prints row above)':34} {'backslashes':>11} {'predicted 2b+q':>14} {'own':>5}")
for k in range(lo, hi + 1):
    r, inner = rows[k], rows[k + 1]
    b, bi, qi = int(r['backslashes']), int(inner['backslashes']), int(inner['dquotes'])
    pred = 2 * bi + qi
    print(f"{k:>4} {rows[k+1]['languages'][:34]:34} {b:>11,} {pred:>14,} {b-pred:>5}")
