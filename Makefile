LEXFLAGS ?=
YACCFLAGS ?=
GCCFLAGS ?= -std=c++20

all : reset compiler

lexer : parser *.l
	flex $(LEXFLAGS) -o lexer.cc *.l

parser : *.y
	bison $(YACCFLAGS) -o parser.cc -d *.y

compiler : parser lexer
	g++ $(GCCFLAGS) -o compiler lexer.cc parser.cc tinymm8.cc

reset :
	rm -f lexer.?? parser.?? compiler location.hh
