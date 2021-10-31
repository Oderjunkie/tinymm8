#include "irast.hh"
#include <algorithm>
#include <iostream>
#include <optional>
#include <signal.h>
#include <sstream>
#include <stdexcept>

#define BREAKPOINT raise(SIGINT)

/*
 * Some info about my naming convention:
 * Local Variables are represented as @NAME%COUNT, where COUNT is an
 * incrementing value.
 * Temporary Variables are represented as just %COUNT.
 */

using namespace irast; // Fight me... again. =P
using std::optional;
using std::pair;
using std::string;
using std::variant;
using std::vector;
CallStack irast::call_stack;

string infertype(string lhs, string rhs) {
        if (lhs == rhs) return lhs;
        throw std::invalid_argument("Type " + lhs + " and type " + rhs + " are not identical.");
        return "This message should not appear, so if it does, tell me right away.";
};

string op2str(Operator op) {
        switch (op) {
        case Operator::PLUS: return "+";
        case Operator::MINUS: return "-";
        case Operator::TIMES: return "*";
        case Operator::OVER: return "/";
        case Operator::BAND: return "&";
        case Operator::BOR: return "|";
        case Operator::BXOR: return "^";
        case Operator::LAND: return "&&";
        case Operator::LOR: return "||";
        case Operator::MOD: return "mod";
        case Operator::LSHIFT: return "<<";
        case Operator::RSHIFT: return ">>";
        case Operator::LNOT: return "!";
        case Operator::UMINUS: return "-";
        case Operator::DEREF: return "*";
        case Operator::ADDROF: return "&";
        case Operator::EQ: return "==";
        case Operator::NEQ: return "!=";
        case Operator::GT: return ">";
        case Operator::GTE: return ">=";
        case Operator::LT: return "<";
        case Operator::LTE: return "<=";
        default: throw std::invalid_argument("Invalid operator passed to op2str");
        }
        return "This message should not appear, I'll be scared if it does.";
}

string op2dump(Operator op) {
        switch (op) {
        case Operator::PLUS: return "Operator::PLUS";
        case Operator::MINUS: return "Operator::MINUS";
        case Operator::TIMES: return "Operator::TIMES";
        case Operator::OVER: return "Operator::OVER";
        case Operator::BAND: return "Operator::BAND";
        case Operator::BOR: return "Operator::BOR";
        case Operator::BXOR: return "Operator::BXOR";
        case Operator::LAND: return "Operator::LAND";
        case Operator::LOR: return "Operator::LOR";
        case Operator::MOD: return "Operator::MOD";
        case Operator::LSHIFT: return "Operator::LSHIFT";
        case Operator::RSHIFT: return "Operator::RSHIFT";
        case Operator::LNOT: return "Operator::LNOT";
        case Operator::UMINUS: return "Operator::UMINUS";
        case Operator::DEREF: return "Operator::DEREF";
        case Operator::ADDROF: return "Operator::ADDROF";
        default: throw std::invalid_argument("Invalid operator passed to op2dump");
        }
        return "This message should not appear, if it does, it's a bug.";
}

string op2dump(ast::op op) {
        switch (op) {
        case ast::op::COMMA: return "ast::op::COMMA";
        case ast::op::TIMES: return "ast::op::TIMES";
        case ast::op::OVER: return "ast::op::OVER";
        case ast::op::PLUS: return "ast::op::PLUS";
        case ast::op::MINUS: return "ast::op::MINUS";
        case ast::op::ASSGN: return "ast::op::ASSGN";
        case ast::op::EQ: return "ast::op::EQ";
        case ast::op::NEQ: return "ast::op::NEQ";
        case ast::op::GT: return "ast::op::GT";
        case ast::op::GTE: return "ast::op::GTE";
        case ast::op::LT: return "ast::op::LT";
        case ast::op::LTE: return "ast::op::LTE";
        case ast::op::MOD: return "ast::op::MOD";
        case ast::op::BAND: return "ast::op::BAND";
        case ast::op::BOR: return "ast::op::BOR";
        case ast::op::BXOR: return "ast::op::BXOR";
        case ast::op::LAND: return "ast::op::LAND";
        case ast::op::LOR: return "ast::op::LOR";
        case ast::op::LNOT: return "ast::op::LNOT";
        case ast::op::BNOT: return "ast::op::BNOT";
        case ast::op::CALL: return "ast::op::CALL";
        case ast::op::TERN: return "ast::op::TERN";
        case ast::op::DEREF: return "ast::op::DEREF";
        case ast::op::ADROF: return "ast::op::ADROF";
        case ast::op::UNPLUS: return "ast::op::UNPLUS";
        case ast::op::UNMINUS: return "ast::op::UNMINUS";
        case ast::op::PREINC: return "ast::op::PREINC";
        case ast::op::PREDEC: return "ast::op::PREDEC";
        case ast::op::POSTINC: return "ast::op::POSTINC";
        case ast::op::POSTDEC: return "ast::op::POSTDEC";
        case ast::op::AS: return "ast::op::AS";
        }
        return "This message should not appear. What should i do if it does...?";
}

