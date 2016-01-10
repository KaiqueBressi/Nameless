#include "Lexer.hpp"

Token::Token(Token_Type type, unsigned line, unsigned column)
{
	this->type = type;
	this->line = line;
	this->column = column;
}

Lexer::Lexer(std::string input)
{
	this->input = input;
}

std::string Lexer::type2name(Token_Type type)
{
	return token_names[(int)type];
}

Token Lexer::next_token()
{
	for(;;) 
	{
		switch(current_char()) 
		{
			case '\0':
				return Token(TK_EOF);
			case ' ': case '\f': case '\t': case '\v':
				next_char();
				break;
			case '\r': 
				next_char();
				
				if (check_next('\n'))
					return Token(TK_EOL);

				break;
			case '\n':
				next_char();
				return Token(TK_EOL);
			case ',':
				next_char();
				return Token(TK_COMMA);
			case ';':
				next_char();
				return Token(TK_SEMICOLON);
			case '(':
				next_char();
				return Token(TK_OPENPAR);
			case ')':
				next_char();
				return Token(TK_CLOSEPAR);
			case '{':
				next_char();
				return Token(TK_OPENBRAC);
			case '}':
				next_char();
				return Token(TK_CLOSEBRAC);
			case '=': 
				next_char();

				if (check_next('='))
				{
					if (check_next('='))
						return Token(TK_TEQUAL);
					else
						return Token(TK_DEQUAL);
				}

				return Token(TK_EQUAL);
			case '+':
				next_char();

				if (check_next('='))
					return Token(TK_PLUSEQUAL);

				return Token(TK_PLUS);
			case '-':
				next_char();

				if (check_next('='))
					return Token(TK_MINUSEQUAL);

				return Token(TK_MINUS);
			case '*':
				next_char();

				if (check_next('*'))
					return Token(TK_EXPO);

				return Token(TK_MUL);
			case '/':
				next_char();

				return Token(TK_DIV);
			default:
			{
				if ((current_char() >= 'a') && (current_char() <= 'z')) // Identifier or keyword
				{
					std::string ident = read_ident();
					
					Token_Type type = (Token_Type)is_keyword(ident);

					Token tk(TK_UNKNOW);

					if (type >= 0) {
						tk.type = type;
					} else {
						tk.type = TK_IDENTIFIER;
						tk.value.sval = new std::string(ident);
					}

					return tk;
				} else if ((current_char() >= 'A') && (current_char() <= 'Z')) {
					std::string ident = read_ident();
					Token tk(TK_CONSTANT);
					tk.value.sval = new std::string(ident);
					return tk;
				} else if ((current_char() >= '0') && (current_char() <= '9')) {
					std::string ident = std::string(1, current_char());
					Token tk(TK_NUMBER);
					tk.value.ival = std::stoi(ident);
					next_char();
					return tk;
				} else {
					//break;
					next_char();
				}
			}
		}
	}
}

std::string Lexer::read_ident()
{
	std::string ident;

	while (is_alpha(current_char()))
	{
		ident += current_char();
		next_char();
	}

	return ident;
}

int Lexer::is_keyword(std::string ident)
{
	for (unsigned int i = 0; i < token_names.size(); i++)
		if (token_names[i] == ident)
			return i;

	return -1;
}

bool Lexer::is_alpha(char str)
{
	if (((str >= 'a') && (str <= 'z'))  ||
		((str >= 'A') && (str <= 'Z'))  ||
		((str >= '1') && (str <= '9')))
	{
		return true;
	}

	return false;
}

bool Lexer::check_next(char next)
{
	if (current_char() == next)
	{
		next_char();
		return true;
	}

	return false;
}

char Lexer::current_char()
{
	try {
		return input.at(0);
	} catch (const std::out_of_range& e) {
		return '\0';
	}
}

char Lexer::next_char()
{
	try {
		input.erase(0, 1);
		return input.at(0);
	} catch(const std::out_of_range& e) {
		return '\0';
	}
}