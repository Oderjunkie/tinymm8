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
%token TERN_IF "?" TERN_ELSE ":" INC "++" DEC "--"
%left "("
%right "!" "~" DEREF ADDROF
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
%nterm<std::vector<typed_ident>> args_req args
%nterm<ast::Expression> expr_no_comma expr stmt ifstmt
%nterm<ast::blck_stmt> blockstmt expr_args_req expr_args

%code requires {
#include <utility>
#include <optional>
#include <string>
typedef std::pair<std::optional<std::string>, std::string> typed_ident;
#include "ast.hh"
using std::string;
namespace driver {
    class driver;
}
}

%code {
#include "tinymm8.hh"
using namespace ast;
}

%start library;

%%

library: library decl {  }
|        %empty       {  }
;

decl: funcdecl {}
// | vardecl
;

funcdecl: type_and_ident[ident] "(" args ")" stmt {
        auto const& [rettype, name] = $ident;
	std::cout << "FUNCTION DEFINITION" << std::endl <<
	          "return type: " << rettype.value_or("[void]") << std::endl <<
	          "name: " << name << std::endl << "body: ";
	$stmt.dump();
	std::cout << std::endl;
}
;

ifstmt[res]: "if" "(" expr[condition] ")" stmt[iftrue] { $res = Expression(ternop{&$condition, &$iftrue, new Expression(), op::TERN }); }

type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair($type,        $name); }
|                                IDENT[name] { $res = std::pair(std::nullopt, $name); }
;

expr[res]: expr_no_comma[val]                            { $res = $val; }
|          expr[lhs] ","  expr[rhs]                      { $res = Expression( binop{&$lhs, &$rhs, op::COMMA }); }
;

expr_no_comma[res]: expr_no_comma[lhs] "+"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::PLUS  }); }
|                   expr_no_comma[lhs] "-"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::MINUS }); }
|                   expr_no_comma[lhs] "*"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::TIMES }); }
|                   expr_no_comma[lhs] "/"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::OVER  }); }
|                   expr_no_comma[lhs] "%"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::MOD   }); }
|                   expr_no_comma[lhs] "="  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::ASSGN }); }
|                   expr_no_comma[lhs] "==" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::EQ    }); }
|                   expr_no_comma[lhs] "!=" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::NEQ   }); }
|                   expr_no_comma[lhs] "<"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::LT    }); }
|                   expr_no_comma[lhs] "<=" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::LTE   }); }
|                   expr_no_comma[lhs] ">"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::GT    }); }
|                   expr_no_comma[lhs] ">=" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::GTE   }); }
|                   expr_no_comma[lhs] "&"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::BAND  }); }
|                   expr_no_comma[lhs] "|"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::BOR   }); }
|                   expr_no_comma[lhs] "^"  expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::BXOR  }); }
|                                      "~"  expr_no_comma[val]                        { $res = Expression(  unop{&$val,               op::BNOT  }); }
|                   expr_no_comma[lhs] "&&" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::LAND  }); }
|                   expr_no_comma[lhs] "||" expr_no_comma[rhs]                        { $res = Expression( binop{&$lhs,        &$rhs, op::LOR   }); }
|                                      "!"  expr_no_comma[val]                        { $res = Expression(  unop{&$val,               op::LNOT  }); }
|                                      "*"  expr_no_comma[val]                        { $res = Expression(  unop{&$val,               op::DEREF }); } %prec DEREF
|                                      "&"  expr_no_comma[val]                        { $res = Expression(  unop{&$val,               op::ADROF }); } %prec ADDROF
|                   expr_no_comma[lhs] "?"  expr_no_comma[mhs] ":" expr_no_comma[rhs] { $res = Expression(ternop{&$lhs, &$mhs, &$rhs, op::TERN  }); }
|                   expr_no_comma[fnn] "(" expr_args[fna] ")"                         { $res = Expression(binop{&$fnn,
														new Expression($fna), op::CALL });  }
|                   "(" expr[val] ")"                                                 { $res = $val;                                                }
|                   IDENT[id]                                                         { $res = Expression($id);                                     }
|                   NUMBER[num]                                                       { $res = Expression($num);                                    }
|                   blockstmt[blck] "}"                                               { $res = Expression($blck);                                   }
;

expr_args_req[res]: expr_args_req[self] "," expr_no_comma[el] { $res = $self; $res.push_back(new Expression($el)); }
|                   expr_no_comma[el]                         { $res = {};    $res.push_back(new Expression($el)); }
;

expr_args[res]: expr_args_req[self] { $res = $self; }
|               %empty              { $res = {};    }
;

stmt[res]: expr[val] ";"             { $res = $val;                                }
//|          blockstmt[blck] "}"       { $res = Expression($blck);                   }
|          ifstmt[val]               { $res = $val;                                }
|          "return" expr[retval] ";" { $res = Expression(new Expression($retval)); }
|          "return" ";"              { $res = Expression(new Expression());        }
;

blockstmt[res]: blockstmt[self] stmt[inst] { $res = $self; $res.push_back(new Expression($inst)); }
|               "{"                        { $res = {};                                           }
;

args_req[res]: args_req[self] "," type_and_ident[el] { $res = $self; $res.push_back($el); }
|              type_and_ident[el]                    { $res = {};    $res.push_back($el); }
;

args[res]: args_req[val] { $res = $val; }
|          %empty        { $res = {};   }
;

%%

void yy::parser::error(const location_type& loc, const std::string& err) {
	std::cerr << loc << std::endl << err << std::endl;
}
