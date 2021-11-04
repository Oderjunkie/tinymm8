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
%nterm<ast::Node*> expr_no_comma expr_with_semicolon expr stmt stmt_open stmt_closed stmt_other
%nterm<ast::TernOp*> if_stmt_open if_stmt_closed
%nterm<ast::Block*> blck_stmt
%nterm<ast::blck_stmt> expr_args_req expr_args stmt_list
%nterm<ast::FnDecl> funcdecl decl
%nterm<std::vector<ast::FnDecl>> library done

%code requires {
#include <utility>
#include <optional>
#include <string>
#include <fstream>
#include "ast.hh"
#include "irast.hh"
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
	std::vector<irast::Stmt*> funcs; // absolute hack, TODO: get rid of this pointer
	for (FuncDecl& fndecl : $res) {
		funcs.push_back(irast::parsefn(fndecl));
	});
	std::ofstream output;
	if (driver::pipe_mode)
		output.open("a.out");
	for (auto const& stmt : funcs) {
		auto const& [code, name] = stmt->emit();
		if (driver::pipe_mode)
			std::cout << code << std::endl;
		else
			output << code << std::endl;
	};
	if (driver::pipe_mode)
		output.close();
};

library[res]: library[self] decl[el] { $res = $self; $res.push_back($el); @res = @self + @el; }
|             %empty                 { $res = {};                                             }
;

decl[res]: funcdecl[fn] { $res = $fn; @res = @fn; }
// | vardecl
;

funcdecl[res]: type_and_ident[ident] "(" args ")" stmt {
	@res = @ident + @stmt;
	$res = ast::FnDecl($ident, $args, $stmt, @res);
}
;

if_stmt_open[res]: "if"[lhs] "(" expr[condition] ")" stmt[iftrue]                                  { @res = @lhs + @iftrue;  $res = new TernOp($condition, $iftrue, new Null(), @res); }
|                  "if"[lhs] "(" expr[condition] ")" stmt_closed[iftrue] "else" stmt_open[iffalse] { @res = @lhs + @iffalse; $res = new TernOp($condition, $iftrue, $iffalse,  @res);  }
;

if_stmt_closed[res]: "if"[lhs] "(" expr[condition] ")" stmt_closed[iftrue] "else" stmt_closed[iffalse] { @res = @lhs + @iffalse; $res = new TernOp($condition, $iftrue, $iffalse, @res); }

/* while_stmt[res] */

type_and_ident[res]: IDENT[type] IDENT[name] { $res = std::pair($type, $name); @res = @type + @name; }
/*|                                IDENT[name] { $res = std::pair(std::nullopt, $name); }*/
;

expr[res]: expr_no_comma[val]                            { @res = @val;        $res = $val;                                   }
|          expr[lhs] ","  expr[rhs]                      { @res = @lhs + @rhs; $res = new BinOp($lhs, op::COMMA, $rhs, @res); }
;
 
