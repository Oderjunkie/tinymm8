%require "3.7.6"
%locations
%language "c++"
%define api.value.type variant
%define api.token.prefix {token}
%define api.parser.class {parser}
%define api.token.constructor
/* %define api.value.automove */
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
%token TERN_IF "?" TERN_ELSE ":"
%left "("
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
%right "=" "?" ":"
%left ","
%type<int> NUMBER
%type<std::string> IDENT
%nterm<typed_ident> type_and_ident
%nterm<std::deque<typed_ident>> args_req args
%nterm<std::shared_ptr<ast::Expression>> expr expr_no_comma

%code requires {
#include <utility>
#include <optional>
#include <string>
#include <deque>
typedef std::pair<std::optional<std::string>, std::string> typed_ident;
#include "ast.hh"
using std::string;
namespace driver {
    class driver;
}
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

funcdecl: type_and_ident[ident] "(" args ")" stmt {
	auto const& [rettype, name] = std::move($ident);
	std::cout << "FUNCTION DEFINITION" << std::endl <<
	          "return type: " << rettype.value_or("[void]") << std::endl <<
	          "name: " << name << std::endl;
}
;

ifstat[res]: "if" "(" expr[cond] ")" stmt[iftrue] { /* */ }

type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair(std::move($type),        std::move($name)); }
|                                IDENT[name] { $res = std::pair(std::nullopt,            std::move($name)); }
;

expr[res]: expr_no_comma[val]                            { $res = $val; }
|          expr[lhs] ","  expr[rhs]                      { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::COMMA; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
;

expr_no_comma[res]: expr_no_comma[lhs] "+"  expr_no_comma[rhs]                               { $res = std::make_shared<ast::Expression>(ast::Expression({std::make_shared<ast::Expression>($lhs), std::make_shared<ast::Expression>($rhs), ast::op::PLUS})); }
|                   expr_no_comma[lhs] "-"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::MINUS; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "*"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::TIMES; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "/"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::OVER;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "%"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::MOD;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "="  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::ASSGN; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "==" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::EQ;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "!=" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::NEQ;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "<"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::GT;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "<=" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::GTE;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] ">"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::LT;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] ">=" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::LTE;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "&"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::BAND;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "|"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::BOR;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "^"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::BXOR;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                                      "~"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::BNOT;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "&&" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::LAND;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[lhs] "||" expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::LOR;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                                      "!"  expr_no_comma[rhs]                               { /*$res.exprtype = ast::type::BINOP; $res.binop.opr = ast::op::LNOT;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs;*/ }
|                   expr_no_comma[cond] "?" expr_no_comma[iftrue] ":" expr_no_comma[iffalse] { /*;*/ }
|                   "(" expr[val] ")"                                                        { /*$res = $val;*/ }
|                   expr_no_comma[fnname] "(" expr_args[fnargs] ")"                          {  }
|                   IDENT[id]                                                                { /*$res.exprtype = ast::type::IDENT; $res.ident = $id;*/  }
|                   NUMBER[num]                                                              { /*$res.exprtype = ast::type::NUM;   $res.num   = $num;*/ }
|                   blockstmt "}"                                                            {  }
;

expr_args_req[res]: expr_args_req[self] "," expr_no_comma[el] { /*$res = $self;*/ }
|                   expr_no_comma[el]                         {  } 
;

expr_args[res]: expr_args_req[self] { /*$res = $self;*/ }
|               %empty              { /*$res = {};*/ }
;

stmt[res]: expr[val] ";"             { /*$res.stattype = ast::type::EMPTY;*/ }
|          ifstat[val]               { /*$res = $val;*/ }
|          "return" expr[retval] ";" { /*$res.stattype = ast::type::EMPTY;*/ }
|          "return" ";"              { /*$res.stattype = ast::type::EMPTY;*/ }
;

blockstmt[res]: blockstmt[self] stmt[inst] { /* $res = $self; $res.push_front($inst);*/ }
|               "{"                        { /* $res = {};                           */ }
;

args_req[res]: args_req[self] "," type_and_ident[el] { $res = $self; $res.push_front($el); }
|              type_and_ident[el]                    { $res = {};    $res.push_front($el); }
;

args[res]: args_req[val] { $res = $val; }
|          %empty        { $res = {};    }
;

%%

void yy::parser::error(const location_type& loc, const std::string& err) {
	std::cerr << loc << std::endl << err << std::endl;
}
