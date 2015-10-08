#ifndef CODEGEN_HPP
#define CODEGEN_HPP

#include "Lexer.hpp"

#include <stack>
#include <typeinfo>

class BlockAST;

class Context
{
	public:
		Context() {  }
		void generate_code(BlockAST *block);
		void run_code();

		Context *top_context;	
};

class ExprAST
{
	public:
		virtual ~ExprAST() {}
		virtual void Codegen(Context &context) = 0;
};

class IdentifierAST : public ExprAST
{
	public:
		std::string name;
		IdentifierAST(const std::string &name) : name(name) { }
		void Codegen(Context &context) override;
};

class BinaryExprAST : public ExprAST
{
	Token_Type op;
	ExprAST *lhs, *rhs;
	public:
		BinaryExprAST(Token_Type op, ExprAST *lhs, ExprAST *rhs) : op(op), lhs(lhs), rhs(rhs) {}
		void Codegen(Context &context) override;
};

class AssignmentAST : public ExprAST
{
	ExprAST *lhs, *rhs;
	public:
		AssignmentAST(ExprAST *lhs, ExprAST *rhs) : lhs(lhs), rhs(rhs) {}
		void Codegen(Context &context) override;
};

class DoubleAST : public ExprAST
{
	public:
		double value;
		DoubleAST(double value) : value(value) {}
		void Codegen(Context &context) override;
};

class IntegerAST : public ExprAST
{	
	public:
		long long value;
		IntegerAST(long long value) : value(value) {}
		void Codegen(Context &context) override;
};

class ArglistAST : public ExprAST
{
	public:
		std::string name;
		void Codegen(Context &context) override;
};

class MethodAST : public ExprAST
{
	public:
		std::string name;
		void Codegen(Context &context) override;
};

class BlockAST : public ExprAST
{
	std::vector<ExprAST*> statement_list;
	public:
		BlockAST(std::vector<ExprAST*> statement_list) : statement_list(statement_list) {}
		void Codegen(Context &context) override;
};

#endif