#!/bin/bash
# usage: STEPS=/tmp/steps INTERP=/path/to/built/interpreters REPO=/path/to/quine-relay-284 ./rerun5.sh
S=${STEPS:?}; I=${INTERP:?}; W=${WORK:-/tmp/run5}; mkdir -p $W; cd $W
t(){ local n=$1 exp=$2; shift 2; local t0=$(date +%s); timeout 1700 "$@" < /dev/null > out.$n 2> err.$n; local rc=$?
 if cmp -s out.$n $exp; then r=MATCH; else r=DIFF; fi
 echo "$n rc=$rc $r out=$(wc -c < out.$n) exp=$(wc -c < $exp) $(( $(date +%s)-t0 ))s $(sha256sum out.$n|cut -c1-16)" >> results.txt; }
: > results.txt
cp $S/022.out QR.rail;  t rail   $S/021.out $I/rail/rail QR.rail
cp $S/021.out QR.kpl;   t kipple $S/020.out $I/cipple QR.kpl
cp $S/178.out QR.hxg;   t hexagony $S/177.out ruby $I/hexagony/interpreter.rb QR.hxg
cp $S/135.out QR.emmental; t emmental $S/134.out $I/Emmental/bin/emmental.exe QR.emmental
cp $S/019.out QR.glass; t glass-0.12 $S/018.out $I/glass012/glass-0.12/glass QR.glass
t glass.rb $S/018.out ruby ${REPO:?}/vendor/glass.rb QR.glass
echo DONE >> results.txt