bool iscondop(ast::op opr) {
        switch (opr) {
        case ast::op::EQ:
        case ast::op::NEQ:
        case ast::op::GT:
        case ast::op::GTE:
        case ast::op::LT:
        case ast::op::LTE: return true;
        default: return false;
        }
        return false;
}

Operator astop2irop(ast::op opr) {
        switch (opr) {
        case ast::op::LNOT: return Operator::LNOT;
        case ast::op::DEREF: return Operator::DEREF;
        case ast::op::ADROF: return Operator::ADDROF;
        // case ast::op::UNPLUS: return Operator::UNPLUS;
        case ast::op::UNMINUS:
                return Operator::UMINUS;
                // case ast::op::PREINC: return Operator::PREINC;
                // case ast::op::PREDEC: return Operator::PREDEC:
                // case ast::op::POSTINC: return Operator::POSTINC;
                // case ast::op::POSTDEC: return Operator::POSTDEC:
                // case ast::op::COMMA: return Operator::COMMA;
        case ast::op::TIMES: return Operator::TIMES;
        case ast::op::OVER: return Operator::OVER;
        case ast::op::PLUS: return Operator::PLUS;
        case ast::op::MINUS: return Operator::MINUS;
        // case ast::op::ASSGN: return Operator::ASSGN;
        case ast::op::EQ: return Operator::EQ;
        case ast::op::NEQ: return Operator::NEQ;
        case ast::op::GT: return Operator::GT;
        case ast::op::GTE: return Operator::GTE;
        case ast::op::LT: return Operator::LT;
        case ast::op::LTE: return Operator::LTE;
        case ast::op::MOD: return Operator::MOD;
        case ast::op::BAND: return Operator::BAND;
        case ast::op::BOR: return Operator::BOR;
        case ast::op::BXOR: return Operator::BXOR;
        case ast::op::LAND: return Operator::LAND;
        case ast::op::LOR: return Operator::LOR;
        // case ast::op::CALL: return Operator::CALL;
        // case ast::op::TERN: return Operator::TERN;
        // case ast::op::AS: return Operator::AS;
        default: throw std::invalid_argument("Can't convert to IR operator. " + op2dump(opr));
        }
        return Operator::PLUS;
}

Arithmetic::Arithmetic() {}
Arithmetic::Arithmetic(Arithmetic const& arth) { *this = arth; }
Arithmetic::Arithmetic(Stmt* lhs, Operator op) : lhs(lhs), op(op) { this->allocatecount(); }
Arithmetic::Arithmetic(Stmt* lhs, Operator op, Stmt* rhs) : lhs(lhs), op(op), rhs(rhs) { this->allocatecount(); }

void Arithmetic::allocatecount() {
        try {
                auto& [name, frame] = call_stack.back();
                auto& [type, count] = frame.at(name);
                this->tempvar       = count++;
        } catch (std::out_of_range const& ex) { BREAKPOINT; }
}

pair<string, string> Arithmetic::emit() const {
        std::stringstream output;
        auto const& [preplhs, namelhs] = this->lhs->emit();
        output << preplhs;
        if (this->rhs) {
                auto const& [preprhs, namerhs] = this->rhs.value()->emit();
                output << preprhs;
        }
        auto varname = "%" + std::to_string(this->tempvar);
        output << this->type() << " " << varname;
        output << " = ";
        if (this->rhs) {
                auto const& [preprhs, namerhs] = this->rhs.value()->emit();
                output << namelhs << " " << op2str(this->op) << " " << namerhs;
        } else {
                output << op2str(this->op) << namelhs;
        }
        output << ";" << std::endl;
        return std::make_pair(output.str(), varname);
}

