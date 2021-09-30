%require "3.7.6"
%locations
%language "c++"
%define api.value.type variant
%define api.token.prefix {token}
%define api.parser.class {parser}
%define api.token.constructor
%define api.value.automove
%define api.token.raw
%define parse.trace
%define parse.error detailed
%define parse.lac full
%param { driver::driver& drv }
%token IDENT NUMBER
%token LPAREN "(" RPAREN ")" LBRACK "{" RBRACK "}"
%token SEMI ";" KW_NONINLINE "noninline" KW_RETURN "return" KW_IF "if"
%token COMMA "," RAISE "**" TIMES "*" OVER "/" PLUS "+" MINUS "-" FOVER "//" 
%token ASSGN "=" EQ "==" NEQ "!=" GT ">" GTE ">=" LT "<" LTE "<=" MOD "%"
%token BAND "&" BOR "|" BXOR "^" LAND "&&" LOR "||" LNOT "!" BNOT "~"
%right "!" "~"
%left "*" "/" "%"
%left "+" "-"
%left "<" "<=" ">" ">="
%left "==" "!="
%left "&"
%left "^"
%left "|"
%left "&&"
%left "||"
%right "="
%left ","
%type<int> NUMBER
%type<std::string> IDENT
%nterm<typed_ident> type_and_ident

/* %type<expression> expr_no_comma expr */
%code top {
// extern int yylex();
// virtual int yyFlexLexer::yylex();
// #define yylex yyFlexLexer::yylex()
// #include "tinymm8.hh"
// int yylex();
// #include "any.hh"
}

%code requires {
#include <utility>
#include <optional>
#include <string>
typedef std::pair<std::optional<std::string>, std::string> typed_ident;
using std::string;
namespace driver {
    class driver;
}
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

%code {
#include "tinymm8.hh"
}

%start library;

%%

library: library decl {}
|        %empty       {}
;

decl: funcdecl {}
// | vardecl
;

funcdecl: IDENT "(" args ")" expr {}
type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair($type,        $name); }
|                                IDENT[name] { $res = std::pair(std::nullopt, $name); }
;

;

expr: "return" expr ";" {}
|     IDENT             {}
|     NUMBER            {}
|     %empty            {}
;

args_req: args_req "," arg {}
|         arg              {}
;

args: args_req {}
|     %empty   {}
;

arg: type IDENT {}
;



%%

void yy::parser::error(const location_type& loc, const std::string& err) {
	std::cerr << loc << std::endl << err << std::endl;
}
