#include "ast.hh"
#include <iostream>
#include <stdexcept>

using namespace ast; // Fight me =P
using yy::location;

bool is_unop_pre(op const& opr) {
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
        case op::AS: throw std::invalid_argument("Received binop instead of a unop.");
        }
        return false;
}

std::string op_to_str(op const& opr) {
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
        case op::AS: return "as";
        default: throw std::invalid_argument("Received binop instead of a unop.");
        }
        return "This message should not appear. What should i do if it does...?";
}

TernOp::TernOp() {}
TernOp::TernOp(location loc) : loc(loc) {}
TernOp::TernOp(Node* lhs, Node* mhs, Node* rhs, location loc) : lhs(lhs), mhs(mhs), rhs(rhs), loc(loc) {
        if (this->lhs == nullptr || this->mhs == nullptr || this->rhs == nullptr) throw std::invalid_argument("Null pointer given to ast::TernOp.");
}
void TernOp::dump() const {
        this->lhs->dump();
        std::cout << "?";
        this->mhs->dump();
        std::cout << ":";
        this->rhs->dump();
}
irast::Stmt* TernOp::parse() const { return new irast::IfStmt(this->lhs->parse(), this->mhs->parse(), this->rhs->parse()); }

BinOp::BinOp() {}
BinOp::BinOp(location loc) : loc(loc) {}
BinOp::BinOp(Node* lhs, op opr, Node* rhs, location loc) : lhs(lhs), opr(opr), rhs(rhs), loc(loc) {
        if (this->lhs == nullptr || this->rhs == nullptr) throw std::invalid_argument("Null pointer given to ast::BinOp.");
}
void BinOp::dump() const {
        this->lhs->dump();
        std::cout << " " << op_to_str(this->opr) << " ";
        this->rhs->dump();
}
irast::Stmt* BinOp::parse() const { return new irast::Null(); }

UnOp::UnOp() {}
UnOp::UnOp(location loc) : loc(loc) {}
UnOp::UnOp(Node* val, op opr, location loc) : val(val), opr(opr), loc(loc) {
        if (this->val == nullptr) throw std::invalid_argument("Null pointer given to ast::UnOp.");
}
void UnOp::dump() const {
        auto ispre = is_unop_pre(this->opr);
        if (ispre) std::cout << op_to_str(this->opr);
        this->val->dump();
        if (!ispre) std::cout << op_to_str(this->opr);
}
irast::Stmt* UnOp::parse() const { return new irast::Null(); }

Block::Block() {}
Block::Block(location loc) : loc(loc) {}
Block::Block(blck_stmt body, location loc) : body(body), loc(loc) {
        for (auto const& stmt : this->body)
                if (stmt == nullptr) throw std::invalid_argument("Null pointer given to ast::Block.");
}
void Block::dump() const {
        std::cout << "{";
        for (auto const& stmt : this->body) stmt->dump();
        std::cout << "}";
}
irast::Stmt* Block::parse() const {
        std::vector<irast::Stmt*> newbody;
        std::transform(this->body.cbegin(), this->body.cend(), newbody.begin(), [](Node* const& stmt) { return stmt->parse(); });
        return new irast::BlockStmt(newbody);
}

Ident::Ident() {}
Ident::Ident(location loc) : loc(loc) {}
Ident::Ident(std::string ident, location loc) : ident(ident), loc(loc) {}
void Ident::dump() const { std::cout << this->ident; }
irast::Stmt* Ident::parse() const { return new irast::Ident(this->ident); }

Number::Number() {}
Number::Number(location loc) : loc(loc) {}
Number::Number(int num, location loc) : num(num), loc(loc) {}
void Number::dump() const { std::cout << this->num; }
irast::Stmt* Number::parse() const { return new irast::Integer(this->num); }

Return::Return() {}
Return::Return(location loc) : loc(loc) {}
Return::Return(Node* retval, location loc) : retval(retval), loc(loc) {}
void Return::dump() const { std::cout << "return " << this->retval << ";"; }
irast::Stmt* Return::parse() const { return new irast::ReturnStmt(this->retval->parse()); }

Null::Null() {}
Null::Null(location loc) : loc(loc) {}
void Null::dump() const { std::cout << "null"; }
irast::Stmt* Null::parse() const { return new irast::Null(); }

FnDecl::FnDecl() {}
FnDecl::FnDecl(location loc) : loc(loc) {}
FnDecl::FnDecl(typed_ident const& fnid, std::vector<typed_ident> const& args, Node* const& body, location loc) : fnid(fnid), args(args), body(body), loc(loc) {
        if (this->body == nullptr) throw std::invalid_argument("Null pointer given to ast::FnDecl.");
}
FnDecl::FnDecl(FnDecl const& fndecl) { *this = fndecl; }
FnDecl::~FnDecl()       = default;
FnDecl& FnDecl::operator=(FnDecl const& fndecl) {
        this->fnid = fndecl.fnid;
        this->args = fndecl.args;
        this->body = fndecl.body;
        return *this;
}
void FnDecl::dump() const {
        auto const& [fntype, fnname] = this->fnid;
        std::cout << "\e[35m" << fntype << "\e[m \e[1;32m" << fnname << "\e[m(";
        for (auto const& arg : this->args) {
                auto const& [atype, aname] = arg;
                std::cout << "\e[35m" << atype << "\e[m \e[1;32m" << aname << "\e[m, ";
        }
        std::cout << ") ";
        this->body->dump();
        std::cout << "\n";
}
irast::Stmt* FnDecl::parse() const { return new irast::Func(this->fnid, this->args, this->body->parse()); }
