import csv,os,sys
Z=list(csv.DictReader(open(sys.argv[1])))
D=sys.argv[2]
names={l.split()[1]:l.split()[0] for l in open(D+'/names.txt')}
mism=0
for r in Z:
    c=r['class']
    if c in names:
        b=os.path.getsize(f"{D}/{names[c]}.out")
        if b!=int(r['bytes']): mism+=1; print("MISMATCH",c,b,r['bytes'])
print("rows",len(Z),"dump-matched",sum(r['class'] in names for r in Z),"mismatches",mism)
Zs=sorted(Z,key=lambda r:-int(r['bytes']))
print("top payloads:")
for r in Zs[:8]: print(f"  run {r['run']:>3} {r['languages'][:40]:40} {int(r['bytes']):>12,}")
tot=sum(int(r['bytes']) for r in Z); print("sum of payloads",f"{tot:,}")
