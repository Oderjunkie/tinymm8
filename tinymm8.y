%require "3.2"
%language "c++"
%skeleton "lalr1.cc"
%define api.token.constructor
%define api.token.prefix {token}
%define api.parser.class {parser}
%define api.value.type variant
%token IDENT NUMBER
%token LPAREN "(" RPAREN ")" LBRACK "{" RBRACK "}"
%token SEMI ";" STATIC "static" RETURN "return"
%token COMMA "," RAISE "**" TIMES "*" OVER "/" PLUS "+" MINUS "-"
%token ASSGN "=" EQ "==" NEQ "!=" GT ">" GTE ">=" LT "<" LTE "<="
%left COMMA
%right RAISE
%left TIMES OVER
%left PLUS MINUS
%type<std::string> IDENT
%type<int> NUMBER

/* %type<expression> expr_no_comma expr */
%code top {
// extern int yylex();
// virtual int yyFlexLexer::yylex();
// #define yylex yyFlexLexer::yylex()
}

%code requires {
#include <string>
#include <vector>
using std::string;
using std::vector;
#include "tinymm8.hh"
// #include "parser.hh"
// template <typename T> void YY_DO_BEFORE_ACTION(T...) { return; }
// template <typename T> void YY_NEW_FILE(T...) { return; }
// int yyerror();
// int yywrap();
/* typedef union expression {
	string strv;
	int intv;
	vector<expression> arrv;
} expression */
}
%%

program: expr ";" {
	std::cout << "PROG PARSEd" << std::endl;
}

expr_no_comma: expr_no_comma "+" expr_no_comma
|              expr_no_comma "-" expr_no_comma
|              expr_no_comma "*" expr_no_comma
|              expr_no_comma "/" expr_no_comma
|              expr_no_comma "**" expr_no_comma { /*$$ = 1*/ }
|              "(" expr ")"                     { /*$$ = $2;*/ }
|              IDENT                            { /*$$ = $1;*/ std::cout << "IDENTIFIER DETECTED: " << $1 << std::endl; }
|              NUMBER                           { /*$$ = $1;*/ }
;

expr: expr_no_comma
|     expr "," expr
;

%%

void yy::parser::error(const std::string& err) {
	std::cerr << err << std::endl;
}

int main(int argc, char** argv) {
	yy::parser parse;
	return parse();
}

// #include "lexer.hh"
// #include <FlexLexer.h>
