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
%token SEMI ";" KW_NONINLINE "noninline" KW_RETURN "return" KW_IF "if" KW_ELSE "else"
%token COMMA "," RAISE "**" TIMES "*" OVER "/" PLUS "+" MINUS "-" FOVER "//" 
%token ASSGN "=" EQ "==" NEQ "!=" GT ">" GTE ">=" LT "<" LTE "<=" MOD "%"
%token BAND "&" BOR "|" BXOR "^" LAND "&&" LOR "||" LNOT "!" BNOT "~"
%token TERN_IF "?" TERN_ELSE ":" INC "++" DEC "--" KW_AS "as"
%left "(" POSTINC POSTDEC
%right "!" "~" DEREF ADDROF UNPLUS UNMINUS "++" "--"
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
%nonassoc "as"
%left ","
%type<int> NUMBER
%type<std::string> IDENT
%nterm<ast::typed_ident> type_and_ident
%nterm<std::vector<ast::typed_ident>> args_req args
%nterm<ast::Expression> expr_no_comma expr_with_semicolon expr stmt stmt_open stmt_closed stmt_other if_stmt_open if_stmt_closed
%nterm<ast::blck_stmt> blck_stmt expr_args_req expr_args stmt_list
%nterm<ast::FuncDecl> funcdecl decl
%nterm<std::vector<ast::FuncDecl>> library done

%code requires {
#include <utility>
#include <optional>
#include <string>
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

%start done;

%%

done[res]: library[val] YYEOF {
	@res = @val;
	$res = $val;
	std::for_each($res.begin(), $res.end(), [](FuncDecl& fndecl){
		fndecl.dump();
		emitter::emit(fndecl);
	});
};

library[res]: library[self] decl[el] { $res = $self; $res.push_back($el); @res = @self + @el; }
|             %empty                 { $res = {};                                             }
;

decl[res]: funcdecl[fn] { $res = $fn; @res = @fn; }
// | vardecl
;

funcdecl[res]: type_and_ident[ident] "(" args ")" stmt {
	@res = @ident + @stmt;
	$res = ast::FuncDecl($ident, $args, $stmt, @res);
}
;

if_stmt_open[res]: "if"[lhs] "(" expr[condition] ")" stmt[iftrue]                                  { @res = @lhs + @iftrue;  $res = Expression(ternop{ &$condition, &$iftrue, new Expression(), op::TERN }, @res); }
|                  "if"[lhs] "(" expr[condition] ")" stmt_closed[iftrue] "else" stmt_open[iffalse] { @res = @lhs + @iffalse; $res = Expression(ternop{ &$condition, &$iftrue, &$iffalse,        op::TERN }, @res); }
;

if_stmt_closed[res]: "if"[lhs] "(" expr[condition] ")" stmt_closed[iftrue] "else" stmt_closed[iffalse] { @res = @lhs + @iffalse; $res = Expression(ternop{&$condition, &$iftrue, &$iffalse,        op::TERN }, @res);  }

/* while_stmt[res] */

type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair($type, $name); @res = @type + @name; }
/*|                                IDENT[name] { $res = std::pair(std::nullopt, $name); }*/
;

expr[res]: expr_no_comma[val]                            { @res = @val; $res = $val; }
|          expr[lhs] ","  expr[rhs]                      {
	@res = @lhs + @rhs;
	$res = Expression( binop{&$lhs, &$rhs, op::COMMA}, @res );
}
;

