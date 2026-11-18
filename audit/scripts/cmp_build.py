import re,sys
df=open(sys.argv[1]).read()
# join continuation lines
df=re.sub(r'\\\n',' ',df)
ins=[]
for l in df.split('\n'):
    m=re.match(r'^(FROM|RUN|COPY|ADD|WORKDIR)\s+(.*)$',l)
    if m: ins.append((m.group(1)+' '+m.group(2)).strip())
log=open(sys.argv[2],errors='replace').read().split('\n')
steps={}
for l in log:
    m=re.match(r'^#\d+ \[ *(\d+)/(\d+)\] (.*)$',l)
    if m: steps.setdefault(int(m.group(1)),(int(m.group(2)),m.group(3).strip()))
print("dockerfile instrs:",len(ins),"log steps:",len(steps))
norm=lambda s:re.sub(r'\s+',' ',s)
bad=0
for i,s in enumerate(ins,1):
    t=steps.get(i)
    if not t: print("missing",i,s[:80]);bad+=1;continue
    if norm(t[1])!=norm(s):
        bad+=1; print("DIFF",i,"\n DF:",norm(s)[:150],"\n LOG:",norm(t[1])[:150])
print("mismatches:",bad)
