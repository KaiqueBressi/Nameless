#ifndef LEXER_HPP
#define LEXER_HPP

#include <vector>
#include <iostream>
#include <stdexcept>

enum Token_Type {
	TK_EOF, 					// End of file 
	TK_EOL, 					// End of Line
	TK_EQUAL,  					// Symbol =
	TK_DEQUAL, 					// Symbol ==
	TK_TEQUAL, 					// Symbol ===

	TK_PLUS,  					// Symbol +
	TK_MINUS, 					// Symbol -
	TK_MUL,  					// Symbol *
	TK_DIV,   					// Symbol /
	TK_EXPO, 					// Symbol **

	TK_PLUSEQUAL, 				// Symbol +=
	TK_MINUSEQUAL,				// Symbol -=

	TK_SEMICOLON, 				// Symbol ;

	TK_OPENPAR,					// Symbol (
	TK_CLOSEPAR,				// Symbol )

	TK_IDENTIFIER, 				// Identifier
	TK_CONSTANT,				// Constant
	TK_NUMBER,					// Number

	TK_DEF,						// Keyword def

	TK_IF,						// Keyword if
	TK_THEN,					// Keyword then
	TK_ELSE, 					// Keyword else
	TK_ELSIF, 					// Keyword elsif
	TK_END,						// Keyword end
	TK_WHILE, 					// Keyword while

	TK_TRUE,					// Keyword true
	TK_FALSE,					// Keyword false
	TK_NIL,						// Keyword nil

	TK_UNKNOW, 					// UNKNOW
};

const std::vector<std::string> token_names = {
	"<end-of-file>",
	"<end-of-line>", 
	"=",
	"==",
	"===",

	"+",
	"-",
	"*",
	"/",
	"**",

	"+=",
	"-=",

	";",

	"(",
	")",	

	"<identifier>",
	"<constant>",
	"<number>",

	"def",

	"if",
	"then",
	"else",
	"elsif",
	"end",
	"while",
	"true",
	"false",
	"nil",

	"<unknow>",
};

typedef union {
	std::string *sval;	
	bool bval;
	long long ival;
} Value_Info;

class Token
{
	public:
		Token(Token_Type type, unsigned line = 0, unsigned column = 0);

		unsigned int line;
		unsigned int column;
		Token_Type type;

		Value_Info value;
};

class Lexer
{
	public:
		Lexer(std::string input = "\0");
		std::string type2name(Token_Type type);
		Token next_token();
		std::string input;
	private:
		bool check_next(char next);
		char current_char();
		char next_char();

		bool is_alpha(char str);
		int is_keyword(std::string ident);

		std::string read_ident();
};

#endif