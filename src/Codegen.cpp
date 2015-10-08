#include "Codegen.hpp"

void Context::generate_code(BlockAST *block)
{	
	block->Codegen(*this);
}

void Context::run_code()
{

}

void IdentifierAST::Codegen(Context &context)
{
	printf("This is a identifier\n");
}

void BinaryExprAST::Codegen(Context &context)
{

}

void AssignmentAST::Codegen(Context &context)
{
	printf("This is a assignment\n");

	lhs->Codegen(context);
	rhs->Codegen(context);
}

void DoubleAST::Codegen(Context &context)
{
	
}

void IntegerAST::Codegen(Context &context)
{

}

void BlockAST::Codegen(Context &context)
{
	for (unsigned int i = 0; i < statement_list.size(); i++)
		statement_list[i]->Codegen(context);
}

void MethodAST::Codegen(Context &context)
{

}