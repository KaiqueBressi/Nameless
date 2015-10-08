#include "Main.hpp"

int main(void)
{
	Lexer lex("abc = 6 / (5 * 7 * 8) - 5;;;;;;\n");
	Parser parse(lex);
	parse.parse();

	/*Token token(TK_EOF);
	
	while ((token = lex.next_token()).type != TK_EOF)
	{
		std::cout << lex.type2name(token.type) << std::endl;
	}*/
}