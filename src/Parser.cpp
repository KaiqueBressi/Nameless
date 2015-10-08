#include "Parser.hpp"

Parser::Parser(Lexer lexer)
{
	*lex = lexer;

	*current_token = lex->next_token();
	
	//*peek_next_token = lex->next_token();
}

void Parser::parse()
{
	BlockAST *b = block();

	Context cod = Context();
	cod.generate_code(b);
}

void Parser::next_token()
{
	//*current_token = *peek_next_token;
	//*peek_next_token = lex->next_token();

	*current_token = lex->next_token();
}

bool Parser::check_next(Token_Type type)
{
	if (!test_check_next(type))
	{
		unexpected_token();	
		return false;
	}

	return true;
}

bool Parser::check_end()
{
	return (test_check_next(TK_EOF) || test_check_next(TK_EOL) || test_check_next(TK_SEMICOLON));
}

bool Parser::test_check_next(Token_Type type)
{
	if (current_token->type == type)
	{
		next_token();
		return true;
	}

	return false;
}

void Parser::unexpected_token()
{
	std::cout << "Idiota " + lex->type2name(current_token->type) << std::endl;
	exit(0);
}

/*

				Grammar Rules

*/

bool Parser::block_follow()
{
	switch (current_token->type)
	{
		case TK_ELSIF:
		case TK_ELSE:
		case TK_END:
		case TK_EOF:
			return true;
		default:
			return false;
	}
}

struct precedence Parser::get_precedence(Token_Type type)
{
	for (unsigned int i = 0; i < priorities.size(); i++)
		if (type == priorities[i].operator_type)
			return priorities[i];

	return (struct precedence){0, true, 0};
}

ExprAST *Parser::subexpression(ExprAST *lhs, int limit)
{
	while (true)
	{	
		struct precedence expr_operator = get_precedence(current_token->type);

		if ((limit > expr_operator.precedence) || (expr_operator.precedence == 0))
			return lhs;

		Token_Type operator_type = current_token->type;
		next_token();

		ExprAST *rhs = simple_expression();

		struct precedence next_operator = get_precedence(current_token->type);

		if (next_operator.precedence == 0)
			return new BinaryExprAST(operator_type, lhs, rhs);

		if (!expr_operator.left) {
			if (next_operator.precedence >= expr_operator.precedence)
				rhs = subexpression(rhs, limit + 1);
		} else {
			if (next_operator.precedence > expr_operator.precedence)
				rhs = subexpression(rhs, limit + 1);
		}
	
		lhs = new BinaryExprAST(operator_type, lhs, rhs);
	}
}

ExprAST *Parser::expression()
{
	ExprAST *lhs = simple_expression();
	return subexpression(lhs);
}

ExprAST *Parser::suffixed_expression()
{
	// primary_expression {'.' | '::' | '(' expression_list ')'}
	return primary_expression();
}

ExprAST *Parser::simple_expression()
{
	// number | true | false | nil

	switch(current_token->type)
	{
		case TK_NUMBER:
		{
			IntegerAST *number = new IntegerAST(current_token->value.ival);
			next_token();
			return number;
		}
		case TK_TRUE:
			next_token();
			break;
		case TK_FALSE:
			next_token();
			break;
		case TK_NIL:
			next_token();
			break;
		default:
			return suffixed_expression();
	}

	return NULL;
}

ExprAST *Parser::primary_expression()
{
	// Identifier | '(' expression ')'

	switch(current_token->type)
	{
		case TK_OPENPAR:
		{
			next_token();
			ExprAST *expr_ast = expression();
			check_next(TK_CLOSEPAR);
			return expr_ast;
		}
		case TK_IDENTIFIER:
		{
			IdentifierAST *ident = new IdentifierAST(*current_token->value.sval);
			next_token();
			return ident;
		}
		default:
		{
			unexpected_token();
			return NULL;
		}
	}
}

ExprAST *Parser::expr_statement()
{
	// call() | ident '=' expression

	ExprAST *lhs = suffixed_expression();
	
	if (test_check_next(TK_EQUAL)) {
		// This is an assignment

		ExprAST *rhs = expression();
		return new AssignmentAST(lhs, rhs);
	} else {
		// Method call here
	}

	return NULL;
}

ExprAST *Parser::arglist()
{
	return NULL;
}

ExprAST *Parser::function()
{
	next_token(); // eat def

	if (test_check_next(TK_IDENTIFIER) || test_check_next(TK_CONSTANT))
	{
		check_next(TK_OPENPAR);	
		arglist();
	}
}

ExprAST *Parser::statement()
{
	switch(current_token->type)
	{
		case TK_SEMICOLON: 
		case TK_EOL:
			next_token();

			if (current_token->type != TK_EOF)
				return statement();

			break;
		case TK_IF:
			break;
		case TK_WHILE:
			break;
		case TK_DEF:
			return function();
		default:
			return expr_statement();
			break;
	}

	return NULL;
}

BlockAST *Parser::block()
{	
	std::vector<ExprAST*> statement_list;

	while (!block_follow())
	{
		ExprAST *stat = statement();

		if (stat != NULL)
			statement_list.push_back(stat);
		
		if (!check_end())
			unexpected_token();

		/*if (current_token->type == TK_RETURN)
		{
			statement_list.push_back(statement());
			break;
		}*/
	}

	return new BlockAST(statement_list);
}