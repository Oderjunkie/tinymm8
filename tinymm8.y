%require "3.2"
%language "c++"
%skeleton "lalr1.cc"
%define api.token.constructor
%define api.value.type variant
%token IDENT NUMBER
%token LPAREN "(" RPAREN ")" LBRACK "{" RBRACK "}"
%token SEMI ";" STATIC "static" RETURN "return"
%token COMMA "," RAISE "**" TIMES "*" OVER "/" PLUS "+" MINUS "-"
%left COMMA
%right RAISE
%left TIMES OVER
%left PLUS MINUS
%type<strv> IDENT
%type<intv> NUMBER
%type<arrv> expr_no_comma expr
%{
#include "lexer.hh"
int yyerror();
int yywrap();
typedef union expression {
    typedef struct {
        union expression;
    } expression
}
%}
%%

program: expr ";" {
	std::cout << "PROG PARSEd" << std::endl;
}

expr_no_comma: expr_no_comma "+" expr_no_comma
|              expr_no_comma "-" expr_no_comma
|              expr_no_comma "*" expr_no_comma
|              expr_no_comma "/" expr_no_comma
|              expr_no_comma "**" expr_no_comma { $$ = 1 }
|              "(" expr ")"                     { $$ = $2; }
|              IDENT                            { $$ = $1; }
|              NUMBER                           { $$ = $1; }
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
