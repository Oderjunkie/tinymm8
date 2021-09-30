#include "ast.hh"
#include <iostream>
#include <stdexcept>

using namespace ast; // Fight me =P

Expression::Expression() : type(exprtype::NONE) {}
Expression::Expression(int const& num) : type(exprtype::NUM), num(num) {}
Expression::Expression(blck_stmt const& body) :
    type(exprtype::BODY), body(body) {}
Expression::Expression(std::string const& ident) :
    type(exprtype::IDENT), ident(ident) {}
Expression::Expression(ternop const& opr) :
    type(exprtype::TERNOP), ternopr(opr) {}
Expression::Expression(binop const& opr) : type(exprtype::BINOP), binopr(opr) {}
Expression::Expression(unop const& opr) : type(exprtype::UNOP), unopr(opr) {}
Expression::Expression(Expression const* expr) : type(exprtype::RETURN) {
        ret = new Expression(*expr);
}
Expression::Expression(Expression const& expr) { *this = expr; }
Expression::~Expression() = default;

Expression& Expression::operator=(Expression const& expr) {
        switch (this->type = expr.type) {
        case exprtype::NUM: this->num = expr.num; break;
        case exprtype::BODY:
                this->body = expr.body;
                std::for_each(
                    this->body.begin(), this->body.end(),
                    [](Node& expr) { expr = Expression(expr); });
                this->body = blck_stmt(this->body);
                break;
        case exprtype::IDENT: this->ident = expr.ident; break;
        case exprtype::RETURN: this->ret = expr.ret; break;
        case exprtype::TERNOP:
                delete this->ternopr.lhs;
                delete this->ternopr.mhs;
                delete this->ternopr.rhs;
                this->ternopr.lhs =
                    new Expression(std::move(*expr.ternopr.lhs));
                this->ternopr.mhs =
                    new Expression(std::move(*expr.ternopr.mhs));
                this->ternopr.rhs =
                    new Expression(std::move(*expr.ternopr.rhs));
                this->ternopr.opr = expr.ternopr.opr;
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
        default: break;
        }
        return *this;
}

bool isunoppre(op opr) {
        switch (opr) {
        case op::LNOT:
        case op::BNOT:
        case op::DEREF:
        case op::ADROF:
        case op::UNPLUS:
        case op::UNMINUS:
        case op::PREINC:
        case op::PREDEC: return true;
        case op::POSTINC:
        case op::POSTDEC: return false;
        case op::COMMA:
        case op::TIMES:
        case op::OVER:
        case op::PLUS:
        case op::MINUS:
        case op::ASSGN:
        case op::EQ:
        case op::NEQ:
        case op::GT:
        case op::GTE:
        case op::LT:
        case op::LTE:
        case op::MOD:
        case op::BAND:
        case op::BOR:
        case op::BXOR:
        case op::LAND:
        case op::LOR:
        case op::CALL:
        case op::TERN:
                throw std::invalid_argument(
                    "Received binop instead of a unop.");
        }
        return false;
}

std::string op2str(op opr) {
        switch (opr) {
        case op::COMMA: return ",";
        case op::TIMES: // efficiency 200
        case op::DEREF: return "*";
        case op::OVER: return "/";
        case op::PLUS: // efficiency 300
        case op::UNPLUS: return "+";
        case op::POSTINC: // efficiency 400
        case op::PREINC: return "++";
        case op::POSTDEC: // efficiency 500
        case op::PREDEC: return "--";
        case op::MINUS: // efficiency 600
        case op::UNMINUS: return "-";
        case op::ASSGN: return "=";
        case op::EQ: return "==";
        case op::NEQ: return "!=";
        case op::GT: return ">";
        case op::GTE: return ">=";
        case op::LT: return "<";
        case op::LTE: return "<=";
        case op::MOD: return "%";
        case op::BAND: // efficiency 700
        case op::ADROF: return "&";
        case op::BOR: return "|";
        case op::BXOR: return "^";
        case op::LAND: return "&&";
        case op::LOR: return "||";
        case op::LNOT: return "!";
        case op::BNOT: return "~";
        case op::CALL: return "()";
        }
        return "[invalid]";
}

void Expression::dump() {
        if (this == (Expression*)0) {
                std::cout << "\e[1;31m[uhhh crap]\e[m";
                return;
        }
        switch (this->type) {
        case exprtype::NUM:
                std::cout << "\e[1;36m" << this->num << "\e[m";
                return;
        case exprtype::BODY:
                std::cout << "{ ";
                std::for_each(this->body.begin(), this->body.end(),
                              [](Expression& expr) {
                                      expr.dump();
                                      std::cout << "; ";
                              });
                std::cout << "}";
                return;
        case exprtype::IDENT:
                std::cout << "\e[1;32m" << this->ident << "\e[m";
                return;
        case exprtype::BINOP:
                this->binopr.lhs->dump();
                if (this->binopr.opr == op::CALL) {
                        std::cout << "(";
                        std::for_each(this->binopr.rhs->body.begin(),
                                      this->binopr.rhs->body.end(),
                                      [](Expression& expr) {
                                              expr.dump();
                                              std::cout << ", ";
                                      });
                        std::cout << ")";
                } else {
                        std::cout << " " << op2str(this->binopr.opr) << " ";
                        this->binopr.rhs->dump();
                }
                return;
        case exprtype::TERNOP:
                this->ternopr.lhs->dump();
                std::cout << " ? ";
                this->ternopr.mhs->dump();
                std::cout << " : ";
                this->ternopr.rhs->dump();
                return;
        case exprtype::UNOP:
                if (isunoppre(this->unopr.opr)) {
                        std::cout << op2str(this->unopr.opr);
                        this->unopr.val->dump();
                } else {
                        this->unopr.val->dump();
                        std::cout << op2str(this->unopr.opr);
                }
                return;
        case exprtype::RETURN:
                std::cout << "return ";
                this->ret->dump();
                return;
        case exprtype::NONE: std::cout << "\e[1;30mnull\e[m"; return;
        default: std::cout << "\e[31m[unknown]\e[m"; return;
        }
}

FuncDecl::FuncDecl() {}
FuncDecl::FuncDecl(typed_ident const& fnid,
                   std::vector<typed_ident> const& args,
                   Expression const& body) :
    fnid(fnid),
    args(args), body(body) {}
FuncDecl::FuncDecl(FuncDecl const& fndecl) { *this = fndecl; }
FuncDecl::~FuncDecl()       = default;
FuncDecl& FuncDecl::operator=(FuncDecl const& fndecl) {
        this->fnid = fndecl.fnid;
        this->args = fndecl.args;
        this->body = fndecl.body;
        return *this;
}
void FuncDecl::dump() {
        auto const& [fntype, fnname] = this->fnid;
        if (fntype.has_value())
                std::cout << "\e[35m" << fntype.value() << "\e[m ";
        std::cout << "\e[1;32m" << fnname << "\e[m(";
        std::for_each(this->args.begin(), this->args.end(),
                      [](typed_ident& arg) {
                              auto const& [atype, aname] = arg;
                              std::cout << "\e[35m" << atype.value()
                                        << "\e[m \e[1;32m" << aname << "\e[m, ";
                      });
        std::cout << ") ";
        this->body.dump();
        std::cout << "\n";
}
