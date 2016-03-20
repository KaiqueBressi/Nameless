class Token
    attr_accessor :type
    attr_accessor :line
    attr_accessor :column
    attr_accessor :value

    def initialize(type = :TK_UNKNOWN, line = 1, column = 0, value = nil)
        @type = type
        @line = line
        @column = column
        @value = value
    end
end

class Lexer
    attr_accessor :chunk

    Keywords = {"verdadeiro" => :TK_TRUE,
                "falso"      => :TK_FALSE,
                "se"         => :TK_IF,
                "senao"      => :TK_ELSE,
                "senaose"    => :TK_ELSIF,
                "faca"       => :TK_DO,
                "fim"        => :TK_END,
                "enquanto"   => :TK_WHILE,
                "defina"     => :TK_DEF,
                "inteiro"    => :TK_INT,
                "caracteres" => :TK_STRING}

    def initialize chunk
        @chunk = chunk
        @line = 1
        @column = 0
    end

    def next_token
        while true
            case current_char
            when "\0", nil
                return Token.new :TK_EOF
            when ' ', "\f", "\t", "\v"
                next_char
            when "\n", "\r\n"
                @line += 1
                next_char
                return Token.new :TK_EOL, @line
            when ','
                next_char
                return Token.new :TK_COMMA, @line
            when ';'
                next_char
                return Token.new :TK_SEMICOLON, @line
            when '('
                next_char
                return Token.new :TK_OPENPAR, @line
            when ')'
                next_char
                return Token.new :TK_CLOSEPAR, @line
            when '{'
                next_char
                return Token.new :TK_OPENBRAC, @line
            when '}'
                next_char
                return Token.new :TK_CLOSEBRAC, @line
            when '='
                next_char

                if check_next('=')
                    return Token.new :TK_TEQUAL, @line if check_next('=')
                    return Token.new :TK_DEQUAL, @line
                end

                return Token.new :TK_EQUAL, @line
            when '+'
                next_char
                return Token.new :TK_PLUSEQUAL, @line if check_next('=')
                return Token.new :TK_PLUS, @line
            when '-'
                next_char
                return Token.new :TK_MINUSEQUAL, @line if check_next('=')      
                return Token.new :TK_MINUS, @line
            when '*'
                next_char
                return Token.new :TK_EXPO, @line if check_next('*')     
                return Token.new :TK_MUL, @line
            when '/'
                next_char
                return Token.new :TK_DIV, @line
            when '%'
                next_char
                return Token.new :TK_MOD, @line
            when ':'
                next_char                
                return Token.new :TK_DCOLON, @line if check_next(':')
                return Token.new :TK_COLON, @line
            when '>'
                next_char
                return Token.new(check_next('=') ? :TK_GREATEREQUAL : :TK_GREATER, @line)
            when '<'
                next_char
                return Token.new(check_next('=') ? :TK_LESSEREQUAL : :TK_LESSER, @line)
            when '|'
                next_char
                return Token.new :TK_PIPELINE, @line
            else
                if (current_char >= 'a') and (current_char <= 'z')
                    ident = skip_until_cond ->() { (current_char != nil) and is_alpha?(current_char) }
                    type = check_keyword_or_ident(ident)
                    
                    token = Token.new (type ? type : :TK_IDENTIFIER), @line
                    token.value = ident if token.type == :TK_IDENTIFIER

                    return token
                elsif (current_char >= '0') and (current_char <= '9')
                    number = skip_until_cond ->() do
                        (current_char != nil) and 
                        (current_char >= '0') and
                        (current_char <= '9') 
                    end

                    return Token.new :TK_NUMBER, @line, 0, number.to_i
                else
                    raise "Character não esperado no processo de análise léxica"
                end
            end
        end
    end

    def next_char 
        @chunk.slice!(0) 
    end

    def check_keyword_or_ident name
        Keywords[name] or false
    end

    def skip_until_cond cond
        skipped = ""

        while cond.()
            skipped += current_char
            next_char
        end

        return skipped
    end

    def is_alpha? char
        (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || (char >= '0' && char <= '9') || (char == '_')
    end

    def current_char
        @chunk[0]
    end

    def check_next char
        current_char == char ? (next_char; true) : false
    end
end

f = File.open("test.nl", "r") 
l = Lexer.new f.read

=begin
while ((type = l.next_token).type != :TK_EOF)
    puts type.inspect
end
=end
