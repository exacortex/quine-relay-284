require_relative "code-gen"
require "cairo"
require "rsvg2"

# You need to install the two fonts: Raleway and UnifrakturCook.
# * https://www.google.com/fonts/specimen/Raleway
# * https://www.google.com/fonts/specimen/UnifrakturCook

%w(Raleway UnifrakturCook).each do |font|
  if `fc-list #{ font }`.strip.empty? && !ENV["SKIP_FONT_CHECK"]
    raise "Font `#{ font }' is not available; to skip this check, set SKIP_FONT_CHECK=1"
  end
end

MAME_128 = %w[
  Ruby Rust Scala Scheme Scilab sed Shakespeare S-Lang Squirrel Subleq
  SurgeScript Swift Tcl tcsh Thue TypeScript Unlambda Vala Velato Verilog
  Vimscript Whitespace XSLT Yabasic Yorick Zoem zsh Ada AFNIX Aheui
  Ante AspectJ Asymptote ATS Awk bash bc BeanShell Befunge BLC8
  Brainfuck C C++ C# Chef Clojure CMake Cobol CoffeeScript Crystal
  D dc Dhall Elixir Erlang Execline F# FALSE Fennel Flex
  Fish Forth FORTRAN77 Fortran90 GAP GDB Gnuplot Go GolfScript G-Portugol
  Grass Groovy Gzip Haskell Haxe Icon INTERCAL Jasmin Java JavaScript
  Jq JSFuck Kotlin ksh LiveScript LOLCODE Lua M4 Makefile MiniZinc
  Modula-2 MSIL Mustache NASM Neko Nickle Nim Objective-C OCaml Octave
  Ook! PARI/GP Pascal PHP Piet Pike PostScript Prolog Python R
  Ratfor rc REXX
] + [
  "Standard ML", "Visual Basic", "WebAssembly (Binary format)", "WebAssembly (Text format)",
  "ALGOL 68", "Common Lisp", "Emacs Lisp", "Gambas script", "GEL (Genius)",
  "Lazy K", "LLVM asm", "Parser 3", "Perl 5", "Perl 6", "Promela (Spin)"
]

Radius = 210.0 * RunSteps.size / 128.0
W = H = (2 * (Radius + 245)).to_i
surface = Cairo::ImageSurface.new(W, H)
ctx = Cairo::Context.new(surface)

ctx.line_width = 1
ctx.set_source_rgb(1, 1, 1)
ctx.rectangle(0, 0, W, H)
ctx.fill
ctx.set_source_rgb(0, 0, 0)

ctx.translate(W / 2, H / 2)
ctx.select_font_face("Raleway")
ctx.antialias = Cairo::Antialias::GRAY

BaseFontSize = 13
SubFontSize = 10

RunSteps.each_with_index do |s, i|
  ctx.save do
    angle = i / (RunSteps.size / 4.0)
    dir = 1 < angle && angle <= 3 ? 1 : -1
    ctx.rotate(Math::PI / 2 * (dir < 0 ? -angle : 2 - angle))
    s.name =~ /^(.*?)(\(.*\))?$/
    name, sub_name = $1, $2 || ""
    ctx.font_size = BaseFontSize; e1 = ctx.text_extents(name)
    ctx.font_size = SubFontSize ; e2 = ctx.text_extents(sub_name)
    ctx.move_to(dir * (Radius + 10) - (dir < 0 ? e1.x_advance + e2.x_advance : 0), 4.5)
    ctx.set_source_rgb(*(MAME_128.include?(s.name) ? [0, 0, 0] : [0.80, 0.16, 0.12]))
    ctx.font_size = BaseFontSize; ctx.show_text(name)
    ctx.font_size = SubFontSize ; ctx.show_text(sub_name)
  end
end

ArrowCount = RunSteps.size >= 240 ? 11 : 7
ArrowCount.times do |i|
  ctx.save do
    ctx.rotate(Math::PI * (2 * i) / ArrowCount - Math::PI + 0.06)

    ctx.line_width = 2
    ctx.line_cap = Cairo::LineCap::SQUARE
    ctx.new_path
    ctx.arc(0, 0, Radius, 0.0, Math::PI * 2 / ArrowCount - 0.06)
    ctx.stroke

    ctx.line_width = 1
    ctx.move_to(Radius    , -8)
    ctx.line_to(Radius - 6,  2)
    ctx.line_to(Radius + 6,  2)
    ctx.fill
  end
end

ctx.set_source_rgb(0, 0, 0)
Uroboros = 350.0 * Radius / 210.0
ctx.select_font_face("UnifrakturCook")
ctx.font_size = (25 * Radius / 210.0 * 0.82).round
Title = "#{ RunSteps.size }-Language Uroboros Quine"
e = ctx.text_extents(Title)
height = Uroboros / 2 + e.height + 28
ctx.move_to(-e.width / 2, height / 2)
ctx.show_text(Title)
ctx.save do
  svg = RSVG::Handle.new_from_file("uroboros.svg")
  ctx.translate(-Uroboros / 2, -height / 2)
  ctx.scale(Uroboros / svg.width, Uroboros / svg.width)
  ctx.render_rsvg_handle(svg)
end

surface.write_to_png("../langs.png")
unless ENV["NO_PNG_OPT"]
  system 'optipng -fix -i0 -o7 -strip all ../langs.png'
end
