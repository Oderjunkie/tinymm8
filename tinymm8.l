%option noyywrap nounput noinput batch  debug
%{

#include "tinymm8.hh"
#include "parser.hh"
#include <string>

%}
%%
%{

yy::location& loc = drv.loc;
loc.step();

%}

\n+        
 /* [ui](8|16|32|64)[\*&]* return TYPE; */
[\f\t]                 loc.step();
\r\n | \n              loc.lines(yyleng); loc.ste();
"("                    return yy::parser::make_LPAREN(loc);
")"                    return yy::parser::make_RPAREN(loc);
"{"                    return yy::parser::make_LBRACK(loc);
"}"                    return yy::parser::make_RBRACK(loc);
";"                    return yy::parser::make_SEMI(loc);
"static"               return yy::parser::make_STATIC(loc);
","                    return yy::parser::make_COMMA(loc);
"return"               return yy::parser::make_RETURN(loc);
"+"                    return yy::parser::make_PLUS(loc);
"-"                    return yy::parser::make_MINUS(loc);
"*"                    return yy::parser::make_TIMES(loc);
"/"                    return yy::parser::make_OVER(loc);
"**"                   return yy::parser::make_RAISE(loc);
[0-9]+                 std::cout << "NUMBER" << std::endl; return yy::parser::make_NUMBER(1, loc); // std::stoi(std::string())
[a-zA-Z_][a-zA-Z0-9_]* std::cout << "IDENT" << std::endl; return yy::parser::make_IDENT(yytext, loc);
.                      throw  yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
<<EOF>>                return yy::parser::make_YYEOF(loc);
%%
