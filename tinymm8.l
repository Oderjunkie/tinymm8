%option c++
%option noyywrap
%{
#include "parser.hh"
%}
%%
 /* [ui](8|16|32|64)[\*&]* return TYPE; */
[\f\t\r\n]+
"("                    return LPAREN;
")"                    return RPAREN;
"{"                    return LBRACK;
"}"                    return RBRACK;
";"                    return SEMI;
"static"               return STATIC;
","                    return COMMA;
"return"               return RETURN;
"+"                    return PLUS;
"-"                    return MINUS;
"*"                    return TIMES;
"/"                    return OVER;
"**"                   return RAISE;
[0-9]+                 yylval = atoi(yytext); return NUMBER;
[a-zA-Z_][a-zA-Z0-9_]* yylval = strdup(yytext); return IDENT;
%%
