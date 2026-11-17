# Draws langs.png without the Ruby cairo/rsvg gems (same layout as src/langs.png.gen.rb).
# Needs: ruby, python3 with pycairo, rsvg-convert, and the Raleway + UnifrakturCook fonts.
# Usage (from the repo root): python3 tools/langs_png.py langs.png
import cairo, json, math, subprocess, sys, tempfile, os

MAME_128 = set([
    "Ruby", "Rust", "Scala", "Scheme", "Scilab", "sed", "Shakespeare", "S-Lang", "Squirrel", "Subleq",
    "SurgeScript", "Swift", "Tcl", "tcsh", "Thue", "TypeScript", "Unlambda", "Vala", "Velato", "Verilog",
    "Vimscript", "Whitespace", "XSLT", "Yabasic", "Yorick", "Zoem", "zsh", "Ada", "AFNIX", "Aheui",
    "Ante", "AspectJ", "Asymptote", "ATS", "Awk", "bash", "bc", "BeanShell", "Befunge", "BLC8",
    "Brainfuck", "C", "C++", "C#", "Chef", "Clojure", "CMake", "Cobol", "CoffeeScript", "Crystal",
    "D", "dc", "Dhall", "Elixir", "Erlang", "Execline", "F#", "FALSE", "Fennel", "Flex",
    "Fish", "Forth", "FORTRAN77", "Fortran90", "GAP", "GDB", "Gnuplot", "Go", "GolfScript", "G-Portugol",
    "Grass", "Groovy", "Gzip", "Haskell", "Haxe", "Icon", "INTERCAL", "Jasmin", "Java", "JavaScript",
    "Jq", "JSFuck", "Kotlin", "ksh", "LiveScript", "LOLCODE", "Lua", "M4", "Makefile", "MiniZinc",
    "Modula-2", "MSIL", "Mustache", "NASM", "Neko", "Nickle", "Nim", "Objective-C", "OCaml", "Octave",
    "Ook!", "PARI/GP", "Pascal", "PHP", "Piet", "Pike", "PostScript", "Prolog", "Python", "R",
    "Ratfor", "rc", "REXX", "Standard ML", "Visual Basic", "WebAssembly (Binary format)",
    "WebAssembly (Text format)", "ALGOL 68", "Common Lisp", "Emacs Lisp", "Gambas script",
    "GEL (Genius)", "Lazy K", "LLVM asm", "Parser 3", "Perl 5", "Perl 6", "Promela (Spin)"
])

names = json.loads(subprocess.check_output(
    ["ruby", "-rjson", "-e", 'require "./code-gen"; print JSON.generate(RunSteps.map(&:name))'], cwd="src"))
N = len(names)
Radius = 210.0 * N / 128.0          # keep mame's spacing per name
W = H = int(2 * (Radius + 245))     # room for outer labels around the full ring
Uro = 350.0 * Radius / 210.0
tmp = os.path.join(tempfile.mkdtemp(), "uroboros.png")
subprocess.check_call(["rsvg-convert", "-w", "2200", "src/uroboros.svg", "-o", tmp])
s = cairo.ImageSurface(cairo.FORMAT_ARGB32, W, H)
c = cairo.Context(s)
c.set_source_rgb(1, 1, 1); c.rectangle(0, 0, W, H); c.fill()
c.translate(W / 2, H / 2)
c.select_font_face("Raleway")
fo = cairo.FontOptions(); fo.set_antialias(cairo.ANTIALIAS_GRAY); c.set_font_options(fo)
ACC = (0.80, 0.16, 0.12)
for i, full in enumerate(names):
    c.save()
    angle = i / (N / 4.0)
    d = 1 if 1 < angle <= 3 else -1
    c.rotate(math.pi / 2 * (-angle if d < 0 else 2 - angle))
    if '(' in full and full.endswith(')'):
        k = full.index('('); name, sub = full[:k], full[k:]
    else:
        name, sub = full, ''
    c.set_font_size(13); e1 = c.text_extents(name)
    c.set_font_size(10); e2 = c.text_extents(sub)
    c.move_to(d * (Radius + 10) - (e1.x_advance + e2.x_advance if d < 0 else 0), 4.5)
    c.set_source_rgb(*((0, 0, 0) if full in MAME_128 else ACC))
    c.set_font_size(13); c.show_text(name)
    c.set_font_size(10); c.show_text(sub)
    c.restore()
c.set_source_rgb(0, 0, 0)
AC = 11 if N >= 240 else 7
for i in range(AC):
    c.save()
    c.rotate(math.pi * (2 * i) / AC - math.pi + 0.06)
    c.set_line_width(2); c.set_line_cap(cairo.LINE_CAP_SQUARE)
    c.new_path(); c.arc(0, 0, Radius, 0.0, math.pi * 2 / AC - 0.06); c.stroke()
    c.set_line_width(1)
    c.move_to(Radius, -8); c.line_to(Radius - 6, 2); c.line_to(Radius + 6, 2); c.fill()
    c.restore()
c.select_font_face("UnifrakturCook"); c.set_font_size(round(25 * Radius / 210.0 * 0.82))
title = f"{N}-Language Uroboros Quine"
e = c.text_extents(title)
height = Uro / 2 + e.height + 28
c.move_to(-e.width / 2, height / 2); c.show_text(title)
img = cairo.ImageSurface.create_from_png(tmp)
c.save()
c.translate(-Uro / 2, -height / 2)
sc = Uro / img.get_width(); c.scale(sc, sc)
c.set_source_surface(img, 0, 0); c.paint()
c.restore()
s.write_to_png(sys.argv[1])
