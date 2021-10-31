#pragma once
#include "irast.hh"
#include "location.hh"
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
                DEREF,
                ADROF,
                UNPLUS,
                UNMINUS,
                PREINC,
                PREDEC,
                POSTINC,
                POSTDEC,
                AS
        };
        class Node {
              public:
                virtual void dump() const = 0;
                yy::location loc;
                virtual irast::Stmt* parse() const = 0;
        };
        class TernOp;
        class BinOp;
        class UnOp;
        class Ident;
        class Number;
        class Null;
        class Return;
        class Block;
        class FuncDecl;
        using typed_ident = std::pair<std::string, std::string>;
        using blck_stmt   = std::vector<Node*>;
        class TernOp : public Node {
              public:
                Node* lhs;
                Node* mhs;
                Node* rhs;
                yy::location loc;
                TernOp();
                TernOp(yy::location loc);
                TernOp(Node* lhs, Node* mhs, Node* rhs, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class BinOp : public Node {
              public:
                Node* lhs;
                op opr;
                Node* rhs;
                yy::location loc;
                BinOp();
                BinOp(yy::location loc);
                BinOp(Node* lhs, op opr, Node* rhs, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class UnOp : public Node {
              public:
                Node* val;
                op opr;
                yy::location loc;
                UnOp();
                UnOp(yy::location loc);
                UnOp(Node* val, op opr, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class Block : public Node {
              public:
                blck_stmt body;
                yy::location loc;
                Block();
                Block(yy::location loc);
                Block(blck_stmt body, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class Ident : public Node {
              public:
                std::string ident;
                yy::location loc;
                Ident();
                Ident(yy::location loc);
                Ident(std::string ident, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class Number : public Node {
              public:
                int num;
                yy::location loc;
                Number();
                Number(yy::location loc);
                Number(int num, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class Return : public Node {
              public:
                Node* retval;
                yy::location loc;
                Return();
                Return(yy::location loc);
                Return(Node* retval, yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class Null : public Node {
              public:
                yy::location loc;
                Null();
                Null(yy::location loc);
                void dump() const;
                irast::Stmt* parse() const;
        };
        class FuncDecl : public Node {
              public:
                typed_ident fnid;
                std::vector<typed_ident> args;
                Node* body;
                yy::location loc;
                FuncDecl();
                FuncDecl(yy::location loc);
                FuncDecl(typed_ident const& fnid, std::vector<typed_ident> const& args, Node* const& body, yy::location loc);
                FuncDecl(FuncDecl const& fndecl);
                FuncDecl& operator=(FuncDecl const& fndecl);
                ~FuncDecl();
                void dump() const;
                irast::Stmt* parse() const;
        };
} // namespace ast