string Arithmetic::dump() const {
        std::stringstream output;
        if (this->rhs) {
                output << "Arithmetic(" << this->lhs->dump() << ", " << op2dump(this->op) << ", " << this->rhs.value()->dump() << "\e[1;30m, " << this->tempvar
                       << "\e[m)";
        } else {
                output << "Arithmetic(" << this->lhs->dump() << ", " << op2dump(this->op) << "\e[1;30m, " << this->tempvar << "\e[m)";
        }
        return output.str();
}

string Arithmetic::type() const {
        if (this->rhs) return infertype(this->lhs->type(), this->rhs.value()->type());
        return this->lhs->type();
}

Func::Func() {}
Func::Func(Func const& func) { *this = func; }
Func::Func(pair<string, string> fnsig, vector<pair<string, string>> args, Stmt* body) : fnsig(fnsig), args(args), body(body) {}

// std::string replaceAll(std::string& src, std::string);

pair<string, string> Func::emit() const {
        std::stringstream output;
        std::stringstream output_args;
        auto const& [fnname, fntype] = this->fnsig;
        output << "\e[35m" << fntype << "\e[m \e[1;32m" << fnname << "\e[m(";
        for (auto const& arg : this->args) {
                auto const& [argname, argtype] = arg;
                output_args << "\e[35m" << argtype << "\e[m @\e[1;32m" << argname << "\e[m%0, ";
        };
        auto output_string_args        = output_args.str();
        auto output_string_args_length = output_string_args.size();
        if (output_string_args_length) output_string_args.erase(output_string_args_length - 2);
        output << output_string_args << ") {" << std::endl;
        this->body->emit();
        output << "}" << std::endl;
        return std::make_pair(output.str(), fnname);
}

string Func::dump() const {
        std::stringstream output;
        auto const& [fnname, fntype] = this->fnsig;
        output << "Func({" << fnname << ", " << fntype << "}, [";
        for (auto const& arg : this->args) {
                auto const& [argname, argtype] = arg;
                output << "{\"" << argname << "\", \"" << argtype << "\"},";
        };
        output << "], [";
        output << this->body->dump();
        return output.str();
}

string Func::type() const {
        auto const& [fnname, fntype] = this->fnsig;
        return fntype;
}

Ident::Ident() {}
Ident::Ident(Ident const& ident) { *this = ident; }
Ident::Ident(string name) : name(name) { this->allocatecount(); }
void Ident::allocatecount() {
        try {
                auto const& [name, frame] = call_stack.back();
                auto const& [type, count] = frame.at(this->name);
                this->tempvar             = count;
                this->type_save           = type;
        } catch (std::out_of_range const& ex) { BREAKPOINT; }
}
pair<string, string> Ident::emit() const {
        std::stringstream output;
        output << "\e[1;32m" << this->name << "\e[m@" << this->tempvar;
        return std::make_pair("", output.str());
}
string Ident::dump() const {
        std::stringstream output;
        output << "Ident(\e[1;32m" << this->name << "\e[m\e[1;30m, " << this->tempvar << "\e[m)";
        return output.str();
}
string Ident::type() const { return this->type_save; }

Comment::Comment() {}
Comment::Comment(Comment const& comment) { *this = comment; }
Comment::Comment(string content) : content(content) {}
pair<string, string> Comment::emit() const { return std::make_pair("// " + this->content, ""); }
string Comment::dump() const { return "Comment(\"" + this->content + "\")"; }
string Comment::type() const { return ""; }

ReturnStmt::ReturnStmt() {}
ReturnStmt::ReturnStmt(ReturnStmt const& retstmt) { *this = retstmt; }
ReturnStmt::ReturnStmt(Stmt* retval) : retval(retval) {}
pair<string, string> ReturnStmt::emit() const {
        std::stringstream output;
        if (this->retval) {
                auto const& [prep, name] = this->retval.value()->emit();
                output << prep << "return " << name << ";";
        } else {
                output << "return;";
        }
        output << std::endl;
        return std::make_pair(output.str(), "");
}
string ReturnStmt::dump() const {
        std::stringstream output;
        output << "ReturnStmt(";
        if (this->retval) output << this->retval.value()->dump();
        output << ")";
        return output.str();
}
string ReturnStmt::type() const {
        if (this->retval) return this->retval.value()->type();
        return "void";
}

