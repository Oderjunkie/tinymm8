LEXFLAGS ?=
YACCFLAGS ?=
GCCFLAGS ?=
GCCFLAGS += -std=c++20

all : reset parser lexer compiler

lexer : parser tinymm8.l
	flex $(LEXFLAGS) -o lexer.cc *.l

parser : tinymm8.y
	bison $(YACCFLAGS) -o parser.cc -d *.y

compiler : tinymm8.cc tinymm8.hh ast.cc ast.hh
	g++ $(GCCFLAGS) -o compiler lexer.cc parser.cc tinymm8.cc ast.cc

reset :
	rm -f lexer.?? parser.?? compiler location.hh
