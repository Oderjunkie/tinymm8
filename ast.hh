#pragma once
#include <optional>
#include <string>
#include <utility>
#include <variant>
#include <vector>

namespace ast {
        enum class op {
                COMMA,
                TIMES,
                OVER,
                PLUS,
                MINUS,
                ASSGN,
                EQ,
                NEQ,
                GT,
                GTE,
                LT,
                LTE,
                MOD,
                BAND,
                BOR,
                BXOR,
                LAND,
                LOR,
                LNOT,
                BNOT,
                CALL,
                TERN,
                DEREF,
                ADROF,
                UNPLUS,
                UNMINUS,
                PREINC,
                PREDEC,
                POSTINC,
                POSTDEC
        };
        class Node {};
        class Expression;
        class VarDecl;
        struct ternop {
                Expression* lhs;
                Expression* mhs;
                Expression* rhs;
                op opr;
        };
        struct binop {
                Expression* lhs;
                Expression* rhs;
                op opr;
        };
        struct unop {
                Expression* val;
                op opr;
        };
        using blck_stmt   = std::vector<Expression*>;
        using typed_ident = std::pair<std::optional<std::string>, std::string>;
        enum class exprtype {
                NONE,
                NUM,
                IDENT,
                TERNOP,
                BINOP,
                UNOP,
                BODY,
                RETURN
        };
        class Expression : public Node {
              protected:
                exprtype type;
                ternop ternopr;
                binop binopr;
                unop unopr;
                std::string ident;
                int num;
                blck_stmt body;
                Expression* ret;

              public:
                Expression();
                Expression(int const& num);
                Expression(blck_stmt const& body);
                Expression(std::string const& ident);
                Expression(ternop const& opr);
                Expression(binop const& opr);
                Expression(unop const& opr);
                Expression(Expression const& expr);
                Expression(Expression const* expr);
                ~Expression();
                Expression& operator=(Expression const& expr);
                void dump();
        };
        class FuncDecl : public Node {
              protected:
                typed_ident fnid;
                std::vector<typed_ident> args;
                Expression body;

              public:
                FuncDecl();
                FuncDecl(typed_ident const& fnid,
                         std::vector<typed_ident> const& args,
                         Expression const& body);
                FuncDecl(FuncDecl const& fndecl);
                FuncDecl& operator=(FuncDecl const& fndecl);
                ~FuncDecl();
	        void dump();
        };
} // namespace ast
