%option noyywrap nounput noinput batch debug
%{

#include "tinymm8.hh"
#include "parser.hh"
#include <string>
#include <cstdlib>

%}
%%
%{

yy::location& loc = drv.loc;
loc.step();

%}

\n+                    loc.lines(yyleng); loc.step();
[ \f\t]                loc.step();
"//".*                 loc.lines(1); loc.step();
"("                    return yy::parser::make_LPAREN(loc);
")"                    return yy::parser::make_RPAREN(loc);
"{"                    return yy::parser::make_LBRACK(loc);
"}"                    return yy::parser::make_RBRACK(loc);
";"                    return yy::parser::make_SEMI(loc);
"noninline"            return yy::parser::make_KW_NONINLINE(loc);
"if"                   return yy::parser::make_KW_IF(loc);
"else"                 return yy::parser::make_KW_ELSE(loc);
","                    return yy::parser::make_COMMA(loc);
"return"               return yy::parser::make_KW_RETURN(loc);
"+"                    return yy::parser::make_PLUS(loc);
"++"                   return yy::parser::make_INC(loc);
"-"                    return yy::parser::make_MINUS(loc);
"--"                   return yy::parser::make_DEC(loc);
"*"                    return yy::parser::make_TIMES(loc);
"/"                    return yy::parser::make_OVER(loc);
"%"                    return yy::parser::make_MOD(loc);
"="                    return yy::parser::make_ASSGN(loc);
"=="                   return yy::parser::make_EQ(loc);
"!="                   return yy::parser::make_NEQ(loc);
">"                    return yy::parser::make_GT(loc);
">="                   return yy::parser::make_GTE(loc);
"<"                    return yy::parser::make_LT(loc);
"<="                   return yy::parser::make_LTE(loc);
"&"                    return yy::parser::make_BAND(loc);
"|"                    return yy::parser::make_BOR(loc);
"^"                    return yy::parser::make_BXOR(loc);
"~"                    return yy::parser::make_BNOT(loc);
"&&"                   return yy::parser::make_LAND(loc);
"||"                   return yy::parser::make_LOR(loc);
"!"                    return yy::parser::make_LNOT(loc);
"?"                    return yy::parser::make_TERN_IF(loc);
":"                    return yy::parser::make_TERN_ELSE(loc);
"as"                   return yy::parser::make_KW_AS(loc);
0x[0-9A-Fa-f]*         {
        return yy::parser::make_NUMBER(strtoull(&yytext[2], nullptr, 16), loc);
}
[1-9][0-9]*            {
        return yy::parser::make_NUMBER(strtoull(yytext, nullptr, 10), loc);
}
0[0-7]*                {
        return yy::parser::make_NUMBER(strtoull(&yytext[1], nullptr, 8), loc);
}
[a-zA-Z_][a-zA-Z0-9_]* {
	return yy::parser::make_IDENT(yytext, loc);
}
.                      throw  yy::parser::syntax_error(loc, "lex-time error: invalid character: \"" + std::string(yytext) + "\"");
<<EOF>>                return yy::parser::make_YYEOF(loc);
%%

void driver::driver::scan_begin() {
	yy_flex_debug = trace_scanning;
	if (file.empty() || file == "-")
		yyin = stdin;
	else if (!(yyin = fopen (file.c_str (), "r"))) {
		std::cerr << "tinymm8: " << file << ": " << strerror(errno) << std::endl;
		exit(EXIT_FAILURE);
	}
}

void driver::driver::scan_end() {
  fclose(yyin);
}
