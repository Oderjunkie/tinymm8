%option c++ noyywrap nounput noinput batch debug 
%{
#include "parser.hh"
%}
%%
 /* [ui](8|16|32|64)[\*&]* return TYPE; */
[\f\t\r\n]+
"("                    return yy::parser::token::token_kind_type::tokenLPAREN;
")"                    return yy::parser::token::token_kind_type::tokenRPAREN;
"{"                    return yy::parser::token::token_kind_type::tokenLBRACK;
"}"                    return yy::parser::token::token_kind_type::tokenRBRACK;
";"                    return yy::parser::token::token_kind_type::tokenSEMI;
"static"               return yy::parser::token::token_kind_type::tokenSTATIC;
","                    return yy::parser::token::token_kind_type::tokenCOMMA;
"return"               return yy::parser::token::token_kind_type::tokenRETURN;
"+"                    return yy::parser::token::token_kind_type::tokenPLUS;
"-"                    return yy::parser::token::token_kind_type::tokenMINUS;
"*"                    return yy::parser::token::token_kind_type::tokenTIMES;
"/"                    return yy::parser::token::token_kind_type::tokenOVER;
"**"                   return yy::parser::token::token_kind_type::tokenRAISE;
[0-9]+                 return yy::parser::token::token_kind_type::tokenNUMBER;
[a-zA-Z_][a-zA-Z0-9_]* return yy::parser::token::token_kind_type::tokenIDENT;
%%