IfStmt::IfStmt() {}
IfStmt::IfStmt(IfStmt const& ifstmt) { *this = ifstmt; }
IfStmt::IfStmt(Stmt* cond, Stmt* ifso, Stmt* ifnot) : cond(cond), ifso(ifso), ifnot(ifnot) {
        try {
                auto& [name, frame] = call_stack.back();
                auto& [type, count] = frame.at(name);
                this->tempifso      = count++;
                this->tempifnot     = count++;
                this->tempend       = count++;
                this->tempvar       = count++;
        } catch (std::out_of_range const& ex) { BREAKPOINT; }
}
pair<string, string> IfStmt::emit() const {
        std::stringstream output;
        auto const& [condprep, condname]   = this->cond->emit();
        auto const& [ifsoprep, ifsoname]   = this->ifso->emit();
        auto const& [ifnotprep, ifnotname] = this->ifnot->emit();
        output << condprep << "jmp " << condname << ", IFSO%" << this->tempifso << ";" << std::endl
               << "jmp IFNOT%" << this->tempifnot << ";" << std::endl
               << "IFSO%" << this->tempifso << ":" << std::endl
               << ifsoprep << "jmp END%" << this->tempend << ";" << std::endl
               << "IFNOT%" << this->tempifnot << ":" << std::endl
               << ifnotprep << "jmp END%" << this->tempend << ";" << std::endl
               << "END%" << this->tempend << ":"
               << "%" << this->tempvar << " = @PHI(IFSO%" << this->tempifso << ", " << ifsoname << ", IFNOT%" << this->tempifnot << ", " << ifnotname << ");"
               << std::endl;
        return std::make_pair(output.str(), "%" + this->tempvar);
}
string IfStmt::dump() const {
        std::stringstream output;
        output << "IfStmt(" << this->cond->dump() << ", " << this->ifso->dump() << ", " << this->ifnot->dump() << ")";
        return output.str();
}
string IfStmt::type() const { return infertype(this->ifso->type(), this->ifnot->type()); }

Integer::Integer() {}
Integer::Integer(Integer const& integer) { *this = integer; }
Integer::Integer(int val) : val(val) {}
pair<string, string> Integer::emit() const { return std::make_pair<string, string>("", std::to_string(val)); }
string Integer::dump() const {
        std::stringstream output;
        output << "Integer(" << val << ")";
        return output.str();
}
string Integer::type() const {
        if (val < -128) return "i16";
        if (val < 0) return "i8";
        if (val < 255) return "u8";
        return "u16";
}

Null::Null() {}
Null::Null(Null const& null) { *this = null; }
pair<string, string> Null::emit() const { return std::make_pair<string, string>("", ""); }
string Null::dump() const { return "Null()"; }
string Null::type() const { return "void"; }

Condition::Condition() {}
Condition::Condition(Condition const& cond) { *this = cond; }
Condition::Condition(Stmt* lhs, Operator op, Stmt* rhs) : lhs(lhs), op(op), rhs(rhs) {
        try {
                auto& [name, frame] = call_stack.back();
                auto& [type, count] = frame.at(name);
                this->tempvar       = count++;
        } catch (std::out_of_range const& ex) { BREAKPOINT; }
}
pair<string, string> Condition::emit() const {
        std::stringstream prep;
        string cond;
        auto const& [lhsprep, lhsname] = this->lhs->emit();
        auto const& [rhsprep, rhsname] = this->rhs->emit();
        prep << lhsprep << rhsprep << "%" << this->tempvar;
        auto name = prep.str();
        prep << " = " << lhsname << " - " << rhsname << ";" << std::endl;
        switch (this->op) {
        case Operator::EQ: cond = "==0";
        case Operator::NEQ: cond = "!=0";
        case Operator::GT: cond = ">0";
        case Operator::GTE: cond = ">=0";
        case Operator::LT: cond = "<0";
        case Operator::LTE: cond = "<=0";
        default: throw std::invalid_argument("Cannot make condition from non-conditional operator.");
        }
        return std::make_pair(prep.str(), cond);
}
string Condition::dump() const {
        std::stringstream output;
        output << "Condition(" << this->lhs->dump() << ", " << op2dump(this->op) << ", " << this->rhs->dump() << ")";
        return output.str();
}
string Condition::type() const { return "u8"; }

