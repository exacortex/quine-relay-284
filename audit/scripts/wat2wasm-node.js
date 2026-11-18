#!/usr/bin/env node
// minimal wat2wasm: wat2wasm IN.wat -o OUT.wasm
const fs=require('fs');const a=process.argv.slice(2);let i=a[0],o=null;
for(let k=0;k<a.length;k++){if(a[k]=='-o')o=a[++k];else if(!a[k].startsWith('-'))i=a[k];}
require('wabt')().then(w=>{const m=w.parseWat(i,fs.readFileSync(i,'utf8'));const b=m.toBinary({}).buffer;fs.writeFileSync(o||i.replace(/\.wat$/,'.wasm'),Buffer.from(b));});
