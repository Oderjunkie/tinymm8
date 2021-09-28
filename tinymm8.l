%option noyywrap nounput noinput batch 
%{

#include "tinymm8.hh"
#include "parser.hh"
#include <string>

%}
%%
 /* [ui](8|16|32|64)[\*&]* return TYPE; */
[\f\t\r\n]+
"("                    return yy::parser::make_LPAREN();
")"                    return yy::parser::make_RPAREN();
"{"                    return yy::parser::make_LBRACK();
"}"                    return yy::parser::make_RBRACK();
";"                    return yy::parser::make_SEMI();
"static"               return yy::parser::make_STATIC();
","                    return yy::parser::make_COMMA();
"return"               return yy::parser::make_RETURN();
"+"                    return yy::parser::make_PLUS();
"-"                    return yy::parser::make_MINUS();
"*"                    return yy::parser::make_TIMES();
"/"                    return yy::parser::make_OVER();
"**"                   return yy::parser::make_RAISE();
[0-9]+                 return yy::parser::make_NUMBER(1);
[a-zA-Z_][a-zA-Z0-9_]* return yy::parser::make_IDENT("thing");
%%
