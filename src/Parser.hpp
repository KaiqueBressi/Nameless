#ifndef PARSER_HPP
#define PARSER_HPP

#include "Lexer.hpp"
#include "Codegen.hpp"

struct precedence {
	unsigned char operator_type;
	bool left;
	unsigned char precedence;
};

const std::vector<struct precedence> priorities = {
	{TK_MINUS, true, 1},  // -
	{TK_PLUS,  true, 1},  // +
	
	{TK_MUL, true, 2},    // *
	{TK_DIV, true, 2},    // '/'
};

class Parser
{
	public:
		Parser(Lexer lexer);
		void parse();
	private:
		void next_token();
		bool check_next(Token_Type type);
		bool check_end();
		bool test_check_next(Token_Type type);
		void unexpected_token();
		void eat_eol();
		
		bool block_follow();
		ExprAST *function_list();
		ExprAST *statement_block();
		struct precedence get_precedence(Token_Type type);

		ExprAST *expression();
		ExprAST *subexpression(ExprAST *lhs, int limit = 0);

		ExprAST *simple_expression();
		ExprAST *primary_expression();
		ExprAST *suffixed_expression();
		ExprAST *expr_statement();
		ExprAST *statement();
		ExprAST *function();
		ExprAST *arglist();
		BlockAST *block();

		Lexer *lex = new Lexer();
		Token *current_token = new Token(TK_UNKNOW);
};

#endif