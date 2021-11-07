#pragma once
// #include "ast.hh"
#include <map>
#include <optional>
#include <string>
#include <unordered_map>
#include <variant>
#include <vector>

namespace irast {
        // symbol: [type, count]
        using Symbol = std::tuple<std::string, int>;
        // frame: [framename, name -> symbol]
        using Frame = std::tuple<std::string, std::unordered_map<std::string, Symbol>>;
        // call stack: vector<frame>
        using CallStack = std::vector<Frame>;
        extern CallStack call_stack;
        enum class Operator { PLUS, MINUS, TIMES, OVER, BAND, BOR, BXOR, LAND, LOR, MOD, LSHIFT, RSHIFT, LNOT, UMINUS, DEREF, ADDROF, AS, EQ, NEQ, GT, GTE, LT, LTE };
        enum class ConditionOperator { LT, GT, LTE, GTE, NEQ, EQ };
        class Stmt {
              public:
                virtual std::pair<std::string, std::string> emit() const = 0;
                virtual std::string dump() const                         = 0;
                virtual std::string type() const                         = 0;
        };
        class Ident : public Stmt {
              protected:
                int tempvar;
                void allocatecount();
                std::string type_save;

              public:
                std::string name;
                Ident();
                Ident(Ident const& ident);
                Ident(std::string name);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Integer : public Stmt {
              public:
                int val;
                Integer();
                Integer(Integer const& ident);
                Integer(int val);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Null : public Stmt {
              public:
                Null();
                Null(Null const& null);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Arithmetic : public Stmt {
              protected:
                int tempvar;
                void allocatecount();

              public:
                Stmt* lhs;
                Operator op;
                std::optional<Stmt*> rhs;
                Arithmetic();
                Arithmetic(Arithmetic const& arth);
                Arithmetic(Stmt* lhs, Operator op);
                Arithmetic(Stmt* lhs, Operator op, Stmt* rhs);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Condition : public Stmt {
              protected:
                int tempvar;

              public:
                Stmt* lhs;
                Operator op;
                Stmt* rhs;
                Condition();
                Condition(Condition const& cond);
                Condition(Stmt* lhs, Operator op, Stmt* rhs);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Func : public Stmt {
              public:
                std::pair<std::string, std::string> fnsig;
                std::vector<std::pair<std::string, std::string>> args;
                Stmt* body;
                Func();
                Func(Func const& func);
                Func(std::pair<std::string, std::string> fnsig, std::vector<std::pair<std::string, std::string>> args, Stmt* body);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class ReturnStmt : public Stmt {
              public:
                std::optional<Stmt*> retval;
                ReturnStmt();
                ReturnStmt(ReturnStmt const& retstmt);
                ReturnStmt(Stmt* retval);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class IfStmt : public Stmt {
              protected:
                int tempifso;
                int tempifnot;
                int tempend;
                int tempvar;

              public:
                Stmt* cond;
                Stmt* ifso;
                Stmt* ifnot;
                IfStmt();
                IfStmt(IfStmt const& ifstmt);
                IfStmt(Stmt* cond, Stmt* ifso, Stmt* ifnot);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class BlockStmt : public Stmt {
              public:
                std::vector<Stmt*> body;
                BlockStmt();
                BlockStmt(BlockStmt const& blckstmt);
                BlockStmt(std::vector<Stmt*> body);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class FnCall : public Stmt {
              protected:
                int tempvar;

              public:
                Stmt* name;
                std::vector<Stmt*> args;
                FnCall();
                FnCall(FnCall const& fncall);
                FnCall(Stmt* name, std::vector<Stmt*> args);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        class Comment : public Stmt {
              public:
                std::string content;
                Comment();
                Comment(Comment const& comment);
                Comment(std::string content);
                std::pair<std::string, std::string> emit() const;
                std::string dump() const;
                std::string type() const;
        };
        // Stmt* parsefn(ast::FuncDecl const& fndecl);
        // std::optional<Stmt*> parseexpr(ast::Expression const& expr);
} // namespace irast
