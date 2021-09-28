%require "3.7.6"
%locations
%language "c++"
%define api.token.constructor
%define api.token.prefix {token}
%define api.parser.class {parser}
%define api.value.type variant
%define api.token.raw
%define parse.trace
%define parse.error detailed
%define parse.lac full
%param { driver::driver& drv }
%printer { yyo << $$; } <*>;
%token IDENT NUMBER
%token LPAREN "(" RPAREN ")" LBRACK "{" RBRACK "}"
%token SEMI ";" STATIC "static" RETURN "return"
%token COMMA "," RAISE "**" TIMES "*" OVER "/" PLUS "+" MINUS "-" FOVER "//" 
%token ASSGN "=" EQ "==" NEQ "!=" GT ">" GTE ">=" LT "<" LTE "<=" MOD "%"
%token BAND "&" BOR "|" BXOR "^" LAND "&&" LOR "||" LNOT "!" BNOT "~"
%right RAISE
%right LNOT BNOT
%left TIMES OVER MOD
%left PLUS MINUS
%left LT LTE GT GTE
%left EQ NEQ
%left BAND
%left BXOR
%left BOR
%left LAND
%left LOR
%right ASSGN
%left COMMA
%type<int> NUMBER
%type<char*> IDENT

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
#include <string>
#include <vector>
using std::string;
using std::vector;
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

library: library decl {/*std::cout << "library: library decl" << std::endl;*/}
|        %empty       {/*std::cout << "library: %""empty" << std::endl;*/}
;

decl: funcdecl {/*std::cout << "decl: funcdecl" << std::endl;*/}
// | vardecl
;

funcdecl: /*type*/ IDENT "(" args ")" expr {/*std::cout << "funcdecl: type IDENT \"(\" args \")\" expr" << std::endl;*/}
;

type: IDENT             {/*std::cout << "type: IDENT" << std::endl;*/}
|     %empty            {/*std::cout << "type: %""empty" << std::endl;*/}
;

expr: "return" expr ";" {/*std::cout << "expr: \"return\" expr \";\"" << std::endl;*/}
|     IDENT             {/*std::cout << "expr: IDENT" << std::endl;*/}
|     NUMBER            {/*std::cout << "expr: NUMBER" << std::endl;*/}
|     %empty            {/*std::cout << "expr: %""empty" << std::endl;*/}
;

args_req: args_req "," arg {/*std::cout << "args_req: args_req \",\" arg" << std::endl;*/}
|         arg              {/*std::cout << "args_req: arg" << std::endl;*/}
;

args: args_req {/*std::cout << "args: args_req" << std::endl;*/}
|     %empty   {/*std::cout << "args: %""empty" << std::endl;*/}
;

arg: type IDENT {/*std::cout << "arg: type IDENT" << std::endl;*/}
;

// program: expr ";" {}

// expr_no_comma: expr_no_comma "+" expr_no_comma
// |              expr_no_comma "-" expr_no_comma
// |              expr_no_comma "*" expr_no_comma
// |              expr_no_comma "/" expr_no_comma
// |              expr_no_comma "**" expr_no_comma
// |              "(" expr ")"                     { $$ = $2; }
// |              IDENT                            { $$ = $1; }
// |              NUMBER                           { $$ = $1; }
// ;

// expr: expr_no_comma          { $$ = $1; }
// |     expr "," expr_no_comma
// ;

%%

/*namespace yy {
    parser::symbol_type yylex();
}*/

void yy::parser::error(const location_type& loc, const std::string& err) {
	std::cerr << loc << std::endl << err << std::endl;
}

// #include "lexer.hh"
// #include <FlexLexer.h>