BlockStmt::BlockStmt() {}
BlockStmt::BlockStmt(BlockStmt const& blckstmt) { *this = blckstmt; }
BlockStmt::BlockStmt(vector<Stmt*> body) : body(body) {}
pair<string, string> BlockStmt::emit() const {
        std::stringstream output;
        for (auto const& stmt : this->body) {
                auto const& [prep, name] = stmt->emit();
                output << prep;
        };
        return std::make_pair(output.str(), "");
}
string BlockStmt::dump() const {
        std::stringstream output;
        output << "BlockStmt(";
        for (auto const& stmt : this->body) { output << stmt->dump() << ","; }
        output << ")";
        return output.str();
}
string BlockStmt::type() const { return "void"; }

optional<Stmt*> irast::parseexpr(ast::Expression const& expr) {
        switch (expr.type) {
        case ast::exprtype::BINOP:
                // if (expr.binopr.opr == ast::op::TERNOP)
                if (!iscondop(expr.binopr.opr)) try {
                                auto rhs = parseexpr(*expr.binopr.rhs);
                                if (rhs.has_value()) return new Arithmetic(parseexpr(*expr.binopr.lhs).value(), astop2irop(expr.binopr.opr), rhs.value());
                                return new Arithmetic(parseexpr(*expr.binopr.lhs).value(), astop2irop(expr.binopr.opr));
                        } catch (std::bad_optional_access const& ex) {}
                break;
        case ast::exprtype::TERNOP:
                try {
                        return new IfStmt(parseexpr(*expr.ternopr.lhs).value(), parseexpr(*expr.ternopr.mhs).value(), parseexpr(*expr.ternopr.rhs).value());
                } catch (std::bad_optional_access const& ex) { BREAKPOINT; }
                break;
        case ast::exprtype::IDENT: return new Ident(expr.ident);
        case ast::exprtype::NUM: return new Integer(expr.num);
        case ast::exprtype::RETURN:
                try {
                        if (expr.ret->type == ast::exprtype::NONE) return new ReturnStmt();
                        return new ReturnStmt(parseexpr(*expr.ret).value());
                } catch (std::bad_optional_access const& ex) {}
                break;
        case ast::exprtype::BODY:
                return [&expr]() {
                        call_stack.push_back({"<anonymus>", std::unordered_map<string, Symbol>()});
                        std::vector<Stmt*> outbody;
                        std::for_each(expr.body.begin(), expr.body.end(), [&outbody](ast::Expression* const& expr) {
                                try {
                                        auto result = parseexpr(*expr).value();
                                        outbody.push_back(result);
                                } catch (std::bad_optional_access const& ex) {}
                        });
                        return new BlockStmt(outbody);
                }();
        case ast::exprtype::NONE:
        default: return new Null();
        }
        return new Comment("This message should not appear, should it? Tell me if you see it.");
}

Stmt* irast::parsefn(ast::FuncDecl const& fndecl) {
        auto const& [fntype, fnname] = fndecl.fnid;
        std::unordered_map<string, Symbol> fnlocals;
        vector<pair<string, string>> argnames = {};
        std::for_each(fndecl.args.begin(), fndecl.args.end(), [&fnlocals, &argnames](ast::typed_ident arg) {
                auto [atype, aname] = arg;
                fnlocals.insert({aname, std::make_tuple(atype, 0)});
                argnames.push_back({aname, atype});
        });
        fnlocals.insert({fnname, std::make_tuple(fntype, 0)});
        call_stack.push_back({fnname, fnlocals});
        auto body = fndecl.body;
        if (fndecl.body.type != ast::exprtype::BODY) {
                ast::blck_stmt newbody = {};
                if (fndecl.body.type == ast::exprtype::RETURN)
                        // i don't know why
                        // i don't want to have to know why
                        // but the entire thing doesn't work unless i do this
                        // i don't get why this is required
                        // but for some reason the computer just feels like
                        // adding an extra return for no reason
                        newbody.push_back(new ast::Expression(*fndecl.body.ret));
                else
                        newbody.push_back(new ast::Expression(fndecl.body));
                body = ast::Expression(newbody, newbody.front()->loc + newbody.back()->loc);
        }
        vector<Stmt*> outbody;
        std::for_each(body.body.begin(), body.body.end(), [&outbody](ast::Expression* const& expr) {
                // expr->dump();
                // std::cout << std::endl;
                try {
                        auto result = parseexpr(*expr).value();
                        outbody.push_back(result);
                        // auto const& [prep, name] = result->emit();
                        // std::cout << prep << std::endl;
                } catch (std::bad_optional_access const& ex) {}
        });
        auto ret = new Func(std::make_pair(fnname, fntype), argnames, outbody);
        call_stack.pop_back();
        return ret;
}
