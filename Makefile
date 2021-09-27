all : reset compiler

lexer : *.l
	flex --header-file=lexer.hh -o lexer.cc *.l

parser : *.y
	bison -o parser.cc -d *.y

compiler : lexer parser
	g++ -std=c++14 lexer.cc parser.cc -o compiler

reset :
	rm -f lexer.cc parser.cc compiler