expr_no_comma[res]: expr_no_comma[lhs] "+"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::PLUS,    $rhs, @res); }
|                                      "+"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::UNPLUS,        @res); } %prec UNPLUS
|                                      "++"[opr] expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::PREINC,        @res); }
|                   expr_no_comma[val] "++"[opr]                                           { @res = @val + @opr; $res = new   UnOp($val, op::POSTINC,       @res); } %prec POSTINC
|                   expr_no_comma[lhs] "-"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::MINUS,   $rhs, @res); }
|                                      "-"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::UNMINUS,       @res); } %prec UNMINUS
|                                      "--"[opr] expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::PREDEC,        @res); }
|                   expr_no_comma[val] "--"[opr]                                           { @res = @val + @opr; $res = new   UnOp($val, op::POSTDEC,       @res); } %prec POSTDEC
|                   expr_no_comma[lhs] "*"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::TIMES,   $rhs, @res); }
|                   expr_no_comma[lhs] "/"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::OVER,    $rhs, @res); }
|                   expr_no_comma[lhs] "%"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::MOD,     $rhs, @res); }
|                   expr_no_comma[lhs] "="       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::ASSGN,   $rhs, @res); }
|                   expr_no_comma[lhs] "=="      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::EQ,      $rhs, @res); }
|                   expr_no_comma[lhs] "!="      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::NEQ,     $rhs, @res); }
|                   expr_no_comma[lhs] "<"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::LT,      $rhs, @res); }
|                   expr_no_comma[lhs] "<="      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::LTE,     $rhs, @res); }
|                   expr_no_comma[lhs] ">"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::GT,      $rhs, @res); }
|                   expr_no_comma[lhs] ">="      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::GTE,     $rhs, @res); }
|                   expr_no_comma[lhs] "&"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::BAND,    $rhs, @res); }
|                   expr_no_comma[lhs] "|"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::BOR,     $rhs, @res); }
|                   expr_no_comma[lhs] "^"       expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::BXOR,    $rhs, @res); }
|                                      "~"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::BNOT,          @res); }
|                   expr_no_comma[lhs] "&&"      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::LAND,    $rhs, @res); }
|                   expr_no_comma[lhs] "||"      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::LOR,     $rhs, @res); }
|                                      "!"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::LNOT,          @res); }
|                                      "*"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::DEREF,         @res); } %prec DEREF
|                                      "&"[opr]  expr_no_comma[val]                        { @res = @opr + @val; $res = new   UnOp($val, op::ADROF,         @res); } %prec ADDROF
|                   expr_no_comma[lhs] "?"       expr_no_comma[mhs] ":" expr_no_comma[rhs] { @res = @lhs + @rhs; $res = new TernOp($lhs,    $mhs,    $rhs,  @res); }
/*|                   expr_no_comma[fnn] "("       expr_args[fna] ")"[opr]                   { @res = @fnn + @opr; $res = new  BinOp($fnn,    $fna,       op::CALL,    @res); }*/
|                   expr_no_comma[lhs] "as"      expr_no_comma[rhs]                        { @res = @lhs + @rhs; $res = new  BinOp($lhs, op::AS,     $rhs,  @res); }
|                   "("[lhs] expr[val] ")"[rhs]                                            { @res = @lhs + @rhs; $res = $val;                                      }
/*|                   blck_stmt[val]                                                         { $res = $val;                                                                }*/
|                   IDENT[id]                                                              { @res = @id;  $res = new Ident($id, @res);                             }
|                   NUMBER[num]                                                            { @res = @num; $res = new Number($num, @res);                           }
;

expr_args_req[res]: expr_args_req[self] "," expr_no_comma[el] { @res = @self + @el; $res = $self; $res.push_back($el); }
|                   expr_no_comma[el]                         { @res =         @el; $res = {};    $res.push_back($el); }
;

expr_args[res]: expr_args_req[self] { $res = $self; @res = @self; }
|               %empty              { $res = {};    }
;

expr_with_semicolon[res]: expr[val] ";" { $res = $val; @res = @val; };

stmt[res]: stmt_open[val]   { $res = $val; @res = @val; }
|          stmt_closed[val] { $res = $val; @res = @val; }

stmt_open[res]: if_stmt_open[val] { $res = $val; @res = @val; };

stmt_closed[res]: if_stmt_closed[val] { $res = $val; @res = @val; }
|                 stmt_other[val]     { $res = $val; @res = @val; }
;

stmt_other[res]: expr_with_semicolon[val]            { @res = @val;        $res = $val;                      } 
|                blck_stmt[val]                      { @res = @val;        $res = $val;                      }
|                "return"[lhs] expr[retval] ";"[rhs] { @res = @lhs + @rhs; $res = new Return($retval, @res); }
|                "return"[lhs] ";"[rhs]              { @res = @lhs + @rhs; $res = new Return(nullptr, @res); }
;

stmt_list[res]: stmt_list[self] stmt[inst] { @res = @self + @inst; $res = $self; $res.push_back($inst); }
|               %empty                     {                       $res = {};                           }
;

blck_stmt[res]: "{"[lhs] stmt_list[blck] "}"[rhs] { @res = @lhs + @rhs; $res = new Block($blck, @res); }

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