expr_no_comma[res]: expr_no_comma[lhs] "+"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::PLUS    }, @res); }
|                                      "+"[opr] expr_no_comma[val]                    { @res = @opr + @val; $res = Expression(  unop{&$val,               op::UNPLUS  }, @res); } %prec UNPLUS
|                                      "++"[opr] expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::PREINC  }, @res); }
|                   expr_no_comma[val] "++"[opr]                                      { @res = @val + @opr; $res = Expression(  unop{&$val,               op::POSTINC }, @res); } %prec POSTINC
|                   expr_no_comma[lhs] "-"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::MINUS   }, @res); }
|                                      "-"[opr]  expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::UNMINUS }, @res); } %prec UNMINUS
|                                      "--"[opr] expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::PREDEC  }, @res); }
|                   expr_no_comma[val] "--"[opr]                                      { @res = @val + @opr; $res = Expression(  unop{&$val,               op::POSTDEC }, @res); } %prec POSTDEC
|                   expr_no_comma[lhs] "*"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::TIMES   }, @res); }
|                   expr_no_comma[lhs] "/"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::OVER    }, @res); }
|                   expr_no_comma[lhs] "%"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::MOD     }, @res); }
|                   expr_no_comma[lhs] "="  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::ASSGN   }, @res); }
|                   expr_no_comma[lhs] "==" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::EQ      }, @res); }
|                   expr_no_comma[lhs] "!=" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::NEQ     }, @res); }
|                   expr_no_comma[lhs] "<"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::LT      }, @res); }
|                   expr_no_comma[lhs] "<=" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::LTE     }, @res); }
|                   expr_no_comma[lhs] ">"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::GT      }, @res); }
|                   expr_no_comma[lhs] ">=" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::GTE     }, @res); }
|                   expr_no_comma[lhs] "&"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::BAND    }, @res); }
|                   expr_no_comma[lhs] "|"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::BOR     }, @res); }
|                   expr_no_comma[lhs] "^"  expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::BXOR    }, @res); }
|                                      "~"[opr]  expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::BNOT    }, @res); }
|                   expr_no_comma[lhs] "&&" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::LAND    }, @res); }
|                   expr_no_comma[lhs] "||" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::LOR     }, @res); }
|                                      "!"[opr]  expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::LNOT    }, @res); }
|                                      "*"[opr]  expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::DEREF   }, @res); } %prec DEREF
|                                      "&"[opr]  expr_no_comma[val]                   { @res = @opr + @val; $res = Expression(  unop{&$val,               op::ADROF   }, @res); } %prec ADDROF
|                   expr_no_comma[lhs] "?"  expr_no_comma[mhs] ":" expr_no_comma[rhs] { @res = @lhs + @rhs; $res = Expression(ternop{&$lhs, &$mhs, &$rhs, op::TERN    }, @res); }
|                   expr_no_comma[fnn] "(" expr_args[fna] ")"[opr]                    { @res = @fnn + @opr; $res = Expression( binop{&$fnn,
															      new Expression($fna, @fna), op::CALL    }, @res); }
|                   expr_no_comma[lhs] "as" expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = Expression( binop{&$lhs,        &$rhs, op::AS      }, @res); }
|                   "("[lhs] expr[val] ")"[rhs]                                       { @res = @lhs + @rhs; $res = $val;                                                        }
/*|                   blck_stmt[val]                                                    { $res = $val;                                }*/
|                   IDENT[id]                                                         { @res = @id;  $res = Expression($id, @res);                                              }
|                   NUMBER[num]                                                       { @res = @num; $res = Expression($num, @res);                                             }
;

expr_args_req[res]: expr_args_req[self] "," expr_no_comma[el] { @res = @self + @el; $res = $self; $res.push_back(new Expression($el));  }
|                   expr_no_comma[el]                         { @res =         @el; $res = {};    $res.push_back(new Expression($el));  }
;

expr_args[res]: expr_args_req[self] { $res = $self; @res = @self; }
|               %empty              { $res = {};    }
;

expr_with_semicolon[res]: expr[val] ";" { $res = $val; @res = @val; };

stmt[res]: stmt_open[val]   { $res = $val; @res = @val; }
|          stmt_closed[val] { $res = $val; @res = @val; }

stmt_open[res]: if_stmt_open[val] { $res = $val; @res = @val; };

stmt_closed[res]: if_stmt_closed[val] { $res = $val; @res = @val; }
|                 stmt_other[val]    { $res = $val; @res = @val; }
;

stmt_other[res]: expr_with_semicolon[val]            { @res = @val;        $res = $val;                                      } 
|                blck_stmt[val]                      { @res = @val;        $res = Expression($val, @res);                    }
|                "return"[lhs] expr[retval] ";"[rhs] { @res = @lhs + @rhs; $res = Expression(new Expression($retval), @res); }
|                "return"[lhs] ";"[rhs]              { @res = @lhs + @rhs; $res = Expression(new Expression(),        @res); }
;

stmt_list[res]: stmt_list[self] stmt[inst] { $res = $self; $res.push_back(new Expression($inst)); @res = @self + @inst; }
|               %empty                     { $res = {};                                                                 }
;

blck_stmt[res]: "{"[lhs] stmt_list[blck] "}"[rhs] { $res = $blck; }

args_req[res]: args_req[self] "," type_and_ident[el] { $res = $self; $res.push_back($el); @res = @self + @el; }
|              type_and_ident[el]                    { $res = {};    $res.push_back($el); @res = @el;         }
;

args[res]: args_req[val] { $res = $val; @res = @val; }
|          %empty        { $res = {};                }
;

%%

void yy::parser::error(const location_type& loc, const std::string& err) {
	std::cerr << loc << std::endl << err << std::endl;
}
