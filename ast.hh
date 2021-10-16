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
                FOVER,
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
                ADROF
        };
        class Node {};
        class Expression;
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
}
