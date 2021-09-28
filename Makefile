all : reset compiler

lexer : *.l
	flex -o lexer.cc *.l

parser : *.y
	bison -o parser.cc -d *.y

compiler : parser lexer
	g++ -std=c++20 lexer.cc parser.cc tinymm8.cc -o compiler

reset :
	rm -f lexer.?? parser.?? compiler
