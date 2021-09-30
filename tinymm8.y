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
%nterm<std::deque<typed_ident>> args_req args
%nterm<ast::expression> expr expr1 blockstat
%nterm<ast::statement> stat stat1

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

funcdecl: type_and_ident[ident] "(" args ")" stat {
	auto const& [rettype, name] = $ident;
	std::cout << "FUNCTION DEFINITION" << std::endl <<
	          "return type: " << rettype.value_or("[void]") << std::endl <<
	          "name: " << name << std::endl;
}
;

/* ifstat: "if" "(" expr1[cond] ")" expr1[iftrue] */

type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair($type,        $name); }
|                                IDENT[name] { $res = std::pair(std::nullopt, $name); }
;

expr1[res]: expr[lhs] "+"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::PLUS;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "-"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::MINUS; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "*"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::TIMES; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "/"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::OVER;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "%"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::MOD;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "="  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::ASSGN; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "==" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::EQ;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "!=" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::NEQ;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "<"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::GT;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "<=" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::GTE;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] ">"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::LT;    $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] ">=" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::LTE;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "&"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::BAND;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "|"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::BOR;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "^"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::BXOR;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "~"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::BNOT;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "&&" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::LAND;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "||" expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::LOR;   $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] "!"  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::LNOT;  $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           expr[lhs] ","  expr[rhs] { $res.exprtype = ast::type::BINOP; $res.binop.op = ast::op::COMMA; $res.binop.lhs = $lhs; $res.binop.rhs = $rhs; }
|           "(" expr[val] ")"        { $res = $val; }
|           IDENT[id]                { $res.exprtype = ast::type::IDENT; $res.ident = $id;  }
|           NUMBER[num]              { $res.exprtype = ast::type::NUM;   $res.num   = $num; }
;

expr[res]: expr1[val]    {  }
|          blockstat "}" {  }

stat1[res]: expr1[val] ";"            { $res.stattype = ast::type::EMPTY; }
|           "return" expr[retval] ";" { $res.stattype = ast::type::EMPTY; }
|           "return" ";"              { $res.stattype = ast::type::EMPTY; }
;

stat[res]: stat1[val] { $res = $val; }
;

blockstat[res]: blockstat[self] stat[inst] { $res = $self; $res.push_front($inst); }
|               "{"                        { $res = {};                            }
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
