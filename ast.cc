#include "ast.hh"
#include <iostream>

using namespace ast; // Fight me =P



Expression::Expression()                         : type(exprtype::NONE)                  {               }
Expression::Expression(int const &num)           : type(exprtype::NUM),   num(num)       {               }
Expression::Expression(blck_stmt const &body)    : type(exprtype::BODY),  body(body)     {               }
Expression::Expression(std::string const &ident) : type(exprtype::IDENT), ident(ident)   {               }
Expression::Expression(ternop const &opr)        : type(exprtype::TERNOP), ternopr(opr)  {               }
Expression::Expression(binop const &opr)         : type(exprtype::BINOP), binopr(opr)    {               }
Expression::Expression(unop const &opr)          : type(exprtype::UNOP),  unopr(opr)     {               }
Expression::Expression(Expression const &expr)                                           { *this = expr; }
Expression::~Expression() = default;
Expression& Expression::operator= (Expression const &expr) {
	switch (this->type = expr.type) {
		case exprtype::NUM:   this->num    = expr.num;               break;
		case exprtype::BODY:  this->body   = expr.body;              break;
		case exprtype::IDENT:
		   this->ident  = expr.ident;
		   break;
		case exprtype::BINOP:
		  delete this->binopr.lhs;
		  delete this->binopr.rhs;
		  this->binopr.lhs = new Expression(std::move(*expr.binopr.lhs));
		  this->binopr.rhs = new Expression(std::move(*expr.binopr.rhs));
		  this->binopr.opr = expr.binopr.opr;
		  break;
		case exprtype::UNOP:
		  delete this->unopr.val;
		  this->unopr.val = new Expression(std::move(*expr.unopr.val));
		  this->unopr.opr = expr.unopr.opr;
		  // efficiency 100
		case exprtype::NONE:
	        default:
		  break;
	}
	return *this;
}

std::string op2str(op opr) {
  switch (opr) {
    case op::COMMA: return ",";
    case op::TIMES: return "*";
    case op::OVER:  return "/";
    case op::PLUS:  return "+";
    case op::MINUS: return "-";
    case op::FOVER: return "//";
    case op::ASSGN: return "=";
    case op::EQ:    return "==";
    case op::NEQ:   return "!=";
    case op::GT:    return ">";
    case op::GTE:   return ">=";
    case op::LT:    return "<";
    case op::LTE:   return "<=";
    case op::MOD:   return "%";
    case op::BAND:  return "&";
    case op::BOR:   return "|";
    case op::BXOR:  return "^";
    case op::LAND:  return "&&";
    case op::LOR:   return "||";
    case op::LNOT:  return "!";
    case op::BNOT:  return "~";
    case op::CALL:  return "()";
  }
  return "[invalid]";
}

/*void Expression::debug() {
	std::cout << "ths addr: \e[36m" << (void const*) this <<
	std::endl << "\e[mlhs addr: \e[36m" << (void const*) this->binopr.lhs <<
	std::endl << "\e[mrhs addr: \e[36m" << (void const*) this->binopr.rhs << "\e[m" <<
	std::endl;
}*/

void Expression::dump() {
	switch (this->type) {
		case exprtype::NUM:
			std::cout << this->num;
			return;
		case exprtype::BODY:
		        std::cout << "[body]";
			return;
		case exprtype::IDENT:
			std::cout << "<" << this->ident << ">";
			return;
		case exprtype::BINOP:
		        
		  /*if (this == this->binopr.lhs) {
			        std::cout << std::endl << "\e[31mERROR: EXPR->BINOPR.LHS == EXPR\e[m" <<
				std::endl << "ths addr: \e[36m" << (void const*) this <<
				std::endl << "\e[mlhs addr: \e[36m" << (void const*) this->binopr.rhs <<
				std::endl << "\e[mrhs addr: \e[36m" << (void const*) this->binopr.rhs << "\e[m" <<
				std::endl;
				exit(1);
				}*/
			//this->binopr.lhs->dump();
			this->binopr.lhs->dump();
			std::cout << " " << op2str(this->binopr.opr) << " ";
			this->binopr.rhs->dump();
			return;
		        //std::cout << "[binop]";
			//return;
		case exprtype::UNOP:
			//std::cout << this->unopr.opr;
			//this->unopr.val->dump();
		        std::cout << "[unop]";
			return;
		case exprtype::NONE:
			std::cout << "[null]";
			return;
		default:
			std::cout << "[unknown]";
			return;
	}
}
