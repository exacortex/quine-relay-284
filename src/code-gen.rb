# A source for generating Quine Relay

GenStep = Struct.new(:name, :code, :run_steps, :check)
RunStep = Struct.new(:name, :src, :cmd_make, :cmd_raw, :backup, :apt)

# properly nested delimiters
PARENS   = /\A(?<b>[^()]*+(?:\(\g<b>\)[^()]*+)*+)\z/
BRACKETS = /\A(?<b>[^\[\]]*+(?:\[\g<b>\][^\[\]]*+)*+)\z/

# A class that generates Ruby code that generates a code (in a language X) that prints PREV.
class CodeGen
  # File = source file name of X
  # Cmd = command for execution/compilation
  # Apt = ubuntu package name of the interpreter/compiler of X

  List = []
  def self.inherited(c)
    List << c
  end

  def self.gen_step
    gen = new
    GenStep[name, gen.code, run_steps, gen.method(:check).to_proc]
  end

  def code
    self.class::Code
  end

  # check if PREV satisfies the assumption of the CodeGen
  def check(prev)
  end

  # The same escaping as e[] of GenPrologue, for check
  def escape(s)
    s.gsub(/[\\"]/) { "\\" + $& }.gsub("\n", "\\n")
  end

  def self.run_steps
    a = []
    a << (defined?(self::Name) ? [*self::Name] : self.to_s.split("_"))
    a << [*self::File]
    a << [*self::Cmd]
    a << (defined?(self::Backup) ? [*self::Backup] : [*self::Cmd].map { nil })
    a << [*self::Apt]
    a.transpose.map do |name, src, cmd_make, backup, apt|
      cmd_raw = cmd_make
      cmd_raw = cmd_raw.gsub("$(SCHEME)", "guile")
      cmd_raw = cmd_raw.gsub("$(JAVASCRIPT)", "nodejs")
      cmd_raw = cmd_raw.gsub("$(CC)", "gcc")
      cmd_raw = cmd_raw.gsub("$(CXX)", "g++")
      cmd_raw = cmd_raw.gsub("$(GBS)", "gbs3")
      RunStep[name, src, cmd_make, cmd_raw, backup, apt]
    end
  end
end

# Common part
GenPrologue = <<-'END'.lines.map {|l| l.strip }.join
  B=92.chr;
  g=32.chr;
  N=10.chr;
  n=0;
  e=->s{Q[Q[s,B],?"].gsub(N,B+?n)};
  E=->s{'("'+e[s]+'")'};
  d=->s,t=?"{s.gsub(t){t+t}};
  def f(s,n)s.gsub(/.{1,#{n*255}}/m){yield$S=E[$s=$&]}end;
  Q=->s,t=?${s.gsub(t){B+$&}};
  R=";return 0;";
  V=->s,a,z{s.gsub(/(#{B*4})+/){a+"#{$&.size/2}"+z}};
  C=%w(System.Console Write);
  $C=C*?.;
  $D="program QR";
  $L="public static";
  $W="s.WriteByte";
  rp=->s,r{
    v="";
    [r.inject(s){|s,j|
      o={};
      m=n=0;
      s.size.times{|i|
        o[f=s[i,2]]||=0;
        c=o[f]+=1;
        m<c&&(m=c;n=f)
      };
      v=n+v;
      s.gsub(n,(j%256).chr)
    },v]
  };
END
# rp: Re-Pair (Naive byte pair encoding)


# RUN_AFTER: Promela
# RUN_AFTER: Rail
# RUN_AFTER: Kipple
# RUN_AFTER: Beatnik
# RUN_AFTER: Glass
# RUN_AFTER: Taxi
# RUN_AFTER: DeadfishTilde
# RUN_AFTER: Lout
# RUN_AFTER: PlainTeX
# RUN_AFTER: MetaPost
# RUN_AFTER: Inform6
# RUN_AFTER: Ink
# RUN_AFTER: TADS3
# RUN_AFTER: Uxntal
# RUN_AFTER: MMIX
# RUN_AFTER: Asm6502
# RUN_AFTER: ARM64Asm
# RUN_AFTER: Z80Asm
# RUN_AFTER: RISCVAsm
# RUN_AFTER: BeanShell_Befunge_BLC8_Brainfuck
# RUN_AFTER: Ksh_LazyK_LiveScript
class Python_R_Ratfor_Rc_REXX < CodeGen
  Name = ["Python", "R", "Ratfor", "rc", "REXX"]
  File = ["QR.py", "QR.R", "QR.ratfor", "QR.rc", "QR.rexx"]
  Cmd = [
    "python3 QR.py > OUTFILE",
    "R --slave -f QR.R > OUTFILE",
    "ratfor -o QR.ratfor.f QR.ratfor && gfortran -o QR QR.ratfor.f && ./QR > OUTFILE",
    "rc QR.rc > OUTFILE",
    "rexx ./QR.rexx > OUTFILE"
  ]
  Apt = ["python3", "r-base", "ratfor", "rc", "regina-rexx"]
  Code = %q(%(a=[];b=[]#{N}for l in#{E[d[d[PREV,?'],?']]}.split("#{B}n"):#{N} for c in"echo 'say ''%s'''#{B}n"%l:b.append("r=fput(char(%d))"%ord(c));len(b)>200 and(a.append(b),b:=[])#{N}if b:a.append(b)#{N}for i,g in enumerate(a):print("cat(#{B}"subroutine s%d#{B}#{B}n"%i+"#{B}#{B}n".join(g)+"#{B}#{B}nend#{B}#{B}n#{B}")")#{N}for i in range(len(a)):print("cat(#{B}"call s%d#{B}#{B}n#{B}")"%i)#{N}print("cat(#{B}"end#{B}#{B}n#{B}")")#))

  def check(prev)
    raise unless prev.bytes.all? {|c| c < 128 }
  end
end

class Ksh_LazyK_LiveScript < CodeGen
  Name = ["ksh", "Lazy K", "LiveScript"]
  File = ["QR.ksh", "QR.lazy", "QR.ls"]
  Cmd = [
    "ksh QR.ksh > OUTFILE",
    "lazyk QR.lazy > OUTFILE",
    "lsc QR.ls > OUTFILE",
  ]
  Apt = ["ksh", nil, "livescript"]
  Backup = [nil, nil, "QR.c"]
  def code
    lazyk = ::File.read(::File.join(__dir__, "lazyk-boot.dat"))
    lazyk = lazyk.tr("ski`","0123")
    lazyk += "0" * (-lazyk.size % 3)
    lazyk = lazyk.scan(/.{3}/).map do |n|
      [*93..124,*42..73][n.to_i(4)]
    end.pack("C*")
    lazyk = lazyk.gsub(/[ZHJK\^`~X]/) {|c| "\\x%02x" % c.ord }
    <<-'END'.lines.map {|l| l.strip }.join.sub("LAZYK"){lazyk}
      %(
        p(){ print -rn -- "$1";};
        f(){ for x in $(p "$1"|od -vAn -tu1);do;
            p $4;
            for((j=$3;j--;));do;
              h $2 $x $j;
            done;
          done;
        };
        p k\\`;
        h(){ p \\`${1:$2>>$3&1:2};};
        f 'console.log#{Q[E[PREV],?#].gsub(?',%('"'"'))}' kki 7 '#{"``s"*8}i';
        h(){ p ${1:$2%83-10>>$3*2&3:1};};
        f 'LAZYK' ski\\` 3
      )
    END
  end

  def check(prev)
    raise unless prev.ascii_only?
  end
end

class BeanShell_Befunge_BLC8_Brainfuck < CodeGen
  File = ["QR.bsh", "QR.bef", "QR.Blc", "QR.bf"]
  Cmd = [
    "bsh QR.bsh > OUTFILE",
    "cfunge QR.bef > OUTFILE",
    "ruby vendor/blc.rb < QR.Blc > OUTFILE",
    "ruby vendor/bf.rb QR.bf > OUTFILE",
  ]
  Apt = ["bsh", nil, nil, nil]
  def code
    blc = ::File.read(::File.join(__dir__, "blc-boot.dat"))
    <<-'END'.lines.map {|l| l.strip }.join.sub("BLC", [blc].pack("m0"))
      %(
        f(s){System.out.print(s);}
        s="ef*c+45*,";
        for(c:#{E[PREV]}){
          s+="d9+,";
          for(m=1;m<256;m*=2)
            s+="d9+,4,:"+c/m%2*4+"+,";
          f(s);
          s="4,:,";
        }
        f(s+s);
        for(c:Base64.getDecoder().decode("BLC")){
          c&=255;
          f(""+c%8+c/8%8+c/64+"8*+8*+,");
        }
        f("@");
      )
    END
  end

  def check(prev)
    raise unless prev.ascii_only?
  end
end

class RISCVAsm < CodeGen
  Name = "RISC-V asm"
  File = "QR.rv.s"
  Cmd = "rm -f QR && riscv64-linux-gnu-gcc -nostdlib -static -o QR QR.rv.s && qemu-riscv64 ./QR > OUTFILE && rm -f QR"
  Apt = [["gcc-riscv64-linux-gnu", "qemu-user"]]
  Code = %q((b18z=(PREV);".global _start\n.text\n_start:\n li a0, 1\n la a1, msg\n li a2, #{b18z.bytesize}\n li a7, 64\n ecall\n li a0, 0\n li a7, 93\n ecall\n.data\nmsg:\n"+b18z.scan(/[\x20\x21\x23-\x5b\x5d-\x7e]{1,60}|./m).map{|b18r|b18r=="\x22"||b18r==B||b18r==N ? ".byte #{b18r.ord}" : %(.ascii "#{b18r}")}*N+N))
  def check(prev)
    raise "RISC-V asm: bad byte" if !prev.ascii_only? || prev =~ /[\x00-\x09\x0b-\x1f\x7f]/
  end
end

class Z80Asm < CodeGen
  Name = "Z80 asm"
  File = "QR.z80"
  Cmd = "z80asm QR.z80 -o QR.z80.bin && python3 vendor/runz80.py QR.z80.bin > OUTFILE"
  Apt = "z80asm"
  Code = %q((b18u,b18y=rp[PREV,128..255];b18q=b18y.scan(/../m).reverse;b18g=b18q.map{|b18x|b18x.getbyte(0)};b18h=b18q.map{|b18x|b18x.getbyte(1)};" org 0\n ld sp, 0ffffh\n ld hl, msg\nloop:\n ld a, (hl)\n or a\n jr z, done\n call emit\n inc hl\n jr loop\ndone:\n halt\nemit:\n cp 128\n jr nc, pair\n out (1), a\n ret\npair:\n sub 128\n ld e, a\n ld d, 0\n push hl\n ld hl, dict1\n add hl, de\n ld b, (hl)\n push bc\n ld hl, dict0\n add hl, de\n ld a, (hl)\n call emit\n pop af\n pop hl\n jp emit\ndict0:\n"+b18g.each_slice(32).map{|b18a|" db "+b18a*","}*N+"\ndict1:\n"+b18h.each_slice(32).map{|b18a|" db "+b18a*","}*N+"\nmsg:\n"+(b18u.bytes+[0]).each_slice(32).map{|b18a|" db "+b18a*","}*N+N))
  def check(prev)
    raise "Z80 asm: NUL or non-ASCII" if prev.include?("\0") || !prev.ascii_only?
  end
end

class ARM64Asm < CodeGen
  Name = "ARM64 asm"
  File = "QR.arm64.s"
  Cmd = "rm -f QR && aarch64-linux-gnu-gcc -nostdlib -static -o QR QR.arm64.s && qemu-aarch64 ./QR > OUTFILE && rm -f QR"
  Apt = [["gcc-aarch64-linux-gnu", "qemu-user"]]
  Code = %q(".global _start\n.text\n_start:\n mov x0, #1\n ldr x1, =msg\n ldr x2, =len\n mov x8, #64\n svc #0\n mov x0, #0\n mov x8, #93\n svc #0\n.data\nmsg:\n"+(PREV).scan(/[\x20\x21\x23-\x5b\x5d-\x7e]{1,60}|./m).map{|b18n|b18n=="\x22"||b18n==B||b18n==N ? ".byte #{b18n.ord}" : %(.ascii "#{b18n}")}*N+"\n.equ len, . - msg\n")
  def check(prev)
    raise "ARM64 asm: bad byte" if !prev.ascii_only? || prev =~ /[\x00-\x09\x0b-\x1f\x7f]/
  end
end

class Asm6502 < CodeGen
  Name = "6502 asm"
  File = "QR.s65"
  Cmd = "xa -o QR.o65 QR.s65 && python3 vendor/run6502.py QR.o65 > OUTFILE"
  Apt = "xa65"
  Code = %q((b18t,b18w=rp[PREV,128..255];b18p=b18w.scan(/../m).reverse;b18e=b18p.map{|b18x|b18x.getbyte(0)};b18f=b18p.map{|b18x|b18x.getbyte(1)};"* = $0200\n lda #<msg\n sta 0\n lda #>msg\n sta 1\nloop:\n ldy #0\n lda (0),y\n beq done\n jsr emit\n inc 0\n bne loop\n inc 1\n jmp loop\ndone:\n brk\nemit:\n cmp #128\n bcs pair\n sta $f001\n rts\npair:\n sec\n sbc #128\n tax\n lda dict1,x\n pha\n lda dict0,x\n jsr emit\n pla\n jmp emit\ndict0:\n"+b18e.each_slice(32).map{|b18a|" .byt "+b18a*","}*N+"\ndict1:\n"+b18f.each_slice(32).map{|b18a|" .byt "+b18a*","}*N+"\nmsg:\n"+(b18t.bytes+[0]).each_slice(32).map{|b18a|" .byt "+b18a*","}*N+N))
  def check(prev)
    raise "6502 asm: NUL or non-ASCII" if prev.include?("\0") || !prev.ascii_only?
  end
end

class MMIX < CodeGen
  Name = "MMIX"
  File = "QR.mms"
  Cmd = "mmixal -b 2000000 -o QR.mmo QR.mms && mmix QR.mmo > OUTFILE && rm -f QR.mmo"
  Apt = [nil]
  Code = %q(" LOC #100\nMain GETA $255,S\n TRAP 0,Fputs,StdOut\n SET $255,0\n TRAP 0,Halt,0\nS BYTE "+(PREV).scan(/[\x20\x21\x23-\x7e]{1,60}|./m).map{|b18m|b18m=="\x22"||b18m==N ? b18m.ord : %("#{b18m}")}.join("\n BYTE ")+",0\n")
  def check(prev)
    raise "MMIX: bad byte" if !prev.ascii_only? || prev =~ /[\x00-\x09\x0b-\x1f\x7f]/
  end
end

class Uxntal < CodeGen
  Name = "Uxntal"
  File = "QR.tal"
  Cmd = "uxnasm QR.tal QR.rom && uxncli QR.rom > OUTFILE && rm -f QR.rom"
  Apt = [nil]
  Code = %q((b18s,b18v=rp[PREV,128..255];b18d=b18v.scan(/../m).reverse*"";"|0100 ;s @loop LDAk DUP #00 EQU ;done #{74.chr}CN2 ;emit #{74.chr}SR2 INC2 ;loop #{74.chr}MP2 @done POP POP2 #800f DEO BR#{75.chr} @emit DUP #80 LTH ;out #{74.chr}CN2 #80 SUB #00 SWP DUP2 ADD2 ;dict ADD2 LDAk ;emit #{74.chr}SR2 INC2 LDA ;emit #{74.chr}MP2 @out #18 DEO #{74.chr}MP2r\n@dict\n"+b18d.unpack1(72.chr+"*").scan(/../).each_slice(32).map{|b18a|b18a*" "}*N+"\n@s\n"+b18s.unpack1(72.chr+"*").scan(/../).each_slice(32).map{|b18a|b18a*" "}*N+" 00\n"))
  def check(prev)
    raise "Uxntal: NUL or non-ASCII" if prev.include?("\0") || !prev.ascii_only?
  end
end

class TADS3 < CodeGen
  Name = "TADS 3"
  File = "QR.t3.t"
  Cmd = "rm -f QR.out QR.t3 && t3make -q -a -FI /usr/share/frobtads/tads3/include -FI /usr/local/share/frobtads/tads3/include -FL /usr/share/frobtads/tads3/lib -FL /usr/local/share/frobtads/tads3/lib -o QR.t3 system.tl QR.t3.t && frob -i plain -p -s0 QR.t3 >/dev/null && cat QR.out > OUTFILE && rm -f QR.out QR.t3"
  Apt = [nil]
  Code = %q((b17a=(PREV);b17b={":"=>":e","\x20"=>":s","\x22"=>":q",B=>":b","\x27"=>":a",N=>":n","\x09"=>":d","\x7e"=>":t","\x5e"=>":c","@"=>":m","|"=>":p","["=>":o","]"=>":k","<"=>":l",">"=>":g","="=>":v","+"=>":u","-"=>":h","*"=>":x","/"=>":f","#"=>":r","{"=>":i","}"=>":j"};b17r=[];b17w="";b17a.each_char{|b17c|b17t=b17b[b17c]||b17c;if b17w.size+b17t.size>229 then b17r<<"p(\x27"+b17w+"\x27);";b17w=b17t else b17w+=b17t end};b17r<<"p(\x27"+b17w+"\x27);" if b17w.size>0;b17m=->b17s{b17s.scan(/.../).map{|b17u|"\x27:"+b17u[0]+"\x27,\x27"+B+"x"+b17u[1,2]+"\x27"}*","};["#include <tads.h>","#include <file.h>","o:object f=nil m=["+b17m["q22b5ca27t7ec5ep7co5bk5dm40l3cg3ed09"]+",",b17m["s20v3du2bh2dx2af2fr23i7bj7d"]+",\x27:n\x27,\x27"+B+"n\x27,\x27:e\x27,\x27:\x27];","p(s){for(local i=1;i<47;i+=2)s=s.findReplace(o.m[i],o.m[i+1],ReplaceAll);o.f.writeFile(s);}","main(a){o.f=File.openTextFile(\x27QR.out\x27,FileAccessWrite,\x27us-ascii\x27);",*b17r,"o.f.closeFile();}"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class Ink < CodeGen
  Name = "Ink"
  File = "QR.ink"
  Cmd = "inklecate -p QR.ink > OUTFILE"
  Apt = [nil]
  Code = %q((PREV).lines.map{|b17h|b17h.chomp.gsub(/[\\\\{}|\x7e#\/\-<*+=]|(?:\A\x20)|(?:\x20\z)/){B+$&}}.join(N)+N+"-> END\n")

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.include?("\r")
    raise "Ink: >1250 lines risks inklecate sleep" if prev.lines.size > 1250
  end
end

class Inform6 < CodeGen
  Name = "Inform 6"
  File = "QR.inf"
  Cmd = "rm -f QR.z8 && inform6 -v8 QR.inf QR.z8 >/dev/null && dfrotz -m -q -r cm -w 240 -h 200 QR.z8 | tail -n +2 > OUTFILE && rm -f QR.z8"
  Apt = "inform6-compiler"
  Code = %q((b17j=(PREV).scan(/[\x20\x21\x23-\x3f\x41-\x5b\x5f-\x7d]{1,60}|./m).map{|b17t|(b17t.size>1||("\x22]\x7e\x5e@"+B+N).index(b17t)==nil) ? ("\x22"+b17t+"\x22") : b17t==N ? "\x22\x5e\x22" : "(char)#{b17t.ord}"};b17k=[];b17q="";b17j.each{|b17u|b17x=(b17q.empty? ? "print "+b17u : b17q+","+b17u);if b17q.size>0&&(b17x.size>95||b17x.size+b17x.count("\x22")*10>180) then b17k<<(b17q+";");b17q="print "+b17u else b17q=b17x end};b17k<<(b17q+";") if b17q.size>0;b17m=[];b17n=[];b17k.each_slice(30).with_index{|b17g,b17i|b17m<<"R#{b17i}();";b17n<<"[R#{b17i};\n"+b17g.join(N)+"\n];"};b17n<<"[Main;\n"+b17m.each_slice(8).map{|b17g|b17g.join}.join(N)+"\nquit;];\n";b17n.join(N)))

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.include?("\r")
    raise if prev.lines.any? { |l| l.chomp.empty? || l.chomp.end_with?(" ") || l.chomp.size > 235 }
  end
end

class MetaPost < CodeGen
  Name = "MetaPost"
  File = "QR.mp"
  Cmd = "rm -f QR.out QR.log && mpost -interaction=batchmode QR.mp >/dev/null && cat QR.out > OUTFILE && rm -f QR.out QR.log"
  Apt = "texlive-metapost"
  Code = %q("string o;o:=\"QR.out\";\n"+(PREV).lines.map{|b17d|"write \""+b17d.chomp.gsub(/[\x22\\\\|\[\]]/){"\"&char "+$&.ord.to_s+"&\""}+"\" to o;"}.join(N)+"\nwrite EOF to o;end.\n")

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.lines.any? { |l| l.size > 120 }
  end
end

class PlainTeX < CodeGen
  Name = "Plain TeX"
  File = "QR.tex"
  Cmd = "rm -f QR.out QR.log && tex -interaction=batchmode QR.tex >/dev/null && cat QR.out > OUTFILE && rm -f QR.out QR.log"
  Apt = "texlive-binaries"
  Code = %q([B+"newwrite"+B+"f"+B+"immediate"+B+"openout"+B+"f=QR.out",B+"catcode124=0"+B+"catcode91=1"+B+"catcode93=2","|catcode92=12|catcode123=12|catcode125=12|catcode36=12|catcode38=12","|catcode35=12|catcode94=12|catcode95=12|catcode126=12|catcode37=12|catcode32=12",*(PREV).lines.map{|b17e|"|immediate|write|f["+b17e.chomp+"]"},"|immediate|closeout|f|end"].join(N)+N)

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev =~ /[|\[\]\r]/
  end
end

class Lout < CodeGen
  Name = "Lout"
  File = "QR.lout"
  Cmd = "lout -s -p6p12p QR.lout 2>/dev/null | tr -d '\\014' | grep . > OUTFILE"
  Apt = [nil]
  Code = %q((b17f=(PREV).lines;["@SysInclude { langdefs } @SysInclude { bsf }","@SysInclude { dsf } @SysInclude { docf }","@Use { @BasicSetup @InitialFont { Courier Base 10p }","@InitialBreak { lines 1fx nohyphen } @InitialSpace { lout } }","@Use { @DocumentSetup @PageWidth { 250s } @PageHeight { 60f }","@TopMargin { 0f } @FootMargin { 0f }","@OddLeftMargin { 0s } @OddRightMargin { 0s }","@EvenLeftMargin { 0s } @EvenRightMargin { 0s }","@PageHeaders { None } } @Use { @OrdinarySetup }","@SysDatabase @FontDef { fontdefs }","@Document","//","@Text @Begin",*b17f.map{|b17g|"\x22"+b17g.chomp.gsub(/[\\\\\x22]/){B+$&}+"\x22"}.each_slice(40).map{|b17s|b17s.join(N)}.join(N+"@NP"+N),"@End @Text"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.include?("\r")
    raise if prev.lines.any? { |l| l.chomp.empty? || l.chomp.end_with?(" ") || l.chomp.size > 240 }
  end
end

class DeadfishTilde < CodeGen
  Name = "Deadfish~"
  File = "QR.dft"
  Cmd = "ruby vendor/deadfish_tilde.rb QR.dft > OUTFILE"
  Apt = [nil]
  Code = %q((PREV).bytes.map{|b20d|"i"*b20d+"c"+"d"*b20d}*"")
  def check(prev)
    raise "Deadfish~: NUL or non-ASCII" if prev.include?("\0") || !prev.ascii_only?
  end
end

class Taxi < CodeGen
  Name = "Taxi"
  File = "QR.taxi"
  Cmd = "taxi QR.taxi > OUTFILE"
  Apt = [nil]
  Code = %q(%("#{PREV}" is waiting at the Writer\x27s Depot. Go to Writer\x27s Depot: west 1st left, 2nd right, 1st left, 2nd left. Pickup a passenger going to the Post Office. Go to the Post Office: north 1st right, 2nd right, 1st left. Go to the Taxi Garage: north 1st right, 1st left, 1st right.))
  def check(prev)
    raise "Taxi: quote or backslash or newline" if prev.index(34.chr) || prev.index(92.chr) || prev.index(10.chr)
  end
end

class Glass < CodeGen
  Name = "Glass"
  File = "QR.glass"
  Cmd = "ruby vendor/glass.rb QR.glass > OUTFILE"
  Apt = [nil]
  Code = %q((b20u=(PREV);b20m=b20u[/\A\x22[icd]+/];b20s=b20m[1..].scan(/i+c/).map{|b20x|(b20x.size-1).chr}*"";b20h={"\x7e"=>"\x7e\x7e","\x22"=>"\x7eq",B=>"\x7eb",N=>"\x7en","["=>"\x7el","]"=>"\x7er"};b20e=b20s.gsub(/[\x7e\x22\\\\\n\[\]]/){b20h[$&]};b20t=b20u[b20m.size+1..];"{M[m(_o)O\x21(_s)S\x21(_a)A\x21(q)<34>(_s)(ns).?=(p)\x22#{b20e}\x22=(q)*(_o)o.?(n)(p)*(_s)l.?=(i)<0>=/n(b)(p)*(i)*(_s)i.?(_s)(sn).?=(e)(b)*<126>(_a)e.?=/e(i)(i)*<1>(_a)a.?=(n)(n)*<1>(_a)s.?=(c)(p)*(i)*(_s)i.?(_s)(sn).?=(f)(c)*<113>(_a)e.?=/f(b)<34>=(f)<0>=#{B}(f)(c)*<98>(_a)e.?=/f(b)<92>=(f)<0>=#{B}(f)(c)*<110>(_a)e.?=/f(b)<10>=(f)<0>=#{B}(f)(c)*<108>(_a)e.?=/f(b)<91>=(f)<0>=#{B}(f)(c)*<114>(_a)e.?=/f(b)<93>=(f)<0>=#{B}(e)<0>=#{B}(d)(b)*=/b\x22i\x22(_o)o.?(b)(b)*<1>(_a)s.?=#{B}\x22c\x22(_o)o.?/d\x22d\x22(_o)o.?(d)(d)*<1>(_a)s.?=#{B}(i)(i)*<1>(_a)a.?=(n)(n)*<1>(_a)s.?=#{B}(q)*(_o)o.?\x22#{b20t}\x22(_o)o.?]}"))
  def check(prev)
    raise "Glass: unexpected Taxi" unless prev.start_with?(34.chr)
  end
end

class Beatnik < CodeGen
  Name = "Beatnik"
  File = "QR.beatnik"
  Cmd = "ruby vendor/beatnik.rb QR.beatnik > OUTFILE"
  Apt = [nil]
  Code = %q((PREV).bytes.map{|b20b|"#{75.chr} #{"E"*b20b} #{74.chr}A "}*""+"#{74.chr}AC#{75.chr}")
  def check(prev)
    raise "Beatnik: NUL or non-ASCII" if prev.include?("\0") || !prev.ascii_only?
  end
end

class Kipple < CodeGen
  Name = "Kipple"
  File = "QR.kpl"
  Cmd = "cipple QR.kpl > OUTFILE"
  Apt = [nil]
  Code = %q((b20s=(PREV).scan(/E+/).map{|b20x|b20x.size.chr}*"";b20p=b20s.scan(/[\x00-\x09\x0b-\x21\x23-\x5a\x5e-\x7f]+|./m).map{|b20c|b20c.size==1&&"\x0a\x22\x5b\x5c\x5d".index(b20c) ? "#{b20c.ord}>i" : "i<\x22#{b20c}\x22"}*" ";"75>o 67>o 65>o 74>o #{b20p} (i i>b 32>o 65>o 74>o 32>o (b 69>o b-1 b?) 32>o 75>o)"))
  def check(prev)
    raise "Kipple: unexpected Beatnik" unless prev.end_with?("JACK")
  end
end

class Rail < CodeGen
  Name = "Rail"
  File = "QR.rail"
  Cmd = "rail QR.rail > OUTFILE"
  Apt = [nil]
  Code = %q(%($ 'main'#{N} #{B}#{N}  #{B}-[#{(PREV)}]o#))
  def check(prev)
    raise "Rail: bracket or backslash or newline" if prev.index(92.chr) || prev.index("[") || prev.index("]") || prev.index(10.chr)
  end
end

class Promela < CodeGen
  Name = "Promela (Spin)"
  File = "QR.pr"
  Cmd = "spin -T QR.pr > OUTFILE"
  Apt = "spin"
  Code = %q("init{#{f(PREV,6){"printf#{d[$S,?%]};"}}}")

  def check(prev)
    # spin appends "1 process created" to stdout on the same line, and the "#" comments it out
    raise unless prev.end_with?(?#)
  end
end

# RUN_AFTER: Prolog
class ACL2 < CodeGen
  Name = "ACL2"
  File = "QR.acl2"
  Cmd = "acl2 < QR.acl2 > /dev/null && cat QR_acl2.out > OUTFILE"
  Apt = "acl2"
  Code = %q(%((mv-let (c state) (open-output-channel "QR_acl2.out" :character state) (let ((state (princ$ "#{Q[Q[PREV,B],?"]}" c state))) (close-output-channel c state)))\n))
  def check(prev)
    raise "ACL2: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Prolog < CodeGen
  File = "QR.prolog"
  Cmd = "swipl -q -t qr -f QR.prolog > OUTFILE"
  Apt = "swi-prolog"
  Code = %q("qr:-write#{E[PREV]}.")
end

# RUN_AFTER: PostScript
class Agda < CodeGen
  Name = "Agda"
  File = "QR.agda"
  Cmd = "agda --compile --compile-dir=agda_out QR.agda > /dev/null && ./agda_out/QR > OUTFILE"
  Apt = "agda"
  Code = %q(%(module QR where\nopen import Agda.Builtin.IO\nopen import Agda.Builtin.String\npostulate\n Unit : Set\n putStr : String -> IO Unit\n{-# COMPILE GHC Unit = type () #-}\n{-# FOREIGN GHC import qualified Data.Text.IO #-}\n{-# COMPILE GHC putStr = Data.Text.IO.putStr #-}\nmain : IO Unit\nmain = putStr "#{e[PREV]}"\n))
  def check(prev)
    raise "Agda: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class PostScript < CodeGen
  Name = "PostScript"
  File = "QR.ps"
  Cmd = "gs -dNODISPLAY -q QR.ps > OUTFILE"
  Apt = "ghostscript"
  Code = %q("(#{Q[PREV,B]})print quit")

  def check(prev)
    # a PostScript (...) literal counts nested parens, and only the backslash is escaped here
    raise unless prev.match?(PARENS)
  end
end

# RUN_AFTER: Pike
# Logtalk (on SWI-Prolog, already in the relay): a Logtalk object whose initialization turns a double-quoted
# text (escapes \\ \" and \\n) into an atom and writes it. One line.
class Logtalk < CodeGen
  Name = "Logtalk"
  File = "QR.lgt"
  Cmd = "swilgt -q -g \"logtalk_load('QR.lgt'),halt\" < /dev/null > OUTFILE"
  Apt = [nil]                # release .deb, see installs.txt
  Code = %q(%(:- object(qr). :- initialization((atom_codes(A,"#{e[PREV]}"),write(A),halt)). :- end_object.))
  def check(prev)
    raise "Logtalk: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Pike < CodeGen
  File = "QR.pike"
  Cmd = "pike QR.pike > OUTFILE"
  Apt = "pike8.0"
  Code = %q("int main(){write#{E[PREV]};}")

  def check(prev)
    # the Piet image reads a byte as a column height, and Perl 5's Re-Pair takes 0-31 and 128-255
    raise unless prev.bytes.all? {|c| c == 10 || (0x20..0x7e).cover?(c) }
  end
end



# RUN_AFTER: Perl5
# Merge patch (milestone 212): Rakudo (2024.09) parses a '...' literal with escapes in quadratic time: 20 KB took 39 s,
# 40 KB 150 s, 80 KB over 5 min. That was the slow Perl 6 step in the B09 lap and the stuck B10 lap. A raw Q[[[...]]]
# literal has no escapes at all: the merged 243 KB payload prints in about 1 s (checked byte for byte), and the source
# no longer doubles every backslash, so every step upstream gets smaller too.
# RUN_AFTER: Perl6
# Merge patch (milestone 284): PHP_Piet moved to RISCVAsm (~39 KB), so Maude anchors directly after Perl6.
# Maude strings escape \ " and newline (\n). Maude prints its own result lines on stdout, so the program
# writes the payload through Maude's FILE objects (-allow-files, FILE module loaded from Maude's own lib by the 'file' argument) into QR_maude.out.
# One line: stdin is /dev/null so Maude exits after the erewrite; the Cmd copies that
# file (same pattern as mame's BASIC step and B09's ACL2).
class Maude < CodeGen
  Name = "Maude"
  File = "QR.maude"
  Cmd = "maude -no-banner -no-advise -allow-files file QR.maude < /dev/null > /dev/null && cat QR_maude.out > OUTFILE"
  Apt = "maude"
  Code = %q(%(mod QR is including FILE . op Me : -> Oid . op C : -> Cid . op init : -> Configuration . var F : Oid . eq init = <> < Me : C | none > openFile(fileManager, Me, "QR_maude.out", "w") . rl openedFile(Me, fileManager, F) < Me : C | none > => < Me : C | none > write(F, Me, "#{e[PREV]}") . rl wrote(Me, F) < Me : C | none > => < Me : C | none > closeFile(F, Me) . endm erew init .))
  def check(prev)
    raise "Maude: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

# RUN_AFTER: Perl6
# Mercury strings escape \ " and newline (\n), like C.
class Mercury < CodeGen
  Name = "Mercury"
  File = "qr_mercury.m"
  Cmd = "mmc --make qr_mercury > /dev/null && ./qr_mercury > OUTFILE"
  Apt = [nil]                # see installs.txt
  Code = %q(%(:- module qr_mercury. :- interface. :- import_module io. :- pred main(io::di, io::uo) is det. :- implementation. main(!IO) :- io.write_string("#{e[PREV]}", !IO).))
  def check(prev)
    raise "Mercury: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Perl6 < CodeGen
  Name = "Perl 6"
  File = "QR.pl6"
  Cmd = "perl6 QR.pl6 > OUTFILE"
  Apt = "rakudo"
  # the delimiters are built as ?[*3 / ?]*3 so QR.rb's own source (which every payload contains) never holds them
  Code = %q("print Q#{?[*3}#{PREV}#{?]*3}")

  def check(prev)
    # it goes raw into Q[[[...]]], and Perl 5's Re-Pair takes bytes 0-31 and 128-255
    raise unless prev.bytes.all? {|c| (0x20..0x7e).cover?(c) }
    raise if prev.include?("[[[") || prev.include?("]]]") || prev.start_with?("[") || prev.end_with?("]")
  end
end

class Perl5 < CodeGen
  Name = "Perl 5"
  File = "QR.pl"
  Cmd = "perl QR.pl > OUTFILE"
  Apt = "perl"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      (
        p="eval";
        %(
          $_="#{
            s,v=rp[PREV,128..287];
            ["
              $_='#{Q[s,c=/['\\\\]/]}';
              $n=32;
              for$a(unpack'(a2)*','#{Q[v,c]}'){
                $b=chr(--$n&255);
                s/$b/$a/g
              }
              print
            "].pack("u").tr(" -a",",-:A-Za-y")
          }";
          tr/,-:A-Za-y/ -a/;
          eval unpack u
        ).scan(/[ ,-:A-z]+|(.)/m){p="s++#{$1?"chr #{$1.ord}+e":$&+?+};"+p};
        p
      )
    END
  end

  def check(prev)
    # rp[] allocates its Re-Pair codewords from bytes 0-31 and 128-255
    raise unless prev.bytes.all? {|c| (0x20..0x7f).cover?(c) }
  end
end

class Pascal < CodeGen
  File = "QR.pas"
  Cmd = "fpc QR.pas && ./QR > OUTFILE"
  Apt = "fp-compiler"
  Code = %q("begin write('#{PREV}')end.")

  def check(prev)
    # it goes into a '...' literal unescaped, and the literal cannot span lines
    raise if prev =~ /['\n]/
  end
end

class Parser3 < CodeGen
  Name = "Parser 3"
  File = "QR.p"
  Cmd = "parser3 QR.p > OUTFILE"
  Apt = "parser3-cgi"
  Code = %q("$console:line[#{PREV.gsub(?;,"^;")}]")

  def check(prev)
    # "$" starts a variable reference and "^" is the escape character, but only ";" is escaped here
    raise if prev =~ /[$^]/
    raise if prev.include?("\r") # parser3 turns it into a newline
    # it is placed inside $console:line[...], and brackets cannot be escaped
    raise unless prev.match?(BRACKETS)
  end
end

# ---- Added past 151: Scheme dialects + librep in the low-backslash zone (payload ~17 KB, bs~0 here) ----
# They escape backslash and quote, so they sit where the payload has almost no backslashes.

# RUN_AFTER: ChickenScheme
# RUN_AFTER: Rockstar
class ChezScheme < CodeGen
  Name = "Chez Scheme"
  File = "QR.chez.ss"
  Cmd = "chezscheme --script QR.chez.ss > OUTFILE"
  Apt = "chezscheme"
  Code = %q(%((display "#{e[PREV]}")#{N}))
end

class Rockstar < CodeGen
  Name = "Rockstar"
  File = "QR.rock"
  Cmd = "rockstar QR.rock > OUTFILE"
  Apt = [nil]
  Code = %q((b20c=(PREV).chomp.split(34.chr,-1).map{|b20g|34.chr+b20g+34.chr}*" + q + ";"let q be 34#{N}burn q#{N}shout #{b20c}#{N}"))
  def check(prev)
    raise "Rockstar: expected trailing newline and no backslash/inner newline" if !prev.end_with?(10.chr) || prev[0..-2].index(92.chr) || prev[0..-2].index(10.chr)
  end
end

class ChickenScheme < CodeGen
  Name = "Chicken Scheme"
  File = "QR.chicken.scm"
  Cmd = "csi -q -s QR.chicken.scm > OUTFILE"
  Apt = "chicken-bin"
  Code = %q(%((display "#{e[PREV]}")))
end


class LibRep < CodeGen
  Name = "rep (librep)"
  File = "QR.rep"
  Cmd = "rep QR.rep > OUTFILE"
  Apt = "rep"
  Code = %q(%((princ "#{e[PREV]}")))
end

# RUN_AFTER: PARIGP
class Odin < CodeGen
  Name = "Odin"
  File = "QR.odin"
  Cmd = "odin run QR.odin -file > OUTFILE"
  Apt = [nil]
  Code = %q(%(package main;import"core:fmt";main::proc(){fmt.print("#{e[PREV]}")}))
  def check(prev)
    raise if prev.bytesize > 1_000_000 || prev.include?("\0") || !prev.ascii_only?
  end
end

# RUN_AFTER: PARIGP
# Gleam has no raw strings: \ and " go in as @D / @C and Erlang's string:replace puts them back (3 constant backslashes).
# No stdlib (it would need hex.pm at run time): two @external functions into Erlang's string and io.
# RUN_AFTER: Gleam
# Roc (alpha4) strings escape \ " $ : those go in as @D @C @E (and newline as @F) and split_on/join_with put them back
# (linear; replace_each would be quadratic on 555 KB). 5 constant backslashes. basic-cli 0.20.0 is cached in the image.
# RUN_AFTER: Roc
# Inko strings escape \ ' and ${ : those go in as @D @C @E and String.replace puts them back (4 constant backslashes).
# RUN_AFTER: Inko
# Koka raw string r##"..."## (Lexer.x stringraw: graphic chars, space, tab, newline, utf8; ends at "## exactly).
# RUN_AFTER: Koka
# Chapel '''...''' is an uninterpreted string literal (spec, lexical-structure: "any character except three single quotes").
# RUN_AFTER: Chapel
# Pony triple-quoted strings are fully raw (lexer.c triple_string: no escapes; a single-line one is not normalised).
class Pony < CodeGen
  Name = "Pony"
  File = "QR.pony"
  Cmd = "mkdir -p qrpony && cp QR.pony qrpony/main.pony && ponyc -V0 -b qrpony.out -o . qrpony && ./qrpony.out > OUTFILE"
  Apt = [nil]
  Code = %q(%(actor Main new create(e:Env)=>e.out.write("""#{PREV}""")))
  def check(prev)
    raise "Pony: payload holds a triple quote" if prev.include?('"""')
    raise "Pony: payload must be one line" if prev.include?("\n") || prev.include?("\r")
    raise "Pony: NUL" if prev.include?("\0")
  end
end

class Chapel < CodeGen
  Name = "Chapel"
  File = "QR.chpl"
  Cmd = "chpl -o qrchpl QR.chpl && ./qrchpl > OUTFILE"
  Apt = [nil]
  Code = %q(%(use IO;stdout.write('''#{PREV}''');))
  def check(prev)
    raise "Chapel: payload holds three single quotes" if prev.include?("'''")
    raise "Chapel: payload ends with a single quote" if prev.end_with?("'")
    raise "Chapel: NUL" if prev.include?("\0")
  end
end

class Koka < CodeGen
  Name = "Koka"
  File = "qr.kk"   # Koka needs a lowercase file name (it is the module name)
  Cmd = "koka -v0 -o qrkoka qr.kk && chmod +x qrkoka && ./qrkoka > OUTFILE"
  Apt = [nil]
  Code = %q(%(fun main(){print(r##"#{PREV}"##)}))
  def check(prev)
    raise "Koka: payload holds the raw-string end mark" if prev.include?('"##')
    raise "Koka: control character" if prev =~ /[\x00-\x08\x0b-\x1f\x7f]/
    raise "Koka: not UTF-8" unless prev.dup.force_encoding("UTF-8").valid_encoding?
  end
end

class Inko < CodeGen
  Name = "Inko"
  File = "QR.inko"
  Cmd = "inko run QR.inko > OUTFILE"
  Apt = [nil]
  Code = %q(%(import std.stdio (Stdout)#{N}type async Main {#{N}fn async main {#{N}let _ = Stdout.new.write('#{(PREV).gsub(?@,"@A").gsub(B,"@D").gsub(?',"@C").gsub(?$,"@E")}'.replace('@D', '#{B+B}').replace('@C', '#{B}'').replace('@E', '#{B}$').replace('@A', '@'))#{N}}#{N}}#{N}))
  def check(prev)
    raise "Inko: not UTF-8" unless prev.dup.force_encoding("UTF-8").valid_encoding?
    raise "Inko: NUL" if prev.include?("\0")
  end
end

class Roc < CodeGen
  Name = "Roc"
  File = "QR.roc"
  Cmd = "roc build --output qrroc QR.roc && ./qrroc > OUTFILE"
  Apt = [nil]
  Code = %q(%(app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }#{N}import pf.Stdout#{N}d = |s, a, b| Str.join_with(Str.split_on(s, a), b)#{N}main! = |_args| Stdout.write!(d(d(d(d(d("#{(PREV).gsub(?@,"@A").gsub(B,"@D").gsub(?","@C").gsub(?$,"@E").gsub(N,"@F")}", "@D", "#{B+B}"), "@C", "#{B}""), "@E", "#{B}$"), "@F", "#{B}n"), "@A", "@"))#{N}))
  def check(prev)
    raise "Roc: not UTF-8" unless prev.dup.force_encoding("UTF-8").valid_encoding?
    raise "Roc: control character" if prev =~ /[\x00-\x08\x0b-\x1f\x7f]/
  end
end

class Gleam < CodeGen
  Name = "Gleam"
  File = "QR.gleam"
  Cmd = "mkdir -p qrgleam/src && cp QR.gleam qrgleam/src/qr.gleam && printf 'name = \"qr\"\\nversion = \"1.0.0\"\\n' > qrgleam/gleam.toml && (cd qrgleam; gleam run --no-print-progress) > OUTFILE"
  Apt = [nil]
  Code = %q(%(type W{All}#{N}@external(erlang,"string","replace")fn r(s:String,p:String,t:String,w:W)->String#{N}@external(erlang,"io","put_chars")fn p(s:String)->Nil#{N}pub fn main(){p(r(r(r("#{(PREV).gsub(?@,"@A").gsub(B,"@D").gsub(?","@C")}","@D","#{B+B}",All),"@C","#{B}"",All),"@A","@",All))}))
  def check(prev)
    raise "Gleam: not UTF-8" unless prev.dup.force_encoding("UTF-8").valid_encoding?
    raise "Gleam: NUL or CR (the lexer folds CRLF)" if prev.include?("\0") || prev.include?("\r")
  end
end

class PARIGP < CodeGen
  Name = "PARI/GP"
  File = "QR.gp"
  Cmd = "gp -f -q QR.gp > OUTFILE"
  Apt = "pari-gp"
  Code = %q("print#{E[PREV]};quit")
end

class Octave_Ook < CodeGen
  Name = ["Octave", "Ook!"]
  File = ["QR.octave", "QR.ook"]
  Cmd = [
    "mv QR.m QR.m.bak && octave -qf QR.octave > OUTFILE && mv QR.m.bak QR.m",
    "ruby vendor/ook-to-bf.rb QR.ook QR.ook.bf && ruby vendor/bf.rb QR.ook.bf > OUTFILE"
  ]
  Apt = ["octave", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        puts([arrayfun(@(k)
            [repmat(['Ook' char(46-13*(k<0)) ' '],1,2*abs(k)) 'Ook! Ook. '],
            diff([0 #{E[PREV]}]+0),'un',0){:}]);
      "
    END
  end
end

# RUN_AFTER: OCaml
# Merge patch (milestone 284): Coconut's pyparsing PEG parser is quadratic on a multi-megabyte corridor file;
# after OCaml (~155 KB, above Chapel and Octave/Ook!) the exact same raw wrapper runs in ~3 seconds.
class Coconut < CodeGen
  File = "QR.coco"
  Cmd = "coconut -q -r QR.coco > OUTFILE"
  Apt = [nil]
  Code = %q(%(print(r'''#{PREV}''',end="")))

  def check(prev)
    raise if prev.include?("'''") || prev.end_with?("'") || prev.end_with?("\\")
  end
end

# RUN_AFTER: OCaml
# Merge patch (milestone 284): Velato's Mono compiler (Vlt.exe) builds an in-memory AST of 9 MIDI notes per byte,
# taking >8 GB RAM at 5.4 MB; after OCaml (~155 KB, with %-free Vala for Nickle upstream) it runs in ~3.5 seconds.
class Vala_Velato < CodeGen
  File = ["QR.vala", "QR.mid"]
  Cmd = [
    "valac QR.vala && ./QR > OUTFILE",
    "mono vendor/local/bin/Vlt.exe /s QR.mid && mono QR.exe > OUTFILE",
  ]
  Apt = ["valac", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        void p(int[]c){
          foreach(int v in c){
            stdout.putc((char)(v>>8));
            stdout.putc((char)v);
          };
        }
        void main(){
          int[]a;
          p({19796,26724,0,6,0,1,480,19796,29291,#{s=PREV;(s.size*72+4).divmod(65536)*?,}});
          foreach(int c in#{E[s]}.data)
            foreach(int v in a={0,9,7,4,5,c/100*7/6+1,(c-c/100*100)/10*7/6+1,(c-c/10*10)*7/6+1,7})
              p({144,v=15450+v*256,384,v});
          p({255,12032});
        }
      )
    END
  end
end

# RUN_AFTER: OCaml
# Merge patch (milestone 284): Falcon's lexer is quadratic on a multi-megabyte string literal; after OCaml (~155 KB) it runs in <0.1s.
class Falcon < CodeGen
  File = "QR.fal"
  Cmd = "falcon QR.fal > OUTFILE"
  Apt = [nil] # trusty falconpl 0.9.6.9 .debs, see installs.txt
  # single-quoted strings take no escapes; a quote is written twice
  Code = %q(">> '"+(PREV).gsub(?',"''")+"'")
  def check(prev); raise if prev =~ /[^\t\n -~]/; end
end

class OCaml < CodeGen
  File = "QR.ml"
  Cmd = "ocaml QR.ml > OUTFILE"
  Apt = "ocaml"
  Code = %q("print_string#{E[PREV]}")
end

class ObjC < CodeGen
  Name = "Objective-C"
  File = "QR.m"
  Cmd = "gcc -o QR QR.m && ./QR > OUTFILE"
  Apt = "gobjc"
  Code = %q("#import<stdio.h>#{N}int main(){puts#{E[PREV]+R}}")
end

class Nim < CodeGen
  File = "QR.nim"
  Cmd = "nim compile QR.nim && ./QR > OUTFILE"
  Apt = "nim"
  Code = %q("echo#{E[PREV]}")
end

class Nickle < CodeGen
  File = "QR.5c"
  Cmd = "nickle QR.5c > OUTFILE"
  Apt = "nickle"
  Code = %q("printf#{E[PREV]};")

  def check(prev)
    # it becomes printf's format string
    raise if prev.include?(?%)
  end
end


# RUN_AFTER: Mustache_NASM
# Merge patch (milestone 284): nekoc caps string constants at 65,535 bytes (IO.write_ui16); print 20,000-char chunks.
class Neko < CodeGen
  File = "QR.neko"
  Cmd = "nekoc QR.neko && neko QR.n > OUTFILE"
  Apt = "neko"
  Code = %q((PREV).scan(/.{1,20000}/m).map{|m00n|"$print#{E[m00n]};"}*"")
end

class Mustache_NASM < CodeGen
  File = ["QR.mustache", "QR.asm"]
  Cmd = [
    "mustache QR.mustache QR.mustache > OUTFILE",
    "nasm -felf QR.asm && ld -m elf_i386 -o QR QR.o && ./QR > OUTFILE",
  ]
  Apt = ["ruby-mustache", "nasm"]
  def code
    <<-'END'.lines.map {|l| l.strip.gsub("^^^", " ") }.join("\\n")
      "_start{{!:
      q: |
      ^^^:mov edx,z-d
      ^^^global _start
      ^^^mov ecx,d
      ^^^inc ebx
      ^^^mov al,4
      ^^^int 128
      ^^^mov eax,1
      ^^^dec ebx
      ^^^int 128
      ^^^d:db\x60#{e[PREV]}\x60
      ^^^z:;}}{{{q}}}"
    END
  end

  def check(prev)
    raise if prev.include?(?`) # it closes NASM's `...` string, and e[] does not escape it
    # it closes the {{! ... }} comment that hides the YAML from the mustache pass
    raise if prev.include?("}}")
  end
end

# RUN_AFTER: MSIL
# Merge patch (milestone 284): at Perl6 (~973 KB), PHP_Piet's 128-row bitmap would exceed 1.1 GB;
# after MSIL (~165 KB, above Nickle's % check and above Uxntal/VisualBasic) with memory_limit=-1 it runs cleanly.
class PHP_Piet < CodeGen
  File = ["QR.php", "QR.png"]
  Cmd = ["php QR.php > OUTFILE", "npiet QR.png > OUTFILE"]
  Apt = ["php-cli", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        <?php ini_set("memory_limit","-1");$z=3+$w=strlen($s=#{Q[E[PREV]]})*3;
          echo"\\x89PNG\\r\\n\\32\\n";
          $m="";
          $t="\\xc0\\0\\xff";
          for($i=-1;++$i<$z<<7;
              $m.=$c--?
                (($w-$c||$i>$z)?$i/$z<($c<$w?ord($s[$c/3|0]):$c--%3+2):0)?
                  $t[2].$t[$c%3%2].$t[$c%3]:"\\0\\0\\0":"\\0"
          )
            $c=$i%$z;
          foreach([
            "IHDR".pack("NNCV",$w+2,128,8,2),
            "IDAT".gzcompress($m),
            "IEND"
          ]as$d)
            echo pack("NA*N",strlen($d)-4,$d,crc32($d));
      )
    END
  end

  def check(prev)
    raise unless prev.bytes.all? {|c| c == 10 || (0x20..0x7e).cover?(c) }
  end
end

class MSIL < CodeGen
  File = "QR.il"
  Cmd = "ilasm QR.il && mono QR.exe > OUTFILE"
  Apt = "mono-devel"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        .assembly t{}
        .method #$L void m()
        {
          .entrypoint ldstr"#{e[PREV]}"
          call void [mscorlib]#{C*"::"}(string)
          ret
        }
      )
    END
  end
end

class Modula2 < CodeGen
  Name = "Modula-2"
  File = "QR.mod"
  Cmd = "gm2 -fiso QR.mod -o QR && ./QR > OUTFILE"
  Apt = "gm2"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        MODULE Q;
        IMPORT StrIO;
        BEGIN #{
          PREV.gsub(/()[#{i=?^}"]+|[#{i}']+/){
            ["StrIO.WriteString(",$&,");"]*($1??":?')
          }
        }END Q.
      "
    END
  end

  def check(prev)
    # it is cut into "..." and '...' literals without escaping, and neither can span lines
    raise if prev.include?("\n")
  end
end

class MiniZinc < CodeGen
  File = "QR.mzn"
  Cmd = "minizinc --solver COIN-BC --soln-sep '' QR.mzn > OUTFILE"
  Apt = "minizinc"
  Code = %q("output#{E[PREV]}")
end


# RUN_AFTER: M4
# Merge patch (milestone 284): Linux caps a single sh -c recipe argument at MAX_ARG_STRLEN (131,072 bytes),
# A+ upstream requires QR.mk to stay on one line, and GSL upstream forbids "$(". GNU Make's ${file >QR_m,...}
# (curly-brace form, zero "$(") writes directly from Make's C memory without passing the payload through execve().
class Makefile < CodeGen
  File = "QR.mk"
  Cmd = "make -f QR.mk > OUTFILE"
  Apt = "make"
  Code = %q((m00h={"%"=>"%m","{"=>"%o","}"=>"%p",","=>"%c","$"=>"%d","#"=>"%h",B=>"%b"};"a:;@${file >QR_m,z${subst %m,%,${subst %b,"+B+",${subst %h,${shell printf "+B*2+"043},${subst %d,$$,${subst %c,${shell printf "+B*2+"054},${subst %p,${shell printf "+B*2+"175},${subst %o,${shell printf "+B*2+"173},"+(PREV).gsub(/[%\{\},$#\\\\]/){m00h[$&]}+"}}}}}}}}tail -c+2 QR_m;rm -f QR_m"))

  def check(prev)
    raise if prev.include?("\n")
  end
end

class M4 < CodeGen
  File = "QR.m4"
  Cmd = "m4 QR.m4 > OUTFILE"
  Apt = "m4"
  Code = %q("changequote(<@,@>)<@#{PREV}@>")

  def check(prev)
    # they are the quote delimiters set by changequote, and m4 quotes nest
    raise if prev.include?("<@") || prev.include?("@>")
  end
end

# RUN_AFTER: Lua
# RUN_AFTER: Lisaac
# RUN_AFTER: EC
# RUN_AFTER: CDuce
class Aplus < CodeGen
  Name = "A+"
  File = "QR.aplus.a"
  Cmd = "a+ QR.aplus.a > OUTFILE 2> /dev/null < /dev/null"
  Apt = [nil] # noble aplus-fsf 4.22.1 .deb, see installs.txt
  # '...' takes no escapes (a quote is written twice). A line holds ~64 KB, so long
  # payloads are glued from 30000-char pieces (needs ASCII mode for :=). Prints a trailing newline.
  Code = %q((s=(PREV).scan(/.{1,30000}/m).map{|c|?'+c.gsub(?',"''")+?'}).size<2 ? s[0]+N+"sys.exit 0" : "$mode ascii"+N+"x:="+s*(N+"x:=x,")+N+"x"+N+"sys.exit 0")
  def check(prev); raise if prev.include?("\n") || prev =~ /[^ -~]/; end
end

class CDuce < CodeGen
  File = "QR.cd"
  Cmd = "cduce QR.cd > OUTFILE"
  Apt = [nil] # xenial cduce 0.6.0 .deb (native binary), see installs.txt
  # strings take \\ and \" escapes; one long literal overflows the parser's stack, so print 2000-char pieces
  Code = %q((PREV).scan(/.{1,2000}/m).map{|c|%(print "#{e[c]}";;)}*"")
  def check(prev); raise if prev =~ /[^\t\n -~]/; end
end

class EC < CodeGen
  Name = "eC"
  File = "QR_ec.ec"
  Cmd = "ecp -c QR_ec.ec -o QR_ec.sym && ecc -c QR_ec.ec -o QR_ec.c && ecs -console QR_ec.sym QR_ec.imp -o QR_ec.main.ec && ecp -c QR_ec.main.ec -o QR_ec.main.sym && ecc -c QR_ec.main.ec -o QR_ec.main.c && gcc -std=gnu17 -w -o QR_ec QR_ec.c QR_ec.main.c -lecereCOM && ./QR_ec > OUTFILE"
  Apt = [nil] # focal ecere-sdk 0.44.15 .debs, see installs.txt
  # mame's eC class (retired at Ubuntu 20.10): runs of backslashes print from a loop
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        class QR:Application{
          void f(String const s,int n){for(Print(s);n;n--)Print("\\\\");}
          void Main(){#{f(PREV,15){"f(#{V[$S[1..-2],'",',');f("']},0);"}}} }
      )
    END
  end
end

class Lisaac < CodeGen
  File = "qr.li"
  Cmd = "lisaac -gcc -Wno-implicit-function-declaration qr.li > /dev/null && ./qr > OUTFILE"
  Apt = [nil] # noble lisaac 0.39~rc1 .debs, see installs.txt
  # a source line must stay under 255 columns, so print 88-char pieces, one per line
  Code = %q(%(Section Header+name:=QR;Section Public-main<-(#{(PREV).scan(/.{1,88}/m).map{|c|N+%("#{e[c]}".print;)}*""}#{N});))
  def check(prev); raise if prev =~ /[^\t\n -~]/; end
end

class Lua < CodeGen
  File = "QR.lua"
  Cmd = "lua5.3 QR.lua > OUTFILE"
  Apt = "lua5.3"
  Code = %q("print((#{V[E[PREV],?&,?&]}:gsub('&(%d+)&',load[[return('\\\\\\\\'):rep(...)]])))")

  def check(prev)
    raise if prev.include?(?&) # it delimits the backslash run-length encoding "&n&"
  end
end

class LOLCODE < CodeGen
  File = "QR.lol"
  Cmd = "lci QR.lol > OUTFILE"
  Apt = [nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        HAI 1,
        VISIBLE "#{
          PREV.gsub(/[:"]/,":\\0")
        }",
        KTHXBYE
      )
    END
  end

  def check(prev)
    raise if prev.include?("\n") # lci's VISIBLE "..." cannot span lines
  end
end

# RUN_AFTER: LLVMAsm
# REDUCE (CSL build, 2026-03-08 snapshot) strings only double ", raw newlines are fine. prin2 prints a string as is;
# out/shut send it to a file so the banner and the numbered prompts stay off stdout (probe 3: 300 KB byte-exact).
class REDUCE < CodeGen
  Name = "REDUCE"
  File = "QR.red"
  Cmd = "redcsl -w -b < QR.red > /dev/null && cat QR_reduce.out > OUTFILE"
  Apt = [nil]                # reduce-complete 2026-03-08 .deb (sha256 pinned), see installs.txt
  Code = %q(%(out "QR_reduce.out"$symbolic linelength 100000000$symbolic prin2 "#{d[PREV]}"$shut "QR_reduce.out"$bye;#{N}))
  def check(prev)
    raise "REDUCE: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class LLVMAsm < CodeGen
  Name = "LLVM asm"
  File = "QR.ll"
  Cmd = "llvm-as QR.ll && lli QR.bc > OUTFILE"
  Apt = "llvm"
  Backup = "QR.bc"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        @s=global[#{(s=PREV).size+1}x i8]
          c"#{s.gsub(/[\\"\n\t]/){"\\%02x"%$&.ord}}\\00"
        declare i32@puts(ptr)
        define i32@main(){
          call i32@puts(ptr@s)
          ret i32 0
        }
      )
    END
  end

  def check(prev)
    raise if prev.include?("\0") # @s is a NUL-terminated C string printed by puts
  end
end



# RUN_AFTER: JavaScript_Jq_JSFuck
# Merge patch (milestone 284): 3-byte base-84 LZ78-compress QR.txrlisp (~1.3 MB -> ~515 KB) in 15,000-char String
# constants so upstream JSFuck stays ~45 MB (~9s in nodejs, avoiding V8 Zone::Expand OOM) and kotlinc compiles in <3s.
# RUN_AFTER: Kotlin
# Merge patch (milestone 248): the ksh step printed with `print -rn $1` (unquoted). ksh93 brace-expands and globs an
# unquoted expansion, and B11 Klong joins its pieces with ",", so the payload now holds {...,...} and ksh rewrote it
# (found by running ksh + lazyk on the real merged QR.ksh). Now `print -rn -- "$1"`: byte-identical for any payload.
# RUN_AFTER: Ksh_LazyK_LiveScript
# RUN_AFTER: GeneratorScriptingLanguage
# RUN_AFTER: Seed7
# RUN_AFTER: Curry
class NesC < CodeGen
  Name = "nesC"
  File = "QR.nc"
  # gcc 15 headers use C23 nullptr, which nesC 1.4.0 cannot parse; gcc-14 is its C back end
  Cmd = "nescc -gcc=gcc-14 -o QR QR.nc && ./QR > OUTFILE"
  Apt = [nil] # built from source in installs.txt
  # every "?" becomes "\?" so no "??x" in the payload can turn into a trigraph
  Code = %q(%(#include<stdio.h>\nmodule QR{}implementation{int main()__attribute__((C,spontaneous)){puts#{E[PREV].gsub(??){B+$&}};return 0;} }))

  def check(prev)
    raise if prev =~ /[^\n -~]/ # e[] only escapes \ " and newline
  end
end


# RUN_AFTER: Seed7
# Merge patch (milestone 284): pakcs compiles string literals to FlatCurry char cons lists (~30 MB .fcy at 431 KB,
# overflowing SWI-Prolog's 1 GB stack); read QR.curry's -- comment payload deterministically instead.
class Curry < CodeGen
  File = "QR.curry"
  Cmd = "pakcs --nocypm :load QR.curry :save :quit && ./QR > OUTFILE"
  Apt = "swi-prolog-nox"
  Code = %q(%(main=do{s<-readFile"QR.curry";putStr(f(drop 3(dropWhile(/='#{B}n')s)))};f[]=[];f(c:r)=if c=='@'then g r else c:f r;g[]=[];g(c:r)=if c=='n'then '#{B}n':f r else '@':f r#{N}--#{(PREV).gsub("@","@a").gsub(N,"@n")}))
  def check(prev)
    raise if prev =~ /[^\n -~]/
  end
end

# Relocate BeanShell..Brainfuck and ksh..LiveScript to the ~44 KB tail right after RISCVAsm (Z80Asm's Re-Pair
# compresses RISCVAsm right back to ~112 KB so Uxntal ROM stays ~55 KB and Ink stays <950 lines, while blc.rb & lazyk stay ~55 KB).

class Seed7 < CodeGen
  File = "QR.sd7"
  Cmd = "s7 -q QR.sd7 > OUTFILE"
  Apt = [nil] # built from source in installs.txt
  # (PREV) in parens: unhooked, PREV is an expression like "a"+E[..], and .scan must take all of it
  # the text goes out as "..." & "..." chunks, one per line: GSL (which prints this file) drops
  # a backslash when one template line runs past ~20 KB
  Code = %q(%($ include "seed7_05.s7i";\nconst proc: main is func begin write(#{(PREV).scan(/.{1,200}/m).map{|s|?"+e[s]+?"}*"&\n"}); end func;))

  def check(prev)
    raise if prev =~ /[^\n -~]/ # e[] only escapes \ " and newline
  end
end

class GeneratorScriptingLanguage < CodeGen
  Name = "GSL (Generator Scripting Language)"
  File = "QR.gsl"
  Cmd = "gsl -q QR.gsl > OUTFILE"
  Apt = "generator-scripting-language"
  Code = %q(".template 1\n#{d[PREV,B]}\n.endtemplate")

  def check(prev)
    raise if prev =~ /^\./        # a template line starting with "." is a GSL command
    raise if prev.include?("$(")  # $( ... ) is a GSL substitution
    raise if prev.include?("\r")
  end
end

# RUN_AFTER: Ksh_LazyK_LiveScript
# Klong (Nils Holm's K-like language, its own spec) strings only double ", no backslash escapes, and may hold
# raw newlines. .d displays a string as is. kg caps a literal at 256 chars ("string too long",
# probe 5) but not a line, so the payload goes out in 128-char pieces (<= 256 after "" doubling) joined by , on one line.
# Slot tried Nov 14 (peak, all of B11, 128-char pieces): Ksh_LazyK_LiveScript 6.23 MB, LLVMAsm 6.32, CSharp_Chef 6.39,
# Perl5 6.97, AspectJ 18 MB; LOLCODE refuses the newline. (B03 also anchors here; LiveScript prints Klong.)
class Klong < CodeGen
  Name = "Klong"
  File = "QR.kg"
  Cmd = "kg QR.kg < /dev/null > OUTFILE"
  Apt = [nil]                # Klong 20221212 source build, see installs.txt
  Code = %q(%(.d(#{PREV.scan(/.{1,128}/m).map{|s|?"+d[s]+?"}*?,})#{N}))
  def check(prev)
    raise "Klong: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end


# RUN_AFTER: Kotlin
# Gravity "..." string: escapes \\ \" \n (a \( interpolation can't appear: e[] doubles every backslash).
# System.put adds no newline; -q stops the CLI printing "RESULT: ..." after the run.

# RUN_AFTER: Kotlin
# TXR 302 in Lisp mode. TXR picks the mode by suffix: a .txr file is a TXR query (a bare (put-string ..) line is a
# syntax error there, lap 1), --lisp only applies to files without a .txr/.tl/.tlo suffix, and QR.tl is Teal.
# "..." string: escapes \\ \" \n; put-string adds no newline.
# RUN_AFTER: TXR
# Merge patch (milestone 284): Gravity's C lexer drops string literals >1 MB; emit 20,000-char System.put chunks.
class Gravity < CodeGen
  Name = "Gravity"
  File = "QR.gravity"
  Cmd = "gravity -q QR.gravity > OUTFILE"
  Apt = [nil]
  Code = %q("func main(){"+(PREV).scan(/.{1,20000}/m).map{|b18v|"System.put(\"#{e[b18v]}\");"}*""+"}")
  def check(prev)
    raise "Gravity: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class TXR < CodeGen
  Name = "TXR"
  File = "QR.txrlisp"
  Cmd = "txr --lisp QR.txrlisp > OUTFILE"
  Apt = [nil]                # source build txr-302, see installs.txt
  Code = %q(%((put-string "#{e[PREV]}")))
  def check(prev)
    raise "TXR: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Kotlin < CodeGen
  File = "QR.kt"
  Cmd = "kotlinc QR.kt -include-runtime -d QR.jar && kotlin QR.jar > OUTFILE"
  Apt = "kotlin"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        fun main(){
          val s=arrayOf(#{
            m00z=m00t=(0..m00r=m00q=127).map{|m00n|[m00n,[]]};
            m00a="";
            m00b=->m00n{m00a<<(m00n%78+55)%84+42};
            (PREV).bytes{|m00n|
              m00r,m00z=m00z[m00n]||(
                m00b[m00r/6084];m00b[m00r/78];m00b[m00r];
                m00q<474551&&m00z[m00n]=[m00q+=1,[]];
                m00t[m00n])
            };
            m00b[m00r/6084];m00b[m00r/78];m00b[m00r];
            m00a.scan(/.{1,15000}/m).map{|m00k|Q[E[m00k]]}*?,
          }).joinToString("");
          val c=arrayOfNulls<String>(999999);
          val o=StringBuilder();
          var z="";
          var n=0;
          var q=0;
          while(++n<127)c[n]=""+n.toChar();
          for(i in s.indices){
            q=q*78+(s[i].toInt()-13)%84;
            if(i%3>1){
              c[n]=z+(if(q<n++)c[q]!!else z)[0];
              z=c[q]!!;
              o.append(z);
              q=0
            }
          };
          print(o)
        }
      )
    END
  end

  def check(prev)
    raise if prev.bytes.any? {|b| b < 1 || b > 126 }
  end
end

class JavaScript_Jq_JSFuck < CodeGen
  File = ["QR.js", "QR.jq", "QR.jsfuck"]
  Cmd = [
    "$(JAVASCRIPT) QR.js > OUTFILE",
    "jq -r -n -f QR.jq > OUTFILE",
    "!$(JAVASCRIPT) --stack_size=100000 QR.jsfuck > OUTFILE",
  ]
  Apt = ["nodejs", "jq", "nodejs"]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        P={0:'[+[]]'};
        for(R of
          (
            '![]@!![]@'+
            (A="[]['at']")+
            "@([]+[])['link']()@(+('11e20')+[])['split']([])@(+[])"+
            (C="['constructor']")
          ).split('@')
        )
          for(E in D=eval(G='('+R+'+[])'))
            P[D[E]]||=G+"['"+E+"']";
        for(G='[',B=0;++B<36;)
          P[D=B.toString(36)]=
            B<10?
              (G+='+!+[]')+']'
            :
              P[D]||"(+('"+B+"'))['to'+([]+[])"+C+"['name']]('36')";
        A+=C+"('console.log(unescape(\\"";
        for(E of #{E[PREV]})
          A+="'+![]+'"+E.charCodeAt().toString(16);
        for(A+="\\".replace(/false/g,escape(\\" \\")[0])))')()",R=9;R--;)
          A=A.replace(/'(.*?)'/g,(B,D)=>[...D].map(E=>P[E]).join('+'));
        console.log('"'+A+'"')
      )
    END
  end

  def check(prev)
    # JSFuck encodes each byte as %XX with charCodeAt().toString(16), which is not zero-padded,
    # and unescape() cannot yield a non-ASCII byte
    raise if prev.bytes.any? {|b| b < 0x10 || b > 0x7f }
  end
end



# RUN_AFTER: Icon_INTERCAL
# Merge patch (milestone 248): Jasmin's ldc string is one JVM CONSTANT_Utf8 (max 65,535 bytes) and its payload is
# ~74 KB once B01/B03/B05/B11/B13/B14 all sit downstream. Printed in 20,000-char pieces, one ldc + print each.
# RUN_AFTER: Jasmin
# Merge patch (milestone 284): Java's LZ78 dictionary c[] needs >99,999 slots (~195k entries at 10.9 MB input)
# and the encoded string s (~385 KB) exceeds javac's 65,535-byte constant string limit; grow c[] to 999,999
# and join 30,000-char String constants.
# RUN_AFTER: Java_
class GNUSmalltalk < CodeGen
  Name = "GNU Smalltalk"
  File = "QR.st"
  Cmd = "gst QR.st > OUTFILE"
  Apt = [nil]   # installs.txt
  # only ' is special in a Smalltalk string, and it is doubled
  Code = %q(%(Transcript show: '#{d[PREV,?']}'))

  def check(prev)
    raise if prev.bytes.any? {|b| b < 1 || b > 126 } # Java's LZ78 dictionary upstream
  end
end

class Java_ < CodeGen
  Name = "Java"
  File = "QR.java"
  Cmd = "javac QR.java && java QR > OUTFILE"
  Apt = "openjdk-25-jdk"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        void main(){
            String c[]=new String[999999],z="",s=String.join("",new String[]{#{
              z=t=(0..r=q=127).map{|n|[n,[]]};
              a="";
              b=->n{a<<(n%78+55)%84+42};
              (PREV).bytes{|n|
                r,z=z[n]||(
                  b[r/78];b[r];
                  q<6083&&z[n]=[q+=1,[]];
                  t[n])
              };
              b[r/78];b[r];
              a.scan(/.{1,30000}/m).map{|m00j|"\""+m00j+"\""}*?,
            }});
            int i=0,n=0,q=0;
            for(;++n<127;)c[n]=""+(char)n;
            for(;i<#{a.size};){
              q=q*78+(s.charAt(i)-13)%84;
              if(i++%2>0){
                c[n]=z+(q<n++?c[q]:z).charAt(0);
                IO.print(z=c[q]);
                q=0;
              }
            }
          }
      )
    END
  end

  def check(prev)
    raise if prev.bytes.any? {|b| b < 1 || b > 126 }
  end
end

# RUN_AFTER: Jasmin
# RUN_AFTER: DafnyLang
# RUN_AFTER: JuliaLang
# RUN_AFTER: MaximaLang
# RUN_AFTER: GriLang
class UCBLogo < CodeGen
  Name = "UCBLogo"
  File = "QR.logo"
  Cmd = "ucblogo QR.logo > OUTFILE"
  Apt = [nil]   # installs.txt (built without wx, so it needs no display)
  # FIRST [|...|] is a word that keeps every character as it is; " and | are written as CHAR 34 and
  # CHAR 124 so the source has neither (Gri, just upstream, can't print ")
  # merge 212: several TYPE lines of at most ~24000 chars, because Gri (upstream) can't read a line of 32767+
  Code = %q(%(#{PREV.scan(/.{1,12000}/m).flat_map{|y|y.split(/(["|])/)}.reject(&:empty?).map{|x|x==?"?"CHAR 34":x==?|?"CHAR 124":"FIRST [|#{x}|]"}.inject([[]]){|g,x|g[-1][0]&&g[-1].sum(&:size)+x.size>24000?g<<[x]:g[-1]<<x;g}.map{|l|"TYPE (WORD #{l*" "})"}*N} BYE))

  def check(prev)
    # \ is still an escape inside |...|, and a newline would split a word
    raise if prev =~ /[\\\n]/
    raise if prev =~ /[$&'^_]/ # upstream: Groovy refuses ' & _, D refuses $, AspectJ refuses ^
  end
end

class GriLang < CodeGen
  Name = "Gri"
  File = "QR.gri"
  Cmd = "gri QR.gri > OUTFILE"
  Apt = "gri"
  # merge 212: one show per line (Gri can't read a line of 32767+ chars; UCBLogo now comes in several lines)
  Code = %q(%(#{PREV.split(N).map{|l|%(show "#{l}")}*N}\n)) # Gri warns on stdout if the last line has no newline

  def check(prev)
    # Gri ends the string at the first " (even after a \) and parses the rest as an expression,
    # \ starts a synonym, and one show prints one line
    raise if prev =~ /["\\]/
    raise if prev =~ /[$&'^_]/ # upstream: Groovy refuses ' & _, D refuses $, AspectJ refuses ^
    raise if prev.split("\n").any? { |l| l.size + 7 > 32000 } # Gri's line limit (32767 fails)
  end
end

class MaximaLang < CodeGen
  Name = "Maxima"
  File = "QR.mac"
  Cmd = "maxima -q --init-mac=QR.mac > OUTFILE"
  Apt = "maxima"
  # the payload is cut at each " and newline and glued back with ascii(34) / ascii(10), so no \ is
  # needed and the source is one line; linel stops Maxima wrapping long lines.
  # Merge 212: the format string ~a is built as sconcat(ascii(126),"a"), so the source has no ~ (B05's ReScript carries " as ~)
  Code = %q(%(linel:99999;printf(true,sconcat(ascii(126),"a"),sconcat(#{PREV.split(/(["\n])/).map{|x|x==?"?"ascii(34)":x==N ? "ascii(10)":%("#{x}")}*?,}));quit();))

  def check(prev)
    # \ is the escape character in Maxima strings
    raise if prev.include?("\\")
    raise if prev =~ /[$&'^_]/ # upstream: Groovy refuses ' & _, D refuses $, AspectJ refuses ^
  end
end

class JuliaLang < CodeGen
  Name = "Julia"
  File = "QR.jl"
  Cmd = "julia QR.jl > OUTFILE"
  Apt = [nil]   # installs.txt
  # triple-quoted raw string: no $ interpolation, and a lone " needs no escape
  Code = %q(%(print(raw"""#{PREV}""")))

  def check(prev)
    # """ would close it, \ before " is still special in a raw string, a " at the end would merge
    # into the closing """, and a newline would start the dedent rules
    raise if prev =~ /"""|\\|"\z|\n/
    raise if prev =~ /[$&'^_]/ # upstream: Groovy refuses ' & _, D refuses $, AspectJ refuses ^
  end
end

class DafnyLang < CodeGen
  Name = "Dafny"
  File = "QR.dfy"
  # dafny run would print the verifier's summary into OUTFILE, so verify+build first, then run the dll;
  # -o keeps its QR.cs / QR.dll out of the way of the C# step's files
  Cmd = "dafny build -o dafny-out/QR QR.dfy && DOTNET_ROLL_FORWARD=Major dotnet dafny-out/QR.dll > OUTFILE"
  Apt = [nil]   # installs.txt
  # verbatim string: only " is special, and it is doubled
  Code = %q(%(method Main(){print @"#{d[PREV]}";}))

  def check(prev)
    raise if prev =~ /[$&'^_]/ # upstream: Groovy refuses ' & _, D refuses $, AspectJ refuses ^
  end
end

# RUN_AFTER: Jasmin
# RUN_AFTER: PureScript
# RUN_AFTER: Elm
# RUN_AFTER: Pyret
# RUN_AFTER: ReScript
# RUN_AFTER: Wisp
class Imba < CodeGen
  File = "QR.imba"
  Cmd = "imba QR.imba > OUTFILE"
  Apt = [nil] # npm imba (installs.txt)
  Code = %q(%(process.stdout.write '#{PREV}'))
  def check(prev)
    raise if prev =~ /['\\\n\r]/
  end
end

class Wisp < CodeGen
  File = "QR.wisp"
  Cmd = "wisp < QR.wisp > QR.wisp.js && node QR.wisp.js > OUTFILE"
  Apt = [nil] # npm wisp + commander 7 (installs.txt)
  # every " is carried as # and every ' as !, put back with String.fromCharCode, so nothing is escaped
  # and no ' gets past this step
  Code = %q(%[(.write process.stdout (.replace-all (.replace-all "#{PREV.tr(%(\x22\x27),%(#!))}" "#" (.from-char-code String 34)) "!" (.from-char-code String 39)))])
  def check(prev)
    raise if prev =~ /[#!\\]/
  end
end

class ReScript < CodeGen
  File = "QR.res"
  Cmd = "bsc QR.res > QR.res.js && node QR.res.js > OUTFILE"
  Apt = [nil] # npm rescript (installs.txt)
  # every " is carried as ~ and put back with String.fromCharCode(34), so nothing is escaped;
  # Console.log appends a newline (harmless for Wisp)
  Code = %q(%[Console.log(String.replaceAll("#{PREV.tr(?",?~)}", "~", String.fromCharCode(34)))])
  def check(prev)
    raise if prev =~ /[~\\\n\r]/
  end
end

class Pyret < CodeGen
  File = "QR.arr"
  Cmd = "pyretc QR.arr QR.jarr && NODE_PATH=/opt/b05/node_modules node QR.jarr > OUTFILE"
  Apt = [nil] # npm pyret-npm; pyretc runs its compiler without the background server (installs.txt)
  Code = %q(%(print("#{e[PREV]}")))
end

class Elm < CodeGen
  File = "QR.elm"
  Cmd = %q(cp QR.elm /opt/elm/src/QR.elm && cd /opt/elm; elm make src/QR.elm --output=/usr/local/share/quine-relay/QR.elm.js && node -e 'require("./QR.elm.js").Elm.QR.init().ports.o.subscribe(s=>process.stdout.write(s))' > OUTFILE)
  Apt = [nil] # npm elm + /opt/elm/elm.json with elm/core and elm/json (installs.txt)
  # Elm has no stdout: the worker sends the text out of port o, and node writes it
  Code = %q(%(port module QR exposing (main)\nport o : String -> Cmd m\nmain : Program () () ()\nmain = Platform.worker {init = always ((), o "#{e[PREV]}"), update = always (always ((), Cmd.none)), subscriptions = always Sub.none}))
end

class PureScript < CodeGen
  File = "QR.purs"
  Cmd = "purs compile -o /opt/purs/out QR.purs '/opt/purs/lib/*/src/**/*.purs' && node /opt/purs/run.mjs > OUTFILE"
  Apt = [nil] # npm purescript + prelude/effect/console from GitHub tags (installs.txt)
  # """...""" is a raw string: no escapes at all; log appends a newline (harmless for Elm)
  Code = %q(%(module QR where\nimport Effect.Console\nmain = log """#{PREV}"""))
  def check(prev)
    raise if prev.include?('"""') || prev.end_with?('"')
  end
end

class Jasmin < CodeGen
  File = "QR.j"
  Cmd = "jasmin QR.j && java QR > OUTFILE"
  Apt = "jasmin-sable"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        .class QR\n
        .super #{S="java/lang/"}Object\n
        .method #$L main()V\n
        .limit stack 1\n
        #{PREV.scan(/.{1,20000}/m).map{|c|%(ldc "#{e[c]}"\ninvokestatic #{S}IO/print(L#{S}Object;)V\n)}*""}
        return\n
        .end method
      )
    END
  end

  def check(prev)
    # every piece becomes one CONSTANT_Utf8 via ldc
    prev.scan(/.{1,20000}/m) { raise if escape($&).bytesize > 65000 }
    # the dc stage carries the whole program inside a [...] string, which counts nesting
    raise unless prev.match?(BRACKETS)
  end
end


# RUN_AFTER: Haxe
# Merge patch (milestone 248): INTERCAL dimensions its output array with a 16-bit constant (DO,1<-#N), and the
# payload is ~73 KB in the merge (~51 KB at 212). Icon now writes the text as several arrays of <= 60,000 chars,
# each re-dimensioned and READ OUT in turn. C-INTERCAL keeps the "last character output" between READ OUTs,
# so Icon's running c (the previous character, bit-reversed) carries across pieces unchanged. i is the index inside
# a piece; n counts every character and keeps the -n*256 offset that makes (c-u) positive, as the base's -i did.
# RUN_AFTER: Icon_INTERCAL
# Wren "..." string: escapes \\ \" \n, and %( starts interpolation, so every % is written \%. System.print adds a
# newline, and Jasmin (next) NEEDS it: its scanner never treats EOF as a separator, so a QR.j with no final newline
# makes it loop until "OutOfMemoryError: Java heap space" (lap 3, Nov 14). Base INTERCAL always printed that newline.
class Wren < CodeGen
  Name = "Wren"
  File = "QR.wren"
  Cmd = "wren_cli QR.wren > OUTFILE"
  Apt = [nil]                # wren-cli 0.4.0 source build (one-line patch), see installs.txt
  Code = %q(%(System.print("#{Q[e[PREV],"%"]}")))
  def check(prev)
    raise "Wren: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Icon_INTERCAL < CodeGen
  File = ["QR.icn", "QR.i"]
  Cmd = [
    "icont -s QR.icn && ./QR > OUTFILE",
    "ick -bfOc QR.i && gcc -std=c99 -static QR.c -I /usr/include/ick-* -o QR -lick && ./QR > OUTFILE"
  ]
  Backup = [nil, "QR.c"]
  Apt = [["icont", "iconx"], "intercal"]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        procedure main();
          c:=n:=0;
          s:=#{E[PREV+N]};
          every k:=1to*s by 60000do{
            r:=s[k:(*s+1>k+60000)|*s+1];
            i:=0;
            write("DO,1<-#",*r);
            every t:=ord(!r)do{
              i+:=1;
              u:=-(n+:=1);
              every 0to 7do{u:=u*2+t%2;t/:=2};
              write("PLEASE")\\(i%4/3);
              write("DO,1SUB#",i,"<-#",(c-u)%256);
              c:=u;
            };
            write("PLEASEREADOUT,1");
          };
          write("PLEASEGIVEUP");
        end
      )
    END
  end

  def check(prev)
    # each piece is dimensioned with a 16-bit INTERCAL constant; the pieces are 60,000 chars
  end
end

# RUN_AFTER: Haxe
# CLIPS strings escape only \ and " (newlines stay literal). CLIPS 6.3 -f2 only runs a command that ends in a
# newline, and (exit) has to be on its own line, so this one has two newlines.
class CLIPS < CodeGen
  Name = "CLIPS"
  File = "QR.clp"
  Cmd = "clips -f2 QR.clp > OUTFILE"
  Apt = "clips"
  Code = %q(%((printout t "#{Q[Q[PREV,B],?"]}")\n(exit)\n))
  def check(prev)
    raise "CLIPS: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Haxe < CodeGen
  File = "QR.hx"
  Cmd = "haxe -main QR -neko QR.n && neko QR.n > OUTFILE"
  Apt = "haxe"
  Code = %q("class QR{#$L function main()Sys.print#{E[PREV]};}")
end

# RUN_AFTER: Haskell
# Picat strings escape \ " and newline (\n).
class Picat < CodeGen
  Name = "Picat"
  File = "QR.pi"
  Cmd = "picat QR.pi > OUTFILE"
  Apt = [nil]                # release binary, see installs.txt
  Code = %q(%(main => print("#{e[PREV]}").))
  def check(prev)
    raise "Picat: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Haskell < CodeGen
  File = "QR.hs"
  Cmd = "rm -f QR.o && ghc QR.hs && ./QR > OUTFILE"
  Apt = "ghc"
  Code = %q("main=putStr"+E[PREV])

  def check(prev)
    # only \, " and newline are escaped, and GHC rejects a raw control character in a literal
    raise if prev =~ /[^\n\x20-\x7e]/
  end
end


# RUN_AFTER: GolfScript_GPortugol_Grass
# Merge patch (milestone 284): Groovy compiles '...' literals to JVM CONSTANT_Utf8 constants (<=65,535 bytes);
# at ~447 KB, stream 20,000-char chunks into GZIPOutputStream.
# RUN_AFTER: Groovy_Gzip
# Io "..." string: escapes \\ \" \n; print adds no newline.
class IoLang < CodeGen
  Name = "Io"
  File = "QR.io"
  Cmd = "io QR.io > OUTFILE"
  Apt = [nil]                # source build (tag 2019.05.22-alpha, CMake), see installs.txt
  Code = %q(%("#{e[PREV]}" print))
  def check(prev)
    raise "Io: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Groovy_Gzip < CodeGen
  File = ["QR.groovy", "QR.gz"]
  Cmd = ["groovy QR.groovy > OUTFILE", "gzip -cd QR.gz > OUTFILE"]
  Apt = ["groovy", "gzip"]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        z=new java.util.zip.GZIPOutputStream(System.out);
        #{(PREV).tr(?"+B,"&_").scan(/.{1,20000}/m).map{|m00g|"z<<'#{m00g}'.tr('_&','"+B*2+?\"+"');"}*""}
        z.close()
      )
    END
  end

  def check(prev)
    raise if prev.include?(?')
    raise if prev =~ /[&_]/
    raise if prev.include?("\n")
  end
end

# RUN_AFTER: GolfScript_GPortugol_Grass
# Janet "..." string: escapes \\ \" \n; prin adds no newline.
class Janet < CodeGen
  Name = "Janet"
  File = "QR.janet"
  Cmd = "janet QR.janet > OUTFILE"
  Apt = [nil]                # source build v1.43.0, see installs.txt
  Code = %q(%((prin "#{e[PREV]}")))
  def check(prev)
    raise "Janet: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class GolfScript_GPortugol_Grass < CodeGen
  Name = ["GolfScript", "G-Portugol", "Grass"]
  File = ["QR.gs", "QR.gpt", "QR.grass"]
  Cmd = ["ruby vendor/golfscript.rb QR.gs > OUTFILE", "mv QR.c QR.c.bak && gpt -t QR.c QR.gpt && gcc -o QR QR.c && ./QR > OUTFILE && mv QR.c.bak QR.c", "ruby vendor/grass.rb QR.grass > OUTFILE"]
  Apt = [nil, "gpt", nil]
  def code
    r = <<-'END'.lines.map {|l| l.strip }.join
      %(
        @@BASE@@:j;
        {
          119:i;
          {
            206i-:i;
            .43<{76+}{[i]\\43-*}if
          }%
        }:t;
        "algoritmo A;in\\u00edcio imprima(\\""
        @@PROLOGUE@@
        "#{e[PREV]}"
        {
          "W""w"@j 1+:j\\- @@MOD@@%1+*
        }%
        @@EPILOGUE@@
        '");fim'
      )
    END
    mod, prologue, epilogue = ::File.read(::File.join(__dir__, "grass-boot.dat")).lines
    prologue += "t"
    epilogue += "t"
    prologue = prologue.gsub(/(\*,-,\.,)+/) { "\"t\"*,-,.,\"#{ $&.size / 6 }*t\"" }
    mod = mod.to_i
    r.gsub(/@@\w+@@/, {
      "@@PROLOGUE@@" => prologue.chomp,
      "@@EPILOGUE@@" => epilogue.chomp,
      "@@BASE@@" => 119 + mod - 1,
      "@@MOD@@" => mod,
    })
  end

  def check(prev)
    # vendor/golfscript.rb passes a "..." literal to Ruby's eval, so these would interpolate
    raise if prev =~ /#[{$@]/
  end
end

class Go < CodeGen
  File = "QR.go"
  Cmd = "go run QR.go > OUTFILE"
  Apt = "golang"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        package main;
        import"fmt";
        func main(){
          fmt.Print#{E[PREV]}
        }
      )
    END
  end

  def check(prev)
    # the Go compiler rejects a source file that is not valid UTF-8
    raise unless prev.dup.force_encoding("UTF-8").valid_encoding?
  end
end

class Gnuplot < CodeGen
  File = "QR.plt"
  Cmd = "gnuplot QR.plt > OUTFILE"
  Apt = "gnuplot"
  Code = %q('set print"-";print'+E[PREV])
end

class GEL < CodeGen
  Name = "GEL (Genius)"
  File = "QR.gel"
  Cmd = "genius QR.gel > OUTFILE"
  Apt = "genius"
  Code = %q(f(PREV,61){"printn#$S;"})

  def check(prev)
    # genius is flex-based and its scanner overflows above 16383 bytes per token
    prev.scan(/.{1,#{61*255}}/m) do |s|
      raise if s.size + s.scan(/[\\"\n]/).size + 2 > 16383
    end
  end
end

class GDB < CodeGen
  File = "QR.gdb"
  Cmd = "gdb -q -x QR.gdb > OUTFILE"
  Apt = "gdb"
  Code = %q('echo '+e[PREV]+"\nquit")
end

class GAP < CodeGen
  File = "QR.g"
  Cmd = "gap -q QR.g > OUTFILE"
  Apt = "gap"
  Code = %q("WriteAll(OutputTextUser(),#{E[PREV]});QUIT;")
end

class Gambas < CodeGen
  Name = "Gambas script"
  File = "QR.gbs"
  Cmd = "$(GBS) QR.gbs > OUTFILE"
  Apt = [["gambas3-scripter", "gambas3-gb-pcre"]]
  Code = %q(%(print"#{e[PREV]}"))
end


# RUN_AFTER: Fish
# Merge patch (milestone 284): use 126 PARSE (~-delimited, 0 backslashes, 0 newlines, 14 quotes total) in Forth and
# 500-call Fortran 90 subroutines s0..sN so neither f951 nor the Flex..CommonLisp backslash-doubling ladder blows up.
class Forth_FORTRAN77_Fortran90 < CodeGen
  File = ["QR.fs", "QR.f", "QR.f90"]
  Cmd = [
    "gforth QR.fs > OUTFILE",
    "gfortran -o QR QR.f && ./QR > OUTFILE",
    "gfortran -o QR QR.f90 && ./QR > OUTFILE"
  ]
  Backup = [nil, "QR.c", nil]
  Apt = ["gforth", "f2c", "gfortran"]
  Code = %q((m00s=0;m00b=(PREV).scan(/[\x20\x21\x23-\x26\x28-\x5b\x5d-\x7d]{1,38}|./m).map{|m00t|m00o=m00t.ord;m00o<32||m00o>125||m00o==34||m00o==39||m00o==92 ? [1,m00o.to_s] : [0,m00t]};m00c=m00b.each_slice(500).flat_map{|m00g|m00i=m00s;m00s+=1;[[2,"subroutine s#{m00i}"]]+m00g+[[2,"end"]]};m00m=(0...m00s).map{|m00i|[2,"call s#{m00i}"]}+[[2,"end"],[2,"subroutine p(s)"],[2,"character(*)s"],[2,"write(*,''(a)'',advance=''no'')s"],[2,"end"],[2,"subroutine c(n)"],[2,"write(*,''(a)'',advance=''no'')char(n)"],[2,"end"]];%(: Q ."       write(*,'(a)')'" ; : L Q 126 PARSE TYPE ." '" CR ; : P Q ." call p(''" 126 PARSE TYPE ." '')'" CR ; : C Q ." call c(" 126 PARSE TYPE ." )'" CR ; )+(m00c+m00m).map{|m00k,m00v|(m00k==0 ? "P " : m00k==1 ? "C " : "L ")+m00v+126.chr}*" "+%( ."       end" CR BYE)))
end

class Fish < CodeGen
  File = "QR.fish"
  Cmd = "fish QR.fish > OUTFILE"
  Apt = "fish"
  Code = %q("echo '#{Q[PREV,/['\\\\]/]}'")
end

class Flex < CodeGen
  File = "QR.fl"
  Cmd = "flex -o QR.fl.c QR.fl && gcc -o QR QR.fl.c && ./QR > OUTFILE"
  Apt = "flex"
  Code = %q("%option noyywrap\n int main(){puts#{E[PREV]};}\n%%")

  def check(prev)
    raise if prev.include?("\0") # it becomes a C string literal printed by puts
  end
end

class Fennel < CodeGen
  File = "QR.fnl"
  Cmd = "fennel QR.fnl > OUTFILE"
  Apt = "fennel"
  Code = %q("(io.write \"#{e[PREV]}\")")
end

class FALSELang < CodeGen
  Name = "FALSE"
  File = "QR.false"
  Cmd = "ruby vendor/false.rb QR.false > OUTFILE"
  Apt = [nil]
  Code = %q(?"+PREV.gsub(?",'"34,"')+?")
end

class FSharp < CodeGen
  Name = "F#"
  File = "QR.fsx"
  fsproj = <<-END
    <Project Sdk="Microsoft.NET.Sdk">
      <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net10.0</TargetFramework>
        <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
      </PropertyGroup>
      <ItemGroup>
        <Compile Include="QR.fsx" />
      </ItemGroup>
    </Project>
  END
  Cmd = %(echo '#{ fsproj.lines.map {|s| s.strip }.join }' > tmp.fsproj && DOTNET_NOLOGO=1 dotnet run --project tmp.fsproj > OUTFILE)
  Apt = "dotnet-sdk-10.0"
  Code = %q(%(#$C """#{PREV} """))

  def check(prev)
    raise if prev.include?('"""') # it closes the triple-quoted string
  end
end


# RUN_AFTER: Erlang
# Merge patch (milestone 248): echo got the whole payload as one argument, and Linux caps one argument at
# MAX_ARG_STRLEN (131,072); the payload is ~134 KB in the merge. Now 50,000-char pieces, each its own
# `foreground { echo -n "..." }`, then `echo ""` for the trailing newline the old echo printed. Same bytes out.
class Execline < CodeGen
  File = "QR.e"
  Cmd = "execlineb QR.e > OUTFILE"
  Apt = "execline"
  Code = %q(%(#{PREV.scan(/.{1,50000}/m).map{|c|%(foreground { echo -n "#{e[c]}" } )}*""}echo ""))

  def check(prev)
    # MAX_ARG_STRLEN, the Linux limit on one argument; every piece is one argument
    prev.scan(/.{1,50000}/m) { raise if escape($&).bytesize >= 131000 }
  end
end

class Erlang < CodeGen
  File = "QR.erl"
  Cmd = "escript QR.erl > OUTFILE"
  Apt = "erlang"
  Code = %q("\nmain(_)->io:put_chars#{E[PREV]}.")
end

class EmacsLisp < CodeGen
  Name = "Emacs Lisp"
  File = "QR.el"
  Cmd = "emacs -Q --script QR.el > OUTFILE"
  Apt = "emacs-nox"
  Code = %q(%((princ"#{e[PREV]}")))
end

class Elixir < CodeGen
  File = "QR.exs"
  Cmd = "elixir QR.exs > OUTFILE"
  Apt = "elixir"
  Code = %q("IO.write#{E[PREV]}")

  def check(prev)
    raise if prev.include?('#{') # Elixir interpolates it in a "" string
  end
end

#class Dhall < CodeGen
#  Name = "dhall"
#  File = "QR.dhall"
#  Cmd = "dhall text --file QR.dhall > OUTFILE"
#  Apt = "dhall"
#  Code = %q(E[PREV])
#end
#
#class Dc < CodeGen
#  Name = "dc"
#  File = "QR.dc"
#  Cmd = "dc QR.dc > OUTFILE || true" # XXX
#  Apt = "dc"
#  Code = %q("[#{PREV}]pq")
#end

class Dc_Dhall < CodeGen
  Name = ["dc", "Dhall"]
  File = ["QR.dc", "QR.dhall"]
  Cmd = [
    "dc QR.dc > OUTFILE || true", # XXX
    "dhall text --file QR.dhall > OUTFILE",
  ]
  Apt = ["dc", "dhall"]
  Code = %q("[''\n#{PREV}'']p")

  def check(prev)
    raise unless prev.match?(BRACKETS) # dc reads the whole program as a [...] string
    raise if prev.include?("''") # it ends the Dhall multi-line string
    raise if prev.include?("${") # Dhall interpolates it
    raise if prev.start_with?(" ", "\t") # Dhall strips the common indentation
  end
end

class D < CodeGen
  File = "QR.d"
  Cmd = "gdc -o QR QR.d && ./QR > OUTFILE"
  Apt = "gdc"
  Code = %q(%(import std;void main(){write(q"$#{PREV}$");}))

  def check(prev)
    raise if prev.include?("$") # it delimits the q"$...$" string
  end
end

# pakcs package is broken in Ubuntu 20.10; I guess it will be fixed in Ubuntu 21.04
# it was fixed since 21.04, but it is broken again in Ubuntu 22.04
#class Curry < CodeGen
#  Disabled = true
#  File = "QR.curry"
#  Cmd = "pakcs --nocypm :load QR.curry :save :quit && ./QR > OUTFILE"
#  Apt = "pakcs"
#  Code = %q("main=putStr"+E[PREV])
#end

class Crystal < CodeGen
  Name = "Crystal"
  File = "QR.cr"
  Cmd = "crystal QR.cr > OUTFILE"
  Apt = [["crystal", "libevent-dev"]]
  Code = %q("print#{E[PREV]}")

  def check(prev)
    raise if prev.include?('#{') # Crystal interpolates it in a "" string
  end
end


# RUN_AFTER: CoffeeScript
# Merge patch (milestone 284): GNU clisp caps a single string literal at 4,194,304 chars; print in 50,000-char chunks.
class CommonLisp < CodeGen
  Name = "Common Lisp"
  File = "QR.lisp"
  Cmd = "clisp QR.lisp > OUTFILE"
  Apt = "clisp"
  Code = %q((PREV).scan(/.{1,50000}/m).map{|m00c|%((princ"#{e[m00c]}"))}*"")

  def check(prev)
    raise if prev.include?("\n")
  end
end

class CoffeeScript < CodeGen
  File = "QR.coffee"
  Cmd = "coffee --nodejs --stack_size=100000 QR.coffee > OUTFILE"
  Apt = "coffeescript"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        console.log#{V[E[PREV],'"+"\\\\".repeat(',')+"']}
      "
    END
  end
end


# RUN_AFTER: CSharp_Chef
# Merge patch (milestone 284): Clojure's reader compiles string literals to JVM CONSTANT_Utf8 constants (<=65,535 bytes);
# at ~455 KB, concatenate 15,000-char string pieces via (str ...).
# RUN_AFTER: Clojure_CMake_Cobol
# Ring 1.27 (core built from source). '...' has no escapes; see adds no newline.
class RingLang < CodeGen
  Name = "Ring"
  File = "QR.ring"
  Cmd = "ring QR.ring > OUTFILE"
  Apt = [nil]                # source build v1.27 (language/src only), see installs.txt
  Code = %q(%(see '#{PREV.gsub("'","'+char(39)+'")}'))
  def check(prev)
    raise "Ring: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Clojure_CMake_Cobol < CodeGen
  File = ["QR.clj", "QR.cmake", "QR.cob"]
  Cmd = [
    "clojure QR.clj > OUTFILE",
    "cmake -P QR.cmake > OUTFILE",
    "cobc -O2 -x QR.cob && ./QR > OUTFILE",
  ]
  Apt = ["clojure", "cmake", "gnucobol4"]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        (doseq[s
          (concat
            ["program-id. q. procedure division. display"]
             (map #(str \\"
                  (.replace %"\\"""\\"\\"")
                  \\")
               (re-seq #".{1,31}"
                  (str #{(PREV).scan(/.{1,15000}/m).map{|m00k|"\""+e[m00k]+"\""}*" "})))
             ["."])]
          (println"message(STATUS \\"    \\""(pr-str s)")"))
        )
    END
  end

  def check(prev)
    raise if prev.include?("\n")
    prev.scan(/.{1,15000}/m) { raise if escape($&).bytesize > 65000 }
  end
end

# RUN_AFTER: CSharp_Chef
# (Nov 14) The newline piece is a %[...] string, not '...': QR.rb packs its code and writes ~ ` K J Y H ^ X Z G U ! as
# \x.. escapes, which a single-quoted string keeps literally ('write!' became 'write\x21': lap 1 died at Zoem).
# Frink strings escape \ " and newline (\n), and interpolate $name / ${...} even when the $ is written \$ or
# $ (probes 2-4), so a $ that comes right before a name character or { is split off: "...$"+"name...".
class Frink < CodeGen
  Name = "Frink"
  File = "QR.frink"
  Cmd = "java -cp /opt/frink/frink.jar frink.parser.Frink QR.frink > OUTFILE"
  Apt = [nil]                # frink.jar (sha256 pinned) + default-jre-headless, see installs.txt
  Code = %q(%(print["#{e[PREV].gsub(/\$(?=[\w{])/){'$"+"'}}"]))
  def check(prev)
    raise "Frink: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class CSharp_Chef < CodeGen
  Name = ["C#", "Chef"]
  File = ["QR.cs", "QR.chef"]
  csproj = <<-END
    <Project Sdk="Microsoft.NET.Sdk">
      <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net10.0</TargetFramework>
        <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
      </PropertyGroup>
      <ItemGroup>
        <Compile Include="QR.cs" />
      </ItemGroup>
    </Project>
  END
  Cmd = [
    %(echo '#{ csproj.lines.map {|s| s.strip }.join }' > tmp.csproj && DOTNET_NOLOGO=1 dotnet run --project tmp.csproj > OUTFILE),
    "PERL5LIB=vendor/local/lib/perl5 compilechef QR.chef QR.chef.pl && perl QR.chef.pl > OUTFILE"
  ]
  Apt = ["dotnet-sdk-10.0", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        #$C("Quine Relay Coffee.\\n\\nIngredients.\\n");
        for(int i=9;i++<126;)#$C($"{i} l {i}\\n");
        #$C("\\nMethod.\\n");
        foreach(int c in#{E[PREV.reverse]})#$C($"Put {c}.");
        #$C("Pour contents of the mixing bowl into the baking dish.\\n\\nServes 1.");
      )
    END
  end

  def check(prev)
    # the Chef recipe declares no other ingredient
    raise unless prev.bytes.all? {|b| (10..126).cover?(b) }
  end
end

# RUN_AFTER: Cplusplus
# Numbat strings escape \ " and newline (\n); { } interpolate, so they are doubled. print adds a newline: C# (next)
# ignores one extra newline at the end of its source (only QR.rb is compared at the end). Slot tried Nov 14
# (peak, B12 so far): Cplusplus 6.12 MB, BeanShell 6.13, CSharp_Chef 6.16.
class Numbat < CodeGen
  Name = "Numbat"
  File = "QR.nbt"
  Cmd = "numbat QR.nbt > OUTFILE"
  Apt = [nil]                # cargo install numbat-cli 1.24.0, see installs.txt
  Code = %q(%(print("#{e[PREV].gsub(/[{}]/){$&*2}}")))
  def check(prev)
    raise "Numbat: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

# RUN_AFTER: Cplusplus
# RUN_AFTER: Pyth
# RUN_AFTER: Emmental
# RUN_AFTER: ArnoldC
# RUN_AFTER: LFE
# RUN_AFTER: Joy
class Factor < CodeGen
  Name = "Factor"
  File = "QR.factor"
  Cmd = "/opt/factor/factor QR.factor > OUTFILE"
  Apt = [nil]
  Code = %q(("USE: io\n"+(PREV).scan(/[\x20\x21\x23-\x5b\x5d-\x7e]{1,60}|./m).map{|b16v|(b16v.size>1||("\x22"+B+N).index(b16v)==nil) ? ("\x22"+b16v+"\" write") : "#{b16v.ord} write1"}.each_slice(6).map{|b16w|b16w.join(" ")}.join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class Joy < CodeGen
  Name = "Joy"
  File = "QR.joy"
  Cmd = "joy QR.joy > OUTFILE"
  Apt = [nil]
  Code = %q(("0 __settracegc. 0 setautoput.\nDEFINE _p == [putch] step; _q == 34 putch; _b == 92 putch; _r == 93 putch; _n == 10 putch.\n"+(PREV).scan(/[\x20\x21\x23-\x5b\x5e-\x7e]{1,55}|./m).map{|b16u|b16u=="\x22" ? "_q" : b16u==B ? "_b" : b16u=="]" ? "_r" : b16u==N ? "_n" : "\x22"+b16u+"\" _p"}.each_slice(8).map{|b16g|b16g.join(" ")+"."}.join(N)+"\nquit.\n"))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class LFE < CodeGen
  Name = "LFE"
  File = "QR.lfe"
  Cmd = "lfe QR.lfe > OUTFILE"
  Apt = "erlang-nox"
  Code = %q("(lists:foreach\n (lambda (s) (io:put_chars (base64:decode (tl (atom_to_list s)))))\n \x27(\n"+[PREV].pack("m0").scan(/.{1,248}/).map{|b16f|"a"+b16f}.join(N)+"\n))\n(erlang:halt 0)\n")

  def check(prev)
    raise unless prev.ascii_only?
  end
end

class ArnoldC < CodeGen
  Name = "ArnoldC"
  File = "QR.arnoldc"
  Cmd = "rm -f QR.class && java -jar /opt/ArnoldC.jar QR.arnoldc && java QR > OUTFILE && rm -f QR.class"
  Apt = "default-jdk-headless"
  Code = %q((b16g=(PREV).lines.map{|b16e|"TALK TO THE HAND \""+b16e.chomp+"\x22"}.each_slice(2000).to_a;"IT\x27S SHOWTIME\n"+b16g.each_index.map{|b16i|"DO IT NOW m#{b16i}\n"}*""+"YOU HAVE BEEN TERMINATED\n"+b16g.each_with_index.map{|b16s,b16i|"LISTEN TO ME VERY CAREFULLY m#{b16i}\n"+b16s*N+"\nHASTA LA VISTA, BABY\n"}*""))

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev =~ /["\\\r]/
  end
end

class Emmental < CodeGen
  Name = "Emmental"
  File = "QR.emmental"
  Cmd = "ruby vendor/emmental.rb QR.emmental > OUTFILE"
  Apt = [nil]
  Code = %q((b16p=(PREV);b16b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz :\x27+/=-";b16c=[["@",34],["$",10]]+"&*\x5e_|".chars.each_with_index.map{|b16d,b16i|[b16d,48+b16i]};b16h=[];b16m={};b16b.each_byte{|b16x|b16s="##{b16x}.";b16h<<";"+b16s.bytes.map{|b16k|"##{b16k}"}.join+"##{b16x}\x21";b16m[b16x]=b16x.chr};b16c.each{|b16y,b16t|b16o=b16y.ord;b16s="##{b16t}.";b16h<<";"+b16s.bytes.map{|b16k|"##{b16k}"}.join+"##{b16o}\x21";b16m[b16t]=b16y};(b16h+b16p.bytes.map{|b16x|b16m[b16x]||"##{b16x}."}).join+N))

  def check(prev)
    raise unless prev.ascii_only?
  end
end

class Pyth < CodeGen
  Name = "Pyth"
  File = "QR.pyth"
  Cmd = "python3 /opt/pyth/pyth.py -n QR.pyth > OUTFILE"
  Apt = "python3"
  Code = %q("\x22"+(PREV).chomp+"\x22")

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev =~ /["\\\r]/
  end
end

class Cplusplus < CodeGen
  Name = "C++"
  File = "QR.cpp"
  Cmd = "$(CXX) -o QR QR.cpp && ./QR > OUTFILE"
  Apt = "g++"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        #include<cstdio>\n
        int main(){{
          puts#{E[PREV]};;;;;
        };;;;;}
      "
    END
  end
end


# RUN_AFTER: BeanShell_Befunge_BLC8_Brainfuck
# Merge patch (milestone 248): C is mame's LZ77 decoder into a fixed char s[99999]; its payload is ~133 KB once
# B12/B13/B14/B21 sit downstream (66 KB at 212). Buffer is now s[999999]; nothing else changes.
class C < CodeGen
  File = "QR.c"
  Cmd = "$(CC) -o QR QR.c && ./QR > OUTFILE"
  Apt = "gcc"
  def code
    # LZ77-like compression
    <<-'END'.lines.map {|l| l.strip.gsub(/^_+/) { " " * $&.size } }.join
    (
      s=PREV;
      t={};b="";L="";n=i=0;D=->n{L<<(n+62)%92+35;D};
      s.bytes{|c|
        u=t[c]||=[];
        n>0?
          n-=1:
          (u.shift while u[0]&&(u.size>24||u[0]<i-3560);
           w=4;v=0;
           u.each{|j|k=0;k+=1 while k<91&&s.getbyte(i+1+k)==s.getbyte(j+k)&&s.getbyte(j+k);if k>4&&(k>w||(k==w&&j>v)) then w=k;v=j end};
           v>0)?
          (
            n=w;j=v;
            b.gsub(/.{1,3999}/m){|q|D[(z=q.size)%87][z/87];L<<q};b="";
            x=4001+i-j;D[x%87][x/87][n-5]
          ):b<<c;
        u<<(i+=1)
      };
      "
        #include<stdio.h>\n
        char*p=#{E[L]},s[4999999],*q=s;
        int main(){
          for(int n,m;*p;){
            n=(*p-5)%92+(p[1]-5)%92*87;
            p+=2;
            for(m=n>3999?(*p++-5)%92+6:n;m--;q++)*q=n>3999?q[4000-n]:*p++;
          }
          puts(s);
        }
      "
    )
    END
  end

  def check(prev)
    raise if prev.bytesize >= 4999999 # the decoder buffer is char s[4999999]
    raise unless prev[-6..] == prev[-12..-7] # the LZ77 encoder drops the trailing literals
  end
end


# RUN_AFTER: Bash_Bc
# Berry "..." string: escapes \\ \" \n. print always adds a newline, so write to /dev/stdout instead (byte-exact).
class Berry < CodeGen
  Name = "Berry"
  File = "QR.be"
  Cmd = "berry QR.be > OUTFILE"
  Apt = [nil]                # source build v1.1.0, see installs.txt
  Code = %q(%(open("/dev/stdout","w").write("#{e[PREV]}")))
  def check(prev)
    raise "Berry: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Bash_Bc < CodeGen
  Name = ["bash", "bc"]
  File = ["QR.bash", "QR.bc"]
  Cmd = [
    "bash QR.bash > OUTFILE",
    "BC_LINE_LENGTH=4000000 bc -q QR.bc > OUTFILE",
  ]
  Apt = ["bash", "bc"]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(sed 's/\\\\/\\\\\\\\/g;s/"/\\\\q/g;s/.*/print "&"\\nquit/'<<\\E\n#{PREV}\nE)
    END
  end

  def check(prev)
    raise if prev.include?("\n") # sed appends "quit" to each line
  end
end

# RUN_AFTER: Awk
# Mathics (Mathics3 10.0.1, a Wolfram Language interpreter) strings escape \ " and newline (\n). WriteString["stdout", s]
# prints s as is; -q -f runs the file with no banner or In[] prompts (probe 4: byte-exact).
# Slot tried Nov 14 (peak, all of B12): Awk 6.35 MB, CSharp_Chef 6.63.
class Mathics < CodeGen
  Name = "Mathics"
  File = "QR.wl"
  Cmd = "mathics -q --no-completion -f QR.wl < /dev/null > OUTFILE"
  Apt = [nil]                # pip mathics3==10.0.1, see installs.txt
  Code = %q(%(WriteString["stdout","#{e[PREV]}"]))
  def check(prev)
    raise "Mathics: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

# RUN_AFTER: Awk
# Rego (OPA) "..." string, JSON escapes (\\ \" \n). opa eval --format raw adds a newline; Bash (next) ignores it.
# NOT the raw `...` string: Gnuplot (run 84) runs `...` inside its strings as a shell command, so a backtick PAIR
# anywhere downstream of it is silently replaced (lap 1, Nov 14: QR.go came out 746 bytes, Rego got an empty string).
class Rego < CodeGen
  Name = "Rego"
  File = "QR.rego"
  Cmd = "opa eval --format raw -d QR.rego data.qr.x > OUTFILE"
  Apt = [nil]                # OPA v1.22.4 static binary, see installs.txt
  Code = %q(%(package qr#{N}x := "#{e[PREV]}"))
  def check(prev)
    raise "Rego: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Awk < CodeGen
  Name = "Awk"
  File = "QR.awk"
  Cmd = "awk -f QR.awk > OUTFILE"
  Apt = "gawk"
  Code = %q("BEGIN{print#{E[PREV]}}")
end


# RUN_AFTER: Asymptote
# Merge patch (milestone 212): the base ATS step refused any payload holding a C trigraph (??= ??/ ??< ...), and the
# merged relay's compressed literals produce one by chance. Now the string is printed in pieces, split between any two
# adjacent ?, so the C that patscc emits never holds ?? at all (checked with patscc: "a?" then "?<b" prints a??<b).
# RUN_AFTER: ATS
# MoonScript 0.5.0 (luarocks, Lua 5.4). io.write adds no newline. No space before [===[ : with it, an encoded blob
# in ATS's payload happened to hold a C trigraph (??/) and ATS's check refused it (respelled, Nov 14).
class MoonScript < CodeGen
  Name = "MoonScript"
  File = "QR.moon"
  Cmd = "moon QR.moon > OUTFILE"
  Apt = [nil]                # luarocks moonscript 0.5.0-1, see installs.txt
  Code = %q(%(io.write[===[#{PREV}]===]))
  def check(prev)
    raise "MoonScript: payload holds ]===]" if prev.include?("]===]")
    raise "MoonScript: leading newline" if prev.start_with?("\n")
    raise "MoonScript: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class ATS < CodeGen
  File = "QR.dats"
  Cmd = "patscc -o QR QR.dats && ./QR > OUTFILE"
  Apt = "ats2-lang"
  Code = %q("implement main0()=(#{PREV.split(/(?<=\?)(?=\?)/).map{|x|"print#{E[x]}"}*?;})")
end

# RUN_AFTER: Asymptote
class FStar < CodeGen
  Name = "F*"
  File = "QR.fst"
  Cmd = "fstar.exe --cache_checked_modules --cache_dir fst_out QR.fst > /dev/null && fstar.exe --cache_dir fst_out --odir fst_out --codegen OCaml --custard_main QR.main QR.fst > /dev/null && ocaml fst_out/Custard.ml > OUTFILE"
  Apt = [nil]
  Code = %q(%(module QR\nlet main () : FStar.All.ML unit = FStar.IO.print_string "#{e[PREV]}"\n))
  def check(prev)
    raise "F*: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

# RUN_AFTER: Asymptote
# Umka "..." string: escapes \\ \" \n; printf's format is the payload itself, so every % is written %%.
class Umka < CodeGen
  Name = "Umka"
  File = "QR.um"
  Cmd = "umka QR.um > OUTFILE"
  Apt = [nil]                # source build v1.5.7, see installs.txt
  Code = %q(%(fn main(){printf("#{d[e[PREV],"%"]}")}))
  def check(prev)
    raise "Umka: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Asymptote < CodeGen
  File = "QR.asy"
  Cmd = "asy QR.asy > OUTFILE"
  Apt = "asymptote"
  Code = %q("write('#{Q[e[PREV],?']}');")
end



# RUN_AFTER: AFNIX_Aheui
# Merge patch (milestone 284): a68g caps source line length, and QR.a68 is ~802 KB on one line.
# Print 1,000-char lines via PROC p (J upstream already encodes newlines as ',(10{a.),').
# RUN_AFTER: ALGOL68_Ante
# Merge patch (milestone 284): C's LZ77 output can contain '^' by chance, and the RLE string can exceed 65,535 bytes.
# Encode '^' as '^0^' alongside backslash runs '^N^', chunk into 15,000-char Java string constants, and rebuild via StringBuilder.
# RUN_AFTER: AspectJ
# Teal 0.24.8 (luarocks, Lua 5.4). `tl run` type-checks, then runs; io.write "string-call" form (no parens).
# Bracket levels: Teal 1, YueScript 2, MoonScript 3 (level 0 is used by the base Lua step).
class Teal < CodeGen
  Name = "Teal"
  File = "QR.tl"
  Cmd = "tl run QR.tl > OUTFILE"
  Apt = [nil]                # luarocks tl 0.24.8-1, see installs.txt
  Code = %q(%(io.write [=[#{PREV}]=]))
  def check(prev)
    raise "Teal: payload holds ]=]" if prev.include?("]=]")
    raise "Teal: leading newline" if prev.start_with?("\n")
    raise "Teal: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class AspectJ < CodeGen
  File = "QR.aj"
  Cmd = "ajc QR.aj && java QR > OUTFILE"
  Apt = "aspectj"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        class QR{
          #$L void main(String[]a){
            a=String.join("",new String[]{#{PREV.gsub(Regexp.union(94.chr,/\\+/)){"^#{94.chr==$&?0:$&.size}^"}.scan(/.{1,15000}/m).map{|c|E[c]}*?,}}).split("\\\\^",-1);
            StringBuilder o=new StringBuilder(a[0]);
            for(int i=1;i<a.length;o.append(a[i+1]),i+=2){
              int n=Integer.parseInt(a[i]);
              o.append(n<1?"^":"\\\\".repeat(n));
            }
            System.out.print(o);
          }
        }
      )
    END
  end

  def check(prev)
    # every 15,000-char RLE chunk stays well below JVM's 65,535-byte CONSTANT_Utf8 limit
  end
end

# RUN_AFTER: ALGOL68_Ante
# Starlark (Go) raw triple-quoted string r"""...""": no escapes. Past Scheme (run 29) the payload is re-encoded, so
# Genie's and Coconut's triple-quote rules don't reach here. print adds a newline; AspectJ (next) ignores it.
class Starlark < CodeGen
  Name = "Starlark"
  File = "QR.star"
  Cmd = "starlark QR.star 2> OUTFILE"  # starlark-go print writes to stderr (probe 2: stderr byte-exact)
  Apt = [nil]                # go install go.starlark.net/cmd/starlark (pinned), see installs.txt
  Code = %q(%(print(r"""#{PREV}""")))
  def check(prev)
    raise "Starlark: payload holds \"\"\" or ends in \" or \\" if prev.include?('"""') || prev.end_with?('"', "\\")
  end
end

class ALGOL68_Ante < CodeGen
  Name = ["ALGOL 68", "Ante"]
  File = ["QR.a68", "QR.ante"]
  Cmd = [
    "a68g --heap 512M QR.a68 > OUTFILE",
    "ruby vendor/ante.rb QR.ante > OUTFILE",
  ]
  Apt = ["algol68g", nil]
  def code
    <<-'end'.lines.map {|l| l.strip }.join
      %W[
        STRINGz:= 226+ 153,a:=z+ 166,b:=a+"2"+z+ 160,c:=b+"8"+z+ 165;\n
        PROCp=(STRINGt)VOID:FORiTO\ UPBtDO\ INTn:=ABSt[i];
          print( (50+n%64)+c+ (50+n%8%*8)+c+ (50+nMOD8)+b+ 74+a)
        OD;\n#{(PREV).scan(/.{1,1000}/m).map{|m00a|"p(\""+d[m00a]+"\")"}*(";"+N)}
      ]*"REPR"
    end
  end

  def check(prev)
    raise if prev.include?("\n")
  end
end

# RUN_AFTER: AFNIX_Aheui
# J (jsoftware 9.7) strings only double ', no backslash escapes. A newline can't sit in a J literal, so each
# one becomes ',(10{a.),' (10{a. is LF). x 1!:2 (4) writes x to stdout with nothing added; exit 0[ ... runs it,
# then exits, all on ONE line with no final newline (ALGOL 68 and Bash/bc upstream refuse raw newlines).
# J must run before Groovy (run 84), which refuses ' anywhere downstream. Slot: Aheui prints it; payload
# 24 KB, one line, 19 '. jconsole is linked as ijconsole (the JDK has its own jconsole).
class J < CodeGen
  Name = "J"
  File = "QR.ijs"
  Cmd = "ijconsole QR.ijs < /dev/null > OUTFILE"
  Apt = [nil]                # jsoftware j9.7 Linux tarball, see installs.txt
  Code = %q(%(exit 0[('#{d[PREV,?'].gsub(N,"',(10{a.),'")}')1!:2(4)))
  def check(prev)
    raise "J: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class AFNIX_Aheui < CodeGen
  File = ["QR.als", "QR.aheui"]
  Cmd = ["LANG=C LD_LIBRARY_PATH=/usr/lib/afnix axi QR.als > OUTFILE", "ruby vendor/aheui.rb QR.aheui > OUTFILE"]
  Apt = ["afnix", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        trans o(interp:get-output-stream)\n
        o:set-encoding-mode"utf-8"\n
        trans f(v n){
          print(Character(+ 45056(+(* 64 n)v)))
        }\n
        trans D(n){
          if(< n 4){
            f(+(* 6 n)9)48
          }{
            if(n:odd-p){
              D(- n 3)\n
              f 27 48\n
              f 36 11
            }{
              D(/ n 2)\n
              f 21 48\n
              f 48 20
            }
          }
        }\n
        trans S(Buffer"#{e[PREV]}")\n
        while(>(S:length)0){
          trans c(S:read)\n
          D(c:to-integer)\n
          f 35 39
        }\n
        f 24 149
      )
    END
  end

  def check(prev)
    raise unless prev.ascii_only? # the AFNIX Buffer is read as characters
  end
end


# RUN_AFTER: Zsh
# Merge patch (milestone 211): the base Ada step put the whole payload on one source line, and GNAT stops
# at 32766 characters per line. With 9 batches downstream that line is ~41 KB, so the string is now cut
# into 15000-char pieces, one Text_Io.Put per line (the same idea as mame's commented-out variant).
class Ada < CodeGen
  File = "qr.adb"
  Cmd = "gnatmake qr.adb && ./qr > OUTFILE"
  Apt = "gnat"
  Code = %q(%(with Text_Io;procedure qr is begin\n#{PREV.scan(/.{1,15000}/m).map{|c|%(Text_Io.Put("#{d[c].gsub(N,'"&ASCII.LF&"')}");)}*N}\nend;\n))

  def check(prev)
    # gnat allows up to 32766 characters per line: the worst piece is 15000 chars plus its doubled " and &ASCII.LF&
    prev.scan(/.{1,15000}/m).each { |c| raise if c.size + c.count(?") + c.count("\n") * 11 + 20 > 32766 }
  end
end

# RUN_AFTER: Zsh
# RUN_AFTER: Fantom
# RUN_AFTER: Golo
# RUN_AFTER: Ballerina
# RUN_AFTER: Yeti
# RUN_AFTER: Gosu
class Frege < CodeGen
  File = "QR.fr"
  Cmd = "mkdir -p frege-out && frege -d frege-out QR.fr && java -cp frege-out:/usr/local/lib/frege.jar QR > OUTFILE"
  Apt = [nil]
  Code = %q("module QR where main args = do {"+(PREV).scan(/.{1,15000}/m).map{|b04c|"putStr"+E[b04c]}*";"+"}")

  def check(prev)
    prev.scan(/.{1,15000}/m) { raise if escape($&).bytesize > 65000 }
  end
end

class Gosu < CodeGen
  File = "QR.gsp"
  Cmd = "gosu QR.gsp > OUTFILE"
  Apt = [nil]
  Code = %q((PREV).scan(/.{1,15000}/m).map{|b04c|"System.out.print("+Q[E[b04c]].gsub("<%","<\"+\"%")+");"}*"")

  def check(prev)
    prev.scan(/.{1,15000}/m) { raise if escape($&).bytesize + $&.count("$") + 10 > 65000 }
  end
end

class Yeti < CodeGen
  File = "QR.yeti"
  Cmd = "yeti QR.yeti > OUTFILE"
  Apt = [nil]
  Code = %q((PREV).scan(/.{1,15000}/m).map{|b04c|"print"+E[b04c]}*";")

  def check(prev)
    prev.scan(/.{1,15000}/m) { raise if escape($&).bytesize > 65000 }
  end
end

class Ballerina < CodeGen
  File = "QR.bal"
  Cmd = "bal run --offline QR.bal > OUTFILE"
  Apt = [nil]
  Code = %q("import ballerina/io;public function main(){"+(PREV).scan(/.{1,15000}/m).map{|b04c|"io:print"+E[b04c]+";"}*""+" }")

  def check(prev)
    prev.scan(/.{1,15000}/m) { raise if escape($&).bytesize > 65000 }
  end
end

class Golo < CodeGen
  File = "QR.golo"
  Cmd = "golo golo --files QR.golo > OUTFILE"
  Apt = [nil]
  Code = %q("module QR function main=|a|{foreach s in array["+(PREV).scan(/.{1,15000};|.+/m).map{|b04c|34.chr*3+b04c+34.chr*3}*"," +"]{print(s)}}")

  def check(prev)
    raise if prev.include?('"""') || prev.end_with?('"')
    prev.scan(/.{1,15000};|.+/m) { raise if $&.bytesize > 65000 || $&.start_with?('"') || $&.end_with?('"') }
  end
end

class Fantom < CodeGen
  File = "QR.fan"
  Cmd = "fan QR.fan > OUTFILE"
  Apt = [nil]
  Code = %q("class QR{static Void main(){o:=Env.cur.out;"+(PREV).scan(/.{1,20000}/m).map{|b04c|"o.print(Str<|"+b04c.gsub("|>","||>+Str<|>")+ "|>);"}*""+"o.flush} }")

  def check(prev)
    raise if prev =~ /[\r\n]/
  end
end

# RUN_AFTER: Zsh
# Uiua strings escape \ " and newline. Uiua prints BQN's program, which needs the non-ASCII system dot (U+2022);
# Uiua writes it as \u{2022}, so the relay's payloads stay pure ASCII upstream of here. NO regex here: QR.rb packs
# its code and writes ~ ` K J Y H ^ X Z G U ! as \x.. escapes, which only mean the same inside a string literal;
# the first version's /[^[:ascii:]]/ became /[\x5e[:ascii:]]/ in QR.rb (matches everything) and lap 1 hung at step 1.
# RUN_AFTER: Uiua
# BQN (CBQN) strings only double ", newlines stay literal: adds no backslashes. Printed raw by term.OutRaw (the system dot is
# written [8226].pack("U") here, so batch.rb, code-gen.rb and QR.rb stay ASCII).
class BQN < CodeGen
  Name = "BQN"
  File = "QR.bqn"
  Cmd = "bqn QR.bqn > OUTFILE"
  Apt = [nil]                # CBQN v0.9.0 source build, see installs.txt
  Code = %q(%(#{[8226].pack("U")}term.OutRaw "#{d[PREV]}"))
  def check(prev)
    raise "BQN: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Uiua < CodeGen
  Name = "Uiua"
  File = "QR.ua"
  Cmd = "uiua run --no-format QR.ua > OUTFILE"
  Apt = [nil]                # cargo install uiua 0.19.1, see installs.txt
  Code = %q(%(#{PREV.dup.force_encoding("UTF-8").scan(/.{1,4000}/m).map{|u11|%|&pf "#{e[u11].gsub([8226].pack("U"),B+"u{2022}")}"|}*N}))
  def check(prev)
    raise "Uiua: payload is not valid UTF-8" unless prev.dup.force_encoding("UTF-8").valid_encoding?
    # only BQN's system dot is written as \u{2022}; any other non-ASCII would pass through raw
    raise "Uiua: non-ASCII other than U+2022" if prev.dup.force_encoding("UTF-8").delete([8226].pack("U")) =~ /[^\x00-\x7f]/
  end
end

class Zsh < CodeGen
  Name = "zsh"
  File = "QR.zsh"
  Cmd = "zsh QR.zsh > OUTFILE"
  Apt = "zsh"
  Code = %q("cat<<\\\\Q\n#{PREV}\nQ")
end

# RUN_AFTER: Zoem
# Nial (Q'Nial 7 core) strings only double ', no backslash escapes, and DROP a raw newline (probe 5), so each newline
# becomes ' (char 10) ' and link joins the pieces. writechars prints a string as is (no newline);
# bye ends the -defs script. Must run before Groovy (run 84), which refuses ' downstream.
# Slot tried Nov 14 (peak, all of B11): Zoem 6.03 MB, CSharp_Chef 6.07, AspectJ 6.08, BeanShell 6.11; Cplusplus and Clojure fail a check.
class Nial < CodeGen
  Name = "Nial"
  File = "QR.ndf"
  Cmd = "nial -defs QR.ndf < /dev/null > OUTFILE"
  Apt = [nil]                # Q'Nial 7 core, source build (pinned commit), see installs.txt
  Code = %q(%(writechars link '#{d[PREV,?'].gsub(N,"' (char 10) '")}' ;#{N}bye#{N}))
  def check(prev)
    raise "Nial: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Zoem < CodeGen
  File = "QR.azm"
  Cmd = "zoem -i QR.azm > OUTFILE"
  Apt = "zoem"
  Code = %q("\\\\write{-}{txt}{#{Q[PREV,/[\\\\{}]/]}}")
end


# RUN_AFTER: Yabasic
# Merge patch (milestone 212): Yorick's payload here is almost all backslashes, so a 35*255-char chunk escapes to
# ~17,850 chars, past Yorick's 16,360-char line limit. 30*255 = 7,650 chars escapes to at most 15,300.
# RUN_AFTER: Yorick
# Singular always ends its output with a newline. So it sits right before FriCAS, whose program ends in a
# newline: Singular's string holds everything but that last newline, and Singular's own newline completes it.
# Merge patch (milestone 284): Singular's Flex scanner splits string tokens at 16,384 input bytes, corrupting
# escaped backslashes across the boundary. Accumulate 2,000-char chunks (<= 4,002 escaped bytes each) into `s`.
# RUN_AFTER: Singular
# FriCAS strings escape with _ (write __ and _"), never with a backslash, so this adds zero backslashes.
# FriCAS's interpreter echoes results on stdout, so the program writes the payload to QR_fricas.out with a
# TextFile and the Cmd copies that file (same pattern as mame's BASIC step). A string can't hold a newline, so
# each newline becomes its own writeLine!(f,""). One line (plus the final newline Singular needs).
class FriCAS < CodeGen
  Name = "FriCAS"
  File = "QR.input"
  Cmd = "fricas -nosman < QR.input > /dev/null && cat QR_fricas.out > OUTFILE"
  Apt = "fricas"
  Code = %q(%(f:=open("QR_fricas.out"::FileName,"output")$TextFile;write!(f,"#{PREV.gsub(?_,"__").gsub(?",'_"').gsub(N,%[")$TextFile;writeLine!(f,"")$TextFile;write!(f,"])}")$TextFile;close!(f)$TextFile\n))
  def check(prev)
    raise "FriCAS: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Singular < CodeGen
  Name = "Singular"
  File = "QR.sing"
  Cmd = "Singular -q QR.sing > OUTFILE"
  Apt = "singular"
  Code = %q(%(string s="";\n#{PREV.chomp.scan(/.{1,2000}/m).map{|c|%(s=s+"#{Q[Q[c,B],?"]}";\n)}*""}s;quit;))
  def check(prev)
    raise "Singular: payload must end with one newline" unless prev.end_with?("\n") && !prev.end_with?("\n\n")
    raise "Singular: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Yorick < CodeGen
  File = "QR.yorick"
  Cmd = "yorick -batch QR.yorick > OUTFILE"
  Apt = "yorick"
  Code = %q(%(write,format="%s",#{f(PREV,30){$S+"+\n"}}""))

  def check(prev)
    # yorick allows up to 16360 characters per line, and a chunk becomes ("...")+
    prev.scan(/.{1,#{ 30 * 255 }}/m) { raise if escape($&).size + 5 > 16360 }
  end
end

class Yabasic < CodeGen
  File = "QR.yab"
  Cmd = "yabasic QR.yab > OUTFILE"
  Apt = "yabasic"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        sub f(s$,n)
          ?s$;:
          for i=1to n?"\\\\";
          next end sub:
        f("#{V[e[PREV],'",','):f("']}",0)
      )
    END
  end

  def check(prev)
    # yabasic allows up to 16383 characters per "..." literal
    escape(prev).split(/(?:\\\\)+/) { |s| raise if s.size + 2 > 16383 }
  end
end

# RUN_AFTER: XSLT
# RUN_AFTER: Slashes
# RUN_AFTER: CJam
# RUN_AFTER: Underload
class BrainFlak < CodeGen
  Name = "Brain-Flak"
  File = "QR.bflk"
  Cmd = "ruby vendor/brain_flak.rb -A QR.bflk > OUTFILE"
  Apt = [nil]
  Code = %q((b19p=(PREV);b19t=->b19x{b19x<6 ? "()"*b19x : "(#{b19t[b19x/2]}){}#{"()"*(b19x%2)}"};b19p.reverse.bytes.map{|b19b|"(#{b19t[b19b]})"}*""))
  def check(prev)
    raise "Brain-Flak: non-ASCII" unless prev.ascii_only?
  end
end

class Underload < CodeGen
  Name = "Underload"
  File = "QR.ul"
  Cmd = "ruby vendor/underload.rb QR.ul > OUTFILE"
  Apt = [nil]
  Code = %q(%((#{PREV})S))
  def check(prev)
    raise "Underload: unbalanced parens" unless prev.match?(PARENS)
  end
end

class CJam < CodeGen
  Name = "CJam"
  File = "QR.cjam"
  Cmd = "ruby vendor/cjam.rb QR.cjam > OUTFILE"
  Apt = [nil]
  Code = %q(%("#{PREV}"))
  def check(prev)
    raise "CJam: quote or backslash" if prev =~ /["\\]/
  end
end

class Slashes < CodeGen
  Name = "///"
  File = "QR.slashes"
  Cmd = "ruby vendor/slashes.rb QR.slashes > OUTFILE"
  Apt = [nil]
  Code = %q((b19s=(PREV).tr("\x22",33.chr);b19r=[*48..82,*84..90,*97..122];b19r.map{|b19c|b19o={};b19s[0,4000].scan(/../){b19o[$&]=b19o[$&].to_i+1};b19n=b19o.key(b19o.values.max)||"()";b19s=b19s.gsub(b19n,b19c.chr);"/#{b19c.chr}/#{b19n}/"}.reverse*""+"/#{33.chr}/"+34.chr+"/"+b19s))
  def check(prev)
    raise "Slashes: unexpected char" if prev =~ /[^"S(){}]/
  end
end

class XSLT < CodeGen
  File = "QR.xslt"
  Cmd = "xsltproc QR.xslt > OUTFILE"
  Apt = "xsltproc"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        <?xml-#{I="stylesheet"} type='text/xsl'href=''?>
        <#{I} version='1.0' xmlns='http://www.w3.org/1999/XSL/Transform'>
          <output method='text'/>
          <x xmlns='z:'><![CDATA[#{PREV}]]></x>
        </#{I}>
      "
    END
  end

  def check(prev)
    raise if prev.include?("]]>") # it closes the CDATA section
    raise if prev =~ /[\x00-\x08\x0b\x0c\x0e-\x1f]/ # XML 1.0 forbids it and CDATA cannot escape it
  end
end


# RUN_AFTER: VimScript
# Merge patch (milestone 284): at ~2.1 MB, k + s.size crosses 2**21 (3-byte -> 4-byte LEB128);
# restore mame's dynamic m = ((k + s.size).bit_length - 1) / 7 formula within Wasm's 64-page (4 MB) memory.
class VisualBasic_WebAssemblyBinary_WebAssemblyText_Whitespace < CodeGen
  Name = ["Visual Basic", "WebAssembly (Binary format)", "WebAssembly (Text format)", "Whitespace"]
  File = ["QR.vb", "QR.wasm", "QR.wat", "QR.ws"]
  vbproj = <<-END
    <Project Sdk="Microsoft.NET.Sdk">
      <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net10.0</TargetFramework>
        <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
      </PropertyGroup>
      <ItemGroup>
        <Compile Include="QR.vb" />
      </ItemGroup>
    </Project>
  END
  Cmd = [
    %(echo '#{ vbproj.lines.map {|s| s.strip }.join }' > tmp.vbproj && DOTNET_NOLOGO=1 dotnet run --project tmp.vbproj > OUTFILE),
    "$(WASI_RUNTIME) QR.wasm > OUTFILE",
    "wat2wasm QR.wat -o QR.wat.wasm && $(WASI_RUNTIME) QR.wat.wasm > OUTFILE",
    "ruby vendor/whitespace.rb QR.ws > OUTFILE"
  ]
  Apt = ["dotnet-sdk-10.0", "wabt", "wabt", nil]
  def code
    r = <<-'END'.lines.map {|l| l.strip }.join(?:)
      %(Module QR\nSub main()\nDim c,n:Dim s=#{C[0]}.openstandardoutput(),t={@@TBL@@}
          For Each d in"@@DATA1@@}@@DATA2@@~@@DATA3@@$@@DATA4@@"
            c=Asc(d)
            If c=36
              For c=0To 11
                #$W(If(c mod 3,Asc(#{s=PREV;s.size*16+3}.ToString("x8")(7-c*2\\3 xor 1)),92))
              Next
            Else
              n=(c>124)*(@@CONST1@@*c-#{s.size+@@CONST2@@})
              Do While n>127
                #$W(n mod 128+128)
                n\\=128
              Loop
              #$W(If(c<125,If((c-1)\\7-8,c-66*(c>65)*(c<91),t(c-57)),n))
            End If
          Next
          For Each c in"#{d[s].gsub N,'"& VbLf &"'}"
            #$W(Asc(c))
          Next
        End Sub
      end module)
    END
    tbl, data1, data2, data3, data4 = ::File.read(::File.join(__dir__, "wasm-tmpl.dat")).lines.map {|s| s.chomp }
    raise unless data3[0] == '('
    k = data3.size + data4.size + 18
    r.gsub(/@@\w+@@/, {
      "@@TBL@@" => tbl,
      "@@DATA1@@" => data1.gsub("\\"){"\\\\"},
      "@@DATA2@@" => data2.gsub("\\"){"\\\\"},
      "@@DATA3@@" => '#{40.chr}'+data3[1..].gsub("\\"){"\\\\"},
      "@@DATA4@@" => data4.gsub("\\"){"\\\\"},
      "@@CONST1@@" => "\#{6+((#{k}+s.size).bit_length-1)/7}",
      "@@CONST2@@" => "(m=((#{k}+s.size).bit_length-1)/7)+#{k}+125*(6+m)"
    })
  end

  def check(prev)
    data3, data4 = ::File.read(::File.join(__dir__, "wasm-tmpl.dat")).lines.values_at(3, 4)
    k = data3.chomp.size + data4.chomp.size + 18
    raise unless (2**14...4_000_000).cover?(k + prev.size)
  end
end

class VimScript < CodeGen
  Name = ["Vimscript"]
  Apt = "vim"
  File = "QR.vim"
  Cmd = "vim -EsS QR.vim > OUTFILE"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "let s=#{E[PREV]}\nput=s\n2,$p\nq!"
    END
  end
end

# RUN_AFTER: Verilog
# RUN_AFTER: FishEsolang
class Hexagony < CodeGen
  Name = "Hexagony"
  File = "QR.hxg"
  Cmd = "ruby /opt/hexagony/interpreter.rb QR.hxg > OUTFILE"
  Apt = [nil]
  Code = %q((b19u=(PREV);b19v=0;b19t=b19u.bytes.map{|b19b|b19d=b19b==b19v ? "" : b19b==b19v+1 ? ")" : b19b==b19v-1 ? "(" : b19b>64&&b19b<91||b19b>96&&b19b<123 ? (b19v=b19b).chr : "-#{b19v=b19b}";b19v=b19b if b19d.size<2;b19d+";"}+["@"];b19z=b19t.sum(&:size);b19m=4;b19m+=1 while 3*b19m*(b19m-1)-14*b19m<b19z;b19p=0;(0...2*b19m-1).map{|b19i|b19l=2*b19m-1-(b19m-1-b19i).abs;b19c=b19i==0||b19i==2*b19m-2 ? b19l-1 : b19i.odd? ? b19l-2 : b19i==b19m-1 ? b19l-4 : b19l-3;b19s=+"";(b19s<<b19t[b19p];b19p+=1) while b19p<b19t.size&&b19s.size+b19t[b19p].size<=b19c;b19s=b19s.ljust(b19c,".");b19i==0 ? b19s+"<" : b19i==2*b19m-2 ? ">"+b19s : b19i.even? ? (b19i<b19m ? ".>" : ">")+b19s+(b19i<b19m-1 ? "<" : "<.") : "/"+b19s.reverse+"/"}*""))
  def check(prev)
    raise "Hexagony: non-ASCII" unless prev.ascii_only?
  end
end

class FishEsolang < CodeGen
  Name = "><> (Fish)"
  File = "QR.fish.fish"
  Cmd = "python3 vendor/fish.py QR.fish.fish > OUTFILE"
  Apt = [nil]
  Code = %q(%(a0.l?#{33.chr};o20."#{(PREV).reverse.gsub(Regexp.union(N,34.chr)){$&==N ? %("a") : %("b3*1+")}}"20.))
  def check(prev)
    raise "Fish: non-printable byte" unless prev.ascii_only?
  end
end

class Verilog < CodeGen
  File = "QR.v"
  Cmd = "iverilog -o QR QR.v && ./QR -vcd-none > OUTFILE"
  Apt = "iverilog"
  Code = %q(%(module QR;initial begin #{f(PREV,3){%($write("%s",#$S);)}}end endmodule))
end


class TypeScript_Unlambda < CodeGen
  File = ["QR.ts", "QR.unl"]
  Cmd = ["tsc --outFile QR.ts.js QR.ts && $(JAVASCRIPT) QR.ts.js > OUTFILE", "ruby vendor/unlambda.rb QR.unl > OUTFILE"]
  Apt = ["node-typescript", nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "let t='k',c;for(c of#{E[PREV]})t='\\x60.'+c+t;console.log(t)"
    END
  end

  def check(prev)
    raise if prev.include?("\n") # `.<newline> is not a valid token
  end
end

class Tcsh_Thue < CodeGen
  Name = ["tcsh", "Thue"]
  File = ["QR.tcsh", "QR.t"]
  Cmd = ["tcsh QR.tcsh > OUTFILE", "ruby vendor/thue.rb QR.t > OUTFILE"]
  Apt = ["tcsh", nil]
  Code = %q(%(cat<<\\\\E\na::=~#{PREV}\n::=\na\n\\\\E))

  def check(prev)
    raise if prev.include?("\n") # a Thue rule is one line
  end
end

class Tcl < CodeGen
  File = "QR.tcl"
  Cmd = "tclsh QR.tcl > OUTFILE"
  Apt = "tcl"
  Code = %q(%(puts "#{Q[PREV,/["$\[\\\\]/]}"))
end

class Swift < CodeGen
  File = "QR.swift"
  Cmd = "swiftc QR.swift && ./QR > OUTFILE"
  Apt = "swiftlang"
  Code = %q("print"+E[PREV])
end

class SurgeScript < CodeGen
  File = "QR.ss"
  Cmd = "surgescript QR.ss > OUTFILE"
  Apt = "surgescript"
  Code = %q(%(object"Application"{state"main"{#{f(PREV,4){%(Console.write#$S;)}}exit();}}))
end

class StandardML_Subleq < CodeGen
  Name = ["Standard ML", "Subleq"]
  File = ["QR.sml", "QR.sq"]
  Cmd = ["polyc -o QR QR.sml && ./QR > OUTFILE", "ruby vendor/subleq.rb QR.sq > OUTFILE"]
  Apt = [["polyml", "libpolyml-dev"], nil]
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      %(
        fun p n=print(Int.toString n^" ");
        fun main()=(
          print"0 0 130 ";
          List.tabulate(127,p);
          String.map(fn c=>(p(3+ord c);print"-1 0 ";c))#{E[PREV]}
        )
      )
    END
  end

  def check(prev)
    raise if prev.bytes.max.to_i > 126
  end
end

class Squirrel < CodeGen
  File = "QR.nut"
  Cmd = "squirrel QR.nut > OUTFILE"
  Apt = "squirrel3"
  Code = %q("print"+E[PREV])
end


# RUN_AFTER: Scheme
# Merge patch (milestone 284): spl2c's yacc grammar concatenates Shakespeare statements with O(N^2) strcat,
# stalling on a multi-megabyte play, and Ruby's 129-pass Re-Pair rp[] takes minutes on megabytes of Hexagony/C data.
# Instead, Shakespeare speaks a 342-byte S-Lang decoder (100% real Scilab -> sed -> spl2c + gcc -> slsh) while
# QR.sed carries the backslash-RLE payload on #: comment lines (ignored by sed -f and stripped by /^#:/d).
class Scilab_Sed_Shakespeare_SLang < CodeGen
  Name = ["Scilab", "sed", "Shakespeare", "S-Lang"]
  File = ["QR.sci", "QR.sed", "QR.spl", "QR.sl"]
  Cmd = [
    "scilab-cli -nb -f QR.sci > OUTFILE",
    "sed -E -f QR.sed QR.sed > OUTFILE",
    "spl2c < QR.spl > QR.spl.c && gcc -z muldefs -o QR -I ./vendor/local/include -L ./vendor/local/lib QR.spl.c -lspl -lm && ./QR > OUTFILE",
    "slsh QR.sl > OUTFILE",
  ]
  Apt = ["scilab-cli", "sed", nil, "slsh"]
  def code
    <<-'END'.lines.map(&:strip).join
      (
        m00p=(PREV).scan(/.{1,1000}/m).map{|m00c|
          m00c=m00c.gsub(":",":c").gsub(34.chr,":q").gsub(39.chr,":a").gsub("%",":p").gsub("#",":h").gsub(N,":n").gsub(9.chr,":t");
          9.downto(0){|m00i|m00c=m00c.gsub(B*(1<<m00i),":#{m00i}")};
          "printf(\" #:"+m00c+"\\n\")\n"
        }*"";
        m00s="variable f=fopen(\"QR.sed\",\"r\"),s,b,i;\nwhile(0<fgets(&s,f))if(0==strncmp(s,\" #:\",3)){\nb=pack(\"C\",92);s=s[[3:strlen(s)-2]];\n_for i(0,9,1){s=strreplace(s,sprintf(\":%d\",i),b);b+=b;}\ns=strreplace(strreplace(strreplace(strreplace(s,\":q\",pack(\"C\",34)),\":a\",pack(\"C\",39)),\":p\",\"%\"),\":h\",pack(\"C\",35));\ns=strreplace(strreplace(strreplace(s,\":n\",pack(\"C\",10)),\":t\",pack(\"C\",9)),\":c\",\":\");\n()=fputs(s,stdout);\n}\n";
        f(
          "1d;/^ #:/d;s/^ #//;s/1/ the sum of a son and0/g;s/0/ twice/g\n #The Relay of Quine.\n #Ajax, a man.\n #Ford, a man.\n #Act i: Quine.\n #Scene i: Relay.\n #[Enter Ajax and Ford]\n #Ajax:\n #"+
          m00s.bytes.map{|m00b|"You are as bad as"+("%b"%m00b)[1..].reverse+" a son.Speak thy mind."}*"",7
        ){"printf#$S\n"}+"printf(\"\\n #[Exeunt]\\n\")\n"+m00p+"quit"
      )
    END
  end

  def check(prev)
    raise if prev.bytes.max.to_i > 126
  end
end

class Scheme < CodeGen
  File = "QR.scm"
  Cmd = "$(SCHEME) QR.scm > OUTFILE"
  Apt = "guile-3.0"
  Code = %q(%((display"#{e[PREV]}")))
end

class Scala < CodeGen
  File = "QR.scala"
  Cmd = "scalac QR.scala && scala QR > OUTFILE"
  Apt = "scala"
  def code
    <<-'END'.lines.map {|l| l.strip }.join
      "
        object QR extends App{
          #{f(PREV,196){%(print#$S;)}}
        }
      "
    END
  end

  def check(prev)
    # the JVM allows up to 65535 bytes per CONSTANT_Utf8
    prev.scan(/.{1,#{ 196 * 255 }}/m) { raise if $&.bytesize > 65535 }
  end
end

class Rust < CodeGen
  File = "QR.rs"
  Cmd = "rustc QR.rs && ./QR > OUTFILE"
  Apt = "rustc"
  Code = %q(%(fn main(){print!("{}",#{E[PREV]})}))
end

# ---- Added past 138: eleven languages between xonsh and Rust ----
# Run order: xonsh -> mksh -> yash -> Elvish -> VHDL -> Genie -> XQuery
#                  -> Koto -> Coconut -> Anko -> Tengo -> Rhai -> Rust
# All thirteen use raw/verbatim strings or quote-doubling, so none of them doubles
# backslashes (each doubling layer would double the size of every earlier step).
# Every source nests all later ones, so a raw-string step is placed only before
# steps that never emit its closing delimiter; each check() guards that.

class Rhai < CodeGen
  File = "QR.rhai"
  Cmd = "rhai-run QR.rhai > OUTFILE"
  Apt = [nil] # cargo install rhai --features bin-features --bin rhai-run
  # back-tick strings take no escapes; print appends a newline (harmless for Rust)
  Code = %q(%(print(`#{PREV}`);))

  def check(prev)
    raise if prev.include?("`") || prev.include?("${")
  end
end

# RUN_AFTER: Tengo
# Nickel multiline string m%%%%%"..."%%%%% is raw (only "%%%%% and %%%%%{ are special). One line.
class Nickel < CodeGen
  Name = "Nickel"
  File = "QR.ncl"
  Cmd = "nickel export --format text QR.ncl > OUTFILE"
  Apt = [nil]                # cargo install nickel-lang-cli 1.18.0, see installs.txt
  Code = %q(%(m%%%%%"#{PREV}"%%%%%))
  def check(prev)
    raise "Nickel: payload holds the end mark or an interpolation, or a newline" if prev.include?('"%%%%%') || prev.include?("%%%%%{") || prev.include?("\n")
  end
end

# Trailing-newline languages (CUE, Starlark, Rego): their print adds one "\n" after the payload. Only QR.rb is
# compared at the end, so each sits right before a step whose language ignores one extra newline at the end
# of its source (Macaulay2, AspectJ, Octave). A merge that puts a new step right after one of these must keep that true.

class Tengo < CodeGen
  File = "QR.tengo"
  Cmd = "tengo QR.tengo > OUTFILE"
  Apt = [nil] # go install github.com/d5/tengo/v2/cmd/tengo
  # raw back-tick string; each back-tick is spliced in as "`"
  Code = %q(%(fmt:=import("fmt");fmt.print(`#{(PREV).gsub("`",%(`+"`"+`))}`)))
end

class Anko < CodeGen
  File = "QR.ank"
  Cmd = "anko QR.ank > OUTFILE"
  Apt = [nil] # go install github.com/mattn/anko
  Code = %q(%(fmt=import("fmt");fmt.Print(`#{(PREV).gsub("`",%(`+"`"+`))}`)))
end


# RUN_AFTER: Macaulay2
# Merge patch (milestone 284): Coconut moved from after Macaulay2 to after ChezScheme (~150 KB vs 56 MB), so Dart anchors directly on Macaulay2.
# Dart one-line raw string r'...' has no escapes (no triple quotes: Genie upstream refuses """ and Coconut '''): adds zero backslashes (clean corridor).
class Dart < CodeGen
  Name = "Dart"
  File = "QR.dart"
  Cmd = "dart run QR.dart > OUTFILE"
  Apt = [nil]                # official SDK zip, see installs.txt
  # Merge patch (milestone 248): B02's Falcon source holds two ' downstream. Each ' closes the raw string, adds a
  # plain "'" literal and reopens it: r'..'"'"r'..' (Dart joins adjacent string literals).
  Code = %q(%(import 'dart:io';void main(){stdout.write(r'#{PREV.gsub(?',%('"'"r'))}');}))
  def check(prev)
    raise "Dart: payload holds a newline (one-line raw string)" if prev =~ /\n/
    raise "Dart: non-ASCII byte" if prev =~ /[^\x00-\x7f]/n
  end
end

class Macaulay2 < CodeGen
  Name = "Macaulay2"
  File = "QR.m2"
  Cmd = "M2 --script QR.m2 > OUTFILE"
  Apt = "macaulay2"
  # /// ... /// is a raw string: no escaping, so it adds no backslashes
  Code = %q(%(<< ///#{PREV}///))
  def check(prev); raise if prev.include?("///"); end
end

# RUN_AFTER: Koto
# CUE raw string ###"..."### (same rules as Pkl). cue export --out text adds a newline; Macaulay2 (next) ignores it.
class CUE < CodeGen
  Name = "CUE"
  File = "QR.cue"
  Cmd = "cue export --out text -e o QR.cue > OUTFILE"
  Apt = [nil]                # go install cuelang.org/go/cmd/cue@v0.17.1, see installs.txt
  Code = %q(%(o:###"#{PREV}"###))
  def check(prev)
    raise "CUE: payload holds \"###, \\### or a newline" if prev.include?('"###') || prev.include?("\\###") || prev.include?("\n")
  end
end

class Koto < CodeGen
  File = "QR.koto"
  Cmd = "koto QR.koto > OUTFILE"
  Apt = [nil] # cargo install koto_cli
  Code = %q(%(io.stdout().write r#'#{PREV}'#))

  def check(prev)
    raise if prev.include?("'#")
  end
end

# RUN_AFTER: XQuery
# Pkl raw string ##"..."## (only "## ends it and \## starts an escape; two #s because CUE's "# is downstream).
# pkl eval prints output.text as is. One line.
class Pkl < CodeGen
  Name = "Pkl"
  File = "QR.pkl"
  Cmd = "pkl eval QR.pkl > OUTFILE"
  Apt = [nil]                # Pkl 0.33.0 release binary, see installs.txt
  Code = %q(%(output{text=####"#{PREV}"####}))
  def check(prev)
    raise "Pkl: payload holds \"####, \\#### or a newline" if prev.include?('"####') || prev.include?("\\####") || prev.include?("\n")
  end
end

class XQuery < CodeGen
  File = "QR.xq"
  Cmd = "basex QR.xq > OUTFILE"
  Apt = "basex"
  # XQuery 3.1 string constructor: raw except for "]``" and "`{"
  Code = %q(%(``[#{PREV}]``))

  def check(prev)
    raise if prev.include?("]``") || prev.include?("`{")
  end
end

# RUN_AFTER: Genie
# Nix indented string ''...'': no backslash escapes; '' is written ''' and ${ is written ''${.
# One line (indented strings strip common indentation, so check() refuses newlines and leading spaces).
class Nix < CodeGen
  Name = "Nix"
  File = "QR.nix"
  Cmd = "nix eval --extra-experimental-features nix-command --raw --file QR.nix > OUTFILE"
  Apt = "nix-bin"
  Code = %q(%(''#{PREV.gsub("''","'''").gsub("${","''${")}''))
  def check(prev)
    raise "Nix: payload has '${, ends in ', starts with a space or holds a newline" if prev.include?("'${") || prev.end_with?("'") || prev =~ /\A\s/ || prev.include?("\n")
  end
end

class Genie < CodeGen
  File = "QR.genie.gs" # valac needs .gs for Genie; QR.gs is GolfScript's
  Cmd = "valac QR.genie.gs && ./QR.genie > OUTFILE"
  Apt = "valac"
  # verbatim """...""" string
  Code = %q(%(init\n\tstdout.printf("%s","""#{PREV}""")\n))

  def check(prev)
    raise if prev.include?('"""') || prev.end_with?('"')
  end
end

class VHDL < CodeGen
  File = "QR.vhdl"
  Cmd = "ghdl -a QR.vhdl && ghdl -e qr && ghdl -r qr > OUTFILE"
  Apt = "ghdl"
  # "" for a quote; control characters are spliced in with character'val
  Code = %q(%(use std.textio.all;entity QR is end;architecture A of QR is begin process begin write(output,"#{(PREV).gsub(?",%("")).gsub(/[\x00-\x1f\x7f]/){%("&character'val(#{$&.ord})&")}}");wait;end process;end;))
end

# RUN_AFTER: Elvish
class Boo < CodeGen
  File = "QR.boo"
  Cmd = "booi QR.boo > OUTFILE"
  Apt = [nil] # trusty boo 0.9.5 .debs on mono, see installs.txt
  # Merge patch (milestone 284): Mono caps an assembly's #US user-string metadata stream at 16 MB (~8.38M chars).
  # Read QR.boo from disk past the '#' comment mark on one single line (no newlines for Hush upstream).
  Code = %q((b02p=(PREV);"s=System.IO.File.ReadAllText(\"QR.boo\");System.Console.Write(s.Substring(s.IndexOf(char(35))+1).Replace(\"@n\",\""+B+"n\").Replace(\"@a\",\"@\"))#"+b02p.gsub("@","@a").gsub(N,"@n")))
  def check(prev); raise if prev.include?("\r"); end
end

# RUN_AFTER: Elvish
# RUN_AFTER: PowerShell
# RUN_AFTER: Nushell
# RUN_AFTER: IonShell
# RUN_AFTER: YSH
# RUN_AFTER: Murex
# RUN_AFTER: Hush
class EsShell < CodeGen
  Name = "es"
  File = "QR.es"
  Cmd = "es QR.es > OUTFILE"
  Apt = [nil]
  Code = %q(%(echo -n '#{(PREV).gsub(?',%(''))}'))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r") || prev.start_with?("-")
  end
end

class Hush < CodeGen
  Name = "Hush"
  File = "QR.hsh"
  Cmd = "hush QR.hsh > OUTFILE"
  Apt = [nil]
  Code = %q(%(std.read(std.replace(std.replace(std.replace("#{(PREV).gsub('@','@C').gsub(B,'@A').gsub('"','@B')}","@B","#{B}\""),"@A","#{B+B}"),"@C","@"))))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r") || prev.include?("\n")
  end
end

class Murex < CodeGen
  Name = "Murex"
  File = "QR.mx"
  Cmd = "murex QR.mx > OUTFILE"
  Apt = [nil]
  Code = %q(%(tout str '#{(PREV).gsub(?',%(';tout str "'";tout str '))}'))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r")
  end
end

class YSH < CodeGen
  Name = "YSH"
  File = "QR.ysh"
  Cmd = "ysh QR.ysh > OUTFILE"
  Apt = [nil]
  Code = %q(%(write --sep '' --end '' -- #{(PREV).scan(/.{1,32000}/m).map{|s|"r'"+s.gsub(?',%(' "'" r'))+"'"}.join(" ")}))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r")
  end
end

class IonShell < CodeGen
  Name = "Ion"
  File = "QR.ion"
  Cmd = "ion QR.ion > OUTFILE"
  Apt = [nil]
  Code = %q(%(echo -n '#{(PREV).gsub(?',%('"'"'))}'))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r") || prev.start_with?("-")
  end
end

class Nushell < CodeGen
  Name = "Nushell"
  File = "QR.nu"
  Cmd = "nu --no-config-file QR.nu > OUTFILE"
  Apt = [nil]
  Code = %q(%(print -n r#####'#{PREV}'#####))
  def check(prev)
    raise if prev.include?("'#####") || prev.include?("\0") || prev.include?("\r")
  end
end

class PowerShell < CodeGen
  Name = "PowerShell"
  File = "QR.ps1"
  Cmd = "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 POWERSHELL_TELEMETRY_OPTOUT=1 pwsh -NoProfile -NonInteractive -File QR.ps1 > OUTFILE"
  Apt = [nil]
  Code = %q(%([Console]::Out.Write('#{(PREV).gsub('@','@A').gsub(?', '@B').gsub('"','@C').gsub(B,'@D')}'.Replace('@D',[string][char]92).Replace('@C',[string][char]34).Replace('@B',[string][char]39).Replace('@A','@'))))
  def check(prev)
    raise if !prev.ascii_only? || prev.include?("\0") || prev.include?("\r")
  end
end

# RUN_AFTER: Elvish
# RUN_AFTER: VLang
# RUN_AFTER: Hare
# RUN_AFTER: C3
# RUN_AFTER: Nelua
class Zig < CodeGen
  Name = "Zig"
  File = "QR.zig"
  Cmd = "zig run QR.zig > OUTFILE"
  Apt = [nil]
  Code = %q(%(pub fn main()!void{try @import("std").io.getStdOut().writeAll(\n#{B*2+(PREV).gsub(N){N+B*2}}\n);}))
  def check(prev)
    raise if prev =~ /[\x00-\x09\x0b-\x1f\x7f]/ || !prev.ascii_only?
  end
end

class Nelua < CodeGen
  Name = "Nelua"
  File = "QR.nelua"
  Cmd = "nelua --no-cache QR.nelua > OUTFILE"
  Apt = [nil]
  Code = %q(%(require 'io'\nio.write([===[#{PREV}]===])))
  def check(prev)
    raise if prev.include?("]===") || prev.include?("\r") || prev.include?("\0") || prev.start_with?("\n")
  end
end

class C3 < CodeGen
  Name = "C3"
  File = "QR.c3"
  Cmd = "c3c compile QR.c3 -o QR && ./QR > OUTFILE"
  Apt = [nil]
  Code = %q(%(import std::io;fn void main(){io::print(`#{d[PREV,?`]}`);}))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r")
  end
end

class Hare < CodeGen
  Name = "Hare"
  File = "QR.ha"
  Cmd = "hare build -q -o QR QR.ha && ./QR > OUTFILE"
  Apt = "hare"
  Code = %q(%(use fmt;export fn main()void={fmt::print(`#{(PREV).gsub(96.chr,%(`"`"`))}`)!;};))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r") || !prev.ascii_only?
  end
end

class VLang < CodeGen
  Name = "V"
  File = "QR.vlang.v"
  Cmd = "v run QR.vlang.v > OUTFILE"
  Apt = [nil]
  Code = %q(%(fn main(){#{(PREV).split(?',-1).map{|s|%(print(r'#{s}');)}*%(print("'");)}}))
  def check(prev)
    raise if prev.include?("\0") || prev.include?("\r")
  end
end

# RUN_AFTER: Elvish
# RUN_AFTER: Rocq
# RUN_AFTER: Lean4
class Idris2 < CodeGen
  Name = "Idris 2"
  File = "QR.idr"
  Cmd = "idris2 --exec main QR.idr > OUTFILE"
  Apt = [nil]
  Code = %q(%(module Main\nmain : IO ()\nmain = putStr ##"""\n#{PREV}\n"""##\n))
  def check(prev)
    raise "Idris 2: payload holds the raw-string end mark" if prev.include?(%("##)) || prev.include?('\##')
    raise "Idris 2: non-ASCII byte" if prev =~ /[^\x00-\x7f]/n
  end
end

class Lean4 < CodeGen
  Name = "Lean 4"
  File = "QR.lean"
  Cmd = "lean --run QR.lean > OUTFILE"
  Apt = [nil]
  Code = %q(%(def main : IO Unit := IO.print r###"#{PREV}"###\n))
  def check(prev)
    raise "Lean 4: payload holds the raw-string end mark" if prev.include?(%("###))
    raise "Lean 4: non-ASCII byte" if prev =~ /[^\x00-\x7f]/n
  end
end

class Rocq < CodeGen
  Name = "Rocq"
  File = "QR_rocq.v"
  Cmd = "coqc QR_rocq.v && printf 'module Pstring=struct let unsafe_of_string s=s end\\n' | cat - QR_rocq.ml > QR_rocq_run.ml && ocaml QR_rocq_run.ml > OUTFILE && rm -f QR_rocq.ml QR_rocq_run.ml QR_rocq.vo QR_rocq.vok QR_rocq.vos QR_rocq.glob"
  Apt = "coq"
  Code = %q((b09p=(PREV);b09c=(0...b09p.bytesize).step(8000000).map{|b09i|"\""+d[b09p.byteslice(b09i,8000000)]+"\"%pstring"}.join(";");"From Coq Require Import PrimString List Extraction.\nImport ListNotations.\nExtract Constant string => \"Stdlib.String.t\".\nExtract Inductive list => \"list\" [ \"[]\" \"(::)\" ].\nParameter p : list string -> unit.\nExtract Constant p => \"(List.iter print_string)\".\nDefinition main := p ["+b09c+"].\nExtraction \"QR_rocq.ml\" main.\n"))
  def check(prev)
    raise "Rocq: non-ASCII byte" if prev =~ /[^\x00-\x7f]/n
  end
end

class Elvish < CodeGen
  File = "QR.elv"
  Cmd = "elvish QR.elv > OUTFILE"
  Apt = "elvish"
  Code = %q(%(print '#{(PREV).gsub(?',%(''))}'))
end

# RUN_AFTER: Yash
# YueScript 0.34.3 (source build, standalone yue binary with its own Lua 5.4). io.write adds no newline.
class YueScript < CodeGen
  Name = "YueScript"
  File = "QR.yue"
  Cmd = "yue -e QR.yue > OUTFILE"
  Apt = [nil]                # source build v0.34.3, see installs.txt
  Code = %q(%(io.write [==[#{PREV}]==]))
  def check(prev)
    raise "YueScript: payload holds ]==]" if prev.include?("]==]")
    raise "YueScript: leading newline" if prev.start_with?("\n")
    raise "YueScript: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class Yash < CodeGen
  Name = "yash"
  File = "QR.yash"
  Cmd = "!yash QR.yash > OUTFILE"   # "!" = ulimit -s unlimited on the same line (Makefile.gen.rb)
  Apt = "yash"
  Code = %q(%(printf %s '#{(PREV).gsub(?',%('"'"'))}'))

  def check(prev)
    raise if prev.include?("\0")
  end
end

# RUN_AFTER: BusyBoxAsh
# Arturo 0.10.0 (mini build). {: ... :} is a raw verbatim string (check refuses ":}"). prints adds no newline.
class Arturo < CodeGen
  Name = "Arturo"
  File = "QR.art"
  Cmd = "arturo QR.art < /dev/null > OUTFILE"
  Apt = [nil]                # release zip v0.10.0 (mini), see installs.txt
  Code = %q(%(prints {:#{PREV}:}))
  def check(prev)
    raise "Arturo: payload holds :}" if prev.include?(":}")
    raise "Arturo: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

class BusyBoxAsh < CodeGen
  Name = "BusyBox ash"
  File = "QR.bbash"
  Cmd = "busybox ash QR.bbash > OUTFILE"
  Apt = "busybox-static"
  Code = %q(%(printf %s '#{(PREV).gsub(?',%('"'"'))}'))
  def check(prev); raise if prev.include?("\0"); end
end

class Mksh < CodeGen
  Name = "mksh"
  File = "QR.mksh"
  Cmd = "mksh QR.mksh > OUTFILE"
  Apt = "mksh"
  Code = %q(%(print -nr -- '#{(PREV).gsub(?',%('"'"'))}'))

  def check(prev)
    raise if prev.include?("\0")
  end
end

# ---- Added past 128: ten languages between Ruby and Rust ----
# Run order: Ruby -> dash -> groff -> Hy -> Jsonnet -> newLISP -> NQP -> PicoLisp
#                 -> Racket -> SQL -> xonsh -> Rust
# Racket and newLISP were moved here from code-gen-pool.rb (newLISP's template was
# changed to a [text] block, since "..." strings are capped at 2048 chars).

class Xonsh < CodeGen
  Name = "xonsh"
  File = "QR.xsh"
  Cmd = "xonsh --no-rc QR.xsh > OUTFILE"
  Apt = "xonsh"
  Code = %q(%(print("#{e[PREV]}",end="")))
end

# RUN_AFTER: SQL
# RUN_AFTER: AspectCpp
class ParrotAsm < CodeGen
  Name = "Parrot asm (PASM)"
  File = "QR.pasm"
  Cmd = "parrot QR.pasm > OUTFILE"
  Apt = [nil] # built from source in installs.txt
  # single-quoted heredoc: raw text, no escaping
  Code = %q(%(print <<'Q'\n#{PREV}\nQ\nend\n))

  def check(prev)
    raise if prev =~ /^Q$/        # it ends the heredoc
    raise if prev.include?("\r")
  end
end

# ---- escaping languages: between Ksh > Lazy K > LiveScript and LLVM asm ----
# Java (run 89) LZ78-encodes everything below it at generation time, so the escape characters these
# add are only doubled 3 times above them, and Groovy's no-"_"/no-newline rule never sees them.
# GSL first: it must not get Jasmin-style lines starting with "." (it would run them as commands).

class AspectCpp < CodeGen
  Name = "AspectC++"
  File = "QR.cc"
  Cmd = "ag++ --keywords -o QR QR.cc && ./QR > OUTFILE"
  Apt = "aspectc++"
  # the text is printed by a real aspect (advice on main), so plain g++ can't build this file
  # C++11 raw string: no escaping, so it adds no backslashes for the layers above to double.
  # "} }" not "}}": Mustache (step 99) hides its YAML in a {{! }} comment
  Code = %q(%(#include<cstdio>\naspect Q{advice execution("int main()"):before(){fputs(R"Q(#{PREV})Q",stdout);} };int main(){}))

  def check(prev)
    raise if prev.include?(')Q"') # it closes the raw string
    raise if prev.include?("\r")  # the compiler may turn CR LF into LF inside the raw string
  end
end

class SQL < CodeGen
  Name = "SQL (SQLite)"
  File = "QR.sql"
  Cmd = "sqlite3 < QR.sql > OUTFILE"
  Apt = "sqlite3"
  Code = %q(%(SELECT'#{d[PREV,?']}';))
end

class RacketLang < CodeGen
  Name = "Racket"
  File = "QR.rkt"
  Cmd = "racket QR.rkt > OUTFILE"
  Apt = "racket"
  Code = %q("#lang racket/base\n(display \"#{e[PREV]}\")")
end

class PicoLisp < CodeGen
  File = "QR.l"
  Cmd = "pil QR.l > OUTFILE"
  Apt = "picolisp"
  # backslash, double quote and ^ (control-char prefix) are escaped with a backslash
  Code = %q(%((prin "#{Q[PREV,/[\\\\"^]/]}")(bye)))
end

class NQP < CodeGen
  File = "QR.nqp"
  Cmd = "nqp QR.nqp > OUTFILE"
  Apt = "nqp"
  # single-quoted strings: only backslash and ' need escaping
  Code = %q(%(print('#{Q[PREV,/[\\\\']/]}')))
end

class NewLISPLang < CodeGen
  Name = "newLISP"
  File = "QR.nl"
  Cmd = "newlisp -n QR.nl > OUTFILE"
  Apt = "newlisp"
  Code = %q(%((print [text]#{PREV}[/text])(exit)))

  def check(prev)
    raise if prev.include?("[/text]") # it closes the raw text block
  end
end

class Jsonnet < CodeGen
  File = "QR.jsonnet"
  Cmd = "jsonnet -S QR.jsonnet > OUTFILE"
  Apt = "jsonnet"
  Code = %q(E[PREV])
end

class Hy < CodeGen
  File = "QR.hy"
  Cmd = "hy QR.hy > OUTFILE"
  Apt = "hy"
  Code = %q(%((print "#{e[PREV]}" :end "")))
end

class Groff < CodeGen
  Name = "groff"
  File = "QR.roff"
  Cmd = "groff -z QR.roff 2> OUTFILE"
  Apt = "groff"
  # .tm1 prints the rest of the line to stderr in copy mode, where \\ is a backslash
  Code = %q((PREV).lines.map{|l|".tm1 \""+l.chomp.gsub(B){B*2}+N}*"")
end

class Dash < CodeGen
  Name = "dash"
  File = "QR.dash"
  Cmd = "dash QR.dash > OUTFILE"
  Apt = "dash"
  Code = %q(%(printf %s '#{(PREV).gsub(?',%('"'"'))}'))

  def check(prev)
    raise if prev.include?("\0") # shell words cannot hold NUL
  end
end

# ---- Added past 138: Ruby -> BASIC -> ChucK -> dash ----
# ChucK strings need backslash escapes. A doubling layer here grows only its own
# file; anywhere later it would double every earlier step too.
class ChucK < CodeGen
  File = "QR.ck"
  Cmd = "chuck --silent QR.ck > OUTFILE"
  Apt = "chuck"
  # chout flushes only at a newline, so flush at the end
  Code = %q(%(chout <= "#{e[PREV]}";chout.flush();))
end

class BwBASIC < CodeGen
  Name = "BASIC (bwBASIC)"
  File = "QR.bas"
  Cmd = "bwbasic QR.bas > /dev/null; cat QR.out > OUTFILE"
  Apt = "bwbasic"
  # runs right after Ruby, so its source is never escaped again
  # the banner goes to stdout, so the program writes QR.out; lines are packed to
  # at most 242 chars (bwBASIC's limit is 255)
  Code = %q(%(Q$=CHR$(34)\nOPEN "O",#1,"QR.out"\n#{(PREV).chars.inject([""]){|a,c|x=c==?" ? %(";Q$;") : c==N ? %(";CHR$(10);") : c;a[-1].size+x.size>230&&a<<"";a[-1]<<x;a}.map{|l|%(PRINT #1,"#{l}";\n)}*""}CLOSE #1\nSYSTEM\n))

  def check(prev)
    raise if prev =~ /[\x00-\x09\x0b-\x1f]/ # only newline is spliced in
  end
end

# RUN_AFTER: Ruby_
# Merge patch (milestone 248): moved from Yabasic to right after Ruby. K escapes \ " and newline, and in the full
# merge every middle slot sits under mame's escaping layers: at Yabasic the peak payload was 13.5 MB (212 was 3.1 MB).
# Right after Ruby the growth doesn't compound (README rule for steps that double backslashes).
# K (ngn/k) strings escape \ " and newline (\n). `1:x writes x to stdout as is; the last line \\ exits. ngn/k caps a
# literal at 511 chars and one expression at ~100 joined pieces (probe 5), so the payload goes out in 250-char pieces
# (<= 500 escaped), 60 per line (probe 5: 80 pass): `1:"","..","..". The leading "" keeps a 1-char piece a string, not a char atom.
# Slot: before the CoffeeScript/Common Lisp chain (run 62), which re-escapes every quote and newline after it many
# times over. Tried Nov 14 (peak with all of B11): GolfScript 8.6 MB, Awk 6.38, BeanShell 6.33, CSharp_Chef 6.14,
# Zoem 6.06, Yabasic 6.04 (base 157 is 5.54).
class K < CodeGen
  Name = "K (ngn/k)"
  File = "QR.k.k"
  Cmd = "ngnk QR.k.k < /dev/null > OUTFILE"
  Apt = [nil]                # ngn/k source build (pinned commit), see installs.txt
  Code = %q(%(#{PREV.scan(/.{1,250}/m).each_slice(60).map{|g|"`1:"+([""]+g).map{|s|?"+e[s]+?"}*?,}*N}#{N+B+B+N}))
  def check(prev)
    raise "K: non-printable byte" if prev =~ /[^\n\x20-\x7e]/
  end
end

# RUN_AFTER: Ruby_
# RUN_AFTER: SNOBOL4
# RUN_AFTER: Simula
# RUN_AFTER: Oberon
# RUN_AFTER: Euphoria
# RUN_AFTER: ALGOL60
class BCPL < CodeGen
  Name = "BCPL"
  File = "QR.b"
  Cmd = "rm -f QR QR.out && BCPLROOT=/opt/BCPL/cintcode BCPLPATH=/opt/BCPL/cintcode/cin64 BCPLHDRS=/opt/BCPL/cintcode/g BCPLSCRIPTS=/opt/BCPL/cintcode/s /opt/BCPL/cintcode/bin/cintsys64 -c 'bcpl QR.b to QR; QR' >/dev/null && cat QR.out > OUTFILE && rm -f QR QR.out"
  Apt = [nil]
  Code = %q((b15m=(PREV);b15n={"\x7e"=>"\x7e\x7e","\x22"=>"\x7eq","/"=>"\x7es",B=>"\x7eb",N=>"\x7en","\x09"=>"\x7et"};["GET \"libhdr\"","LET start() = VALOF {","LET a = findinput(\"QR.b\")","LET o = findoutput(\"QR.out\")","LET c = 0","selectinput(a); selectoutput(o)","c := rdch()","UNTIL c = 64 DO c := rdch()","c := rdch()","UNTIL c = endstreamch DO {","UNLESS c = 10 DO UNLESS c = 47 DO {","IF c = 126 DO {","c := rdch()","c := c=113->34,c=115->47,c=98->92,c=110->10,c=116->9,126","}","wrch(c)","}","c := rdch()","}","endread(); endwrite(); RESULTIS 0 }","//@",*b15m.scan(/.{1,120}/m).map{|b15q|"//"+b15q.gsub(/[\x7e\x22\/\\\\\n\x09]/){b15n[$&]}}].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class ALGOL60 < CodeGen
  Name = "ALGOL 60"
  File = "QR.alg"
  Cmd = "marst QR.alg -o QR.alg.c && gcc QR.alg.c -lalgol -lm -o QR && ./QR < QR.alg > OUTFILE && rm -f QR QR.alg.c"
  Apt = [nil]
  Code = %q((b15p=(PREV);b15r={"."=>"..","\x22"=>".q","\x27"=>".a",B=>".b",N=>".n","\x20"=>".s","\x09"=>".t",":"=>".d",";"=>".m","\x21"=>".x"};b15u=" \x21#$%&\x27()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]\x5e_\x60abcdefghijklmnopqrstuvwxyz{|}\x7e"+B+"n"+B+"t";["begin comment \x21"+b15p.scan(/.{1,100}/m).map{|b15k|b15k.gsub(/[.\x22\x27\\\\\n\x20\x09:;\x21]/){b15r[$&]}}.join(N)+":;","integer c;","procedure r;inchar(0,\""+b15u+"\",c);","L1:r;if c\x21=2 then go to L1;","L2:r;if c=26 then go to L3;","if c=94 then go to L2;","if c=14 then begin r;","if c=80 then outstring(1,\""+B+"x22\")","else if c=64 then outstring(1,\"\x27\")","else if c=65 then outstring(1,\""+B+"x5c\")","else if c=77 then outstring(1,\""+B+"n\")","else if c=82 then outstring(1,\" \")","else if c=83 then outstring(1,\""+B+"t\")","else if c=67 then outstring(1,\":\")","else if c=76 then outstring(1,\";\")","else if c=87 then outstring(1,\"\x21\")","else outstring(1,\".\")","end else outchar(1,\""+b15u+"\",c);","go to L2;","L3:end"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class Euphoria < CodeGen
  Name = "Euphoria"
  File = "QR.ex"
  Cmd = "eui QR.ex > OUTFILE"
  Apt = [nil]
  Code = %q((b15h=(PREV);b15j={"\x7e"=>"\x7e\x7e","-"=>"\x7ed","\x22"=>"\x7eq","\x27"=>"\x7ea",B=>"\x7eb",N=>"\x7en","\x20"=>"\x7es","\x09"=>"\x7et"};["integer f=open(\"QR.ex\",\"rb\"),c=getc(f)","while c!=64 do c=getc(f) end while","c=getc(f)","while c!=-1 do","if c!=10 and c!=45 then","if c=126 then c=getc(f)","if c=113 then c=34 elsif c=97 then c=39 elsif c=98 then c=92 elsif c=110 then c=10 elsif c=100 then c=45 elsif c=115 then c=32 elsif c=116 then c=9 else c=126 end if","end if","puts(1,c)","end if","c=getc(f)","end while","--@",*b15h.scan(/.{1,100}/m).map{|b15l|"--"+b15l.gsub(/[\x7e\-\x22\x27\\\\\n\x20\x09]/){b15j[$&]}}].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class Oberon < CodeGen
  Name = "Oberon"
  File = "QR.obn"
  Cmd = "rm -rf QR .obnc && obnc QR.obn >/dev/null && ./QR > OUTFILE && rm -rf QR .obnc"
  Apt = [nil]
  Code = %q((b15e=(PREV);b15f={"\x7e"=>"\x7e\x7e","\x22"=>"\x7eq","\x27"=>"\x7ea",B=>"\x7eb",N=>"\x7en","("=>"\x7eo",")"=>"\x7ep","*"=>"\x7ex","\x20"=>"\x7es","\x09"=>"\x7et"};["MODULE QR;","IMPORT Files,Out;","VAR f:Files.File;r:Files.Rider;b:BYTE;c:INTEGER;","BEGIN f:=Files.Old(\"QR.obn\");Files.Set(r,f,0);","REPEAT Files.Read(r,b) UNTIL b=64;","Files.Read(r,b);","WHILE \x7er.eof DO c:=b;","IF (c#10)&(c#42)&(c#41) THEN","IF c=126 THEN Files.Read(r,b);c:=b;","IF c=113 THEN Out.Char(22X)","ELSIF c=97 THEN Out.Char(27X)","ELSIF c=98 THEN Out.Char(5CX)" ,"ELSIF c=110 THEN Out.Ln","ELSIF c=111 THEN Out.Char(28X)","ELSIF c=112 THEN Out.Char(29X)","ELSIF c=120 THEN Out.Char(2AX)","ELSIF c=115 THEN Out.Char(20X)","ELSIF c=116 THEN Out.Char(09X)","ELSE Out.Char(7EX) END","ELSE Out.Char(CHR(c)) END END;","Files.Read(r,b) END END QR.","(*@",*b15e.scan(/.{1,100}/m).map{|b15g|b15g.gsub(/[\x7e\x22\x27\\\\\n()*\x20\x09]/){b15f[$&]}},"*)"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only?
    raise if prev.include?("\r")
  end
end

class Simula < CodeGen
  Name = "Simula"
  File = "QR.sim"
  Cmd = "rm -f QR QR.c && cim -q QR.sim >/dev/null 2>&1 && ./QR > OUTFILE && rm -f QR QR.c"
  Apt = [nil]
  Code = %q((b15b=(PREV);b15c={"\x7e"=>"\x7e\x7e","\x22"=>"\x7eq","\x27"=>"\x7ea",B=>"\x7eb",N=>"\x7en","\x20"=>"\x7es",";"=>"\x7em","$"=>"\x7ed","%"=>"\x7ep","\x09"=>"\x7et"};["Begin Ref(InFile) f;Character c;Integer k;","SysOut.Image:-Blanks(500);f:-New InFile(\"QR.sim\");f.Open(Blanks(240));k:=0;","While k<>64 Do Begin c:=f.InChar;k:=Rank(c);End;k:=0;","While k<>36 Do Begin c:=f.InChar;k:=Rank(c);","If k<>32 And k<>36 Then Begin","If k=126 Then Begin c:=f.InChar;k:=Rank(c);","If k=113 Then OutChar(Char(34))","Else If k=97 Then OutChar(Char(39))","Else If k=98 Then OutChar(Char(92))","Else If k=110 Then OutImage","Else If k=115 Then OutChar(Char(32))","Else If k=109 Then OutChar(Char(59))","Else If k=100 Then OutChar(Char(36))","Else If k=112 Then OutChar(Char(37))","Else If k=116 Then OutChar(Char(9))","Else OutChar(Char(126));","End Else OutChar(c);End;End;f.Close;End;","\x21@"+b15b.scan(/.{1,100}/m).map{|b15d|b15d.gsub(/[\x7e\x22\x27\\\\\n\x20;$%\x09]/){b15c[$&]}}.join(N)+"$;"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.include?("\r")
  end
end

class SNOBOL4 < CodeGen
  Name = "SNOBOL4"
  File = "QR.sno"
  Cmd = "snobol4 -b QR.sno > OUTFILE"
  Apt = [nil]
  Code = %q((b15z=(PREV);b15y={"\x7e"=>"\x7e\x7e","\x22"=>"\x7eq","\x27"=>"\x7ea",B=>"\x7eb","$"=>"\x7ed","\x09"=>"\x7et"};[" INPUT(.F,10,400,\x27QR.sno\x27)","L1 S = F :F(END)"," IDENT(S,\x27*@\x27) :F(L1)","L2 S = F :F(END)"," IDENT(S,\x27*$\x27) :S(END)"," S POS(0) \x27*\x27 =","L3 S \x27\x7e\x7e\x27 = CHAR(1) :S(L3)","L4 S \x27\x7eq\x27 = \x27\"\x27 :S(L4)","L5 S \x27\x7ea\x27 = \"\x27\" :S(L5)","L6 S \x27\x7eb\x27 = \x27"+B+"\x27 :S(L6)","L7 S \x27\x7ed\x27 = \x27$\x27 :S(L7)","L8 S \x27\x7et\x27 = CHAR(9) :S(L8)","L9 S CHAR(1) = \x27\x7e\x27 :S(L9)"," OUTPUT = S :(L2)","*@",*b15z.lines.map{|b15a|"*"+b15a.chomp.gsub(/[\x7e\x22\x27\\\\$\x09]/){b15y[$&]}},"*$","END"].join(N)+N))

  def check(prev)
    raise unless prev.ascii_only? && prev.end_with?("\n")
    raise if prev.include?("\r")
    raise if prev.lines.any? { |l| l.size > 380 }
  end
end

class Ruby_ < CodeGen
  Name = "Ruby"
  File = "QR.rb"
  Cmd = "ruby QR.rb > OUTFILE"
  Apt = "ruby"
  Code = nil
end

load "code-gen-pool.rb" if ENV["ALL"]

GenSteps = CodeGen::List.map {|s| s.gen_step }
RunSteps = CodeGen::List.reverse.flat_map {|s| s.run_steps }
