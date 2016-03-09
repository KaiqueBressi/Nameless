require './Lexer.rb'
require './Codegen.rb'

class Parser
    attr_reader :current_token
    attr_accessor :lexer

    def initialize lexer
        @lexer = lexer
        next_token
    end

    def parse
        function_list
    end

    def next_token
        @current_token = @lexer.next_token
    end

    def unexpected_token
        raise "MANO LARGA DE SER BURRO, SEU CÓDIGO ESTÁ ERRADO " + current_token.line.to_s + " " + current_token.type.to_s
    end

    def test_check_next token_type, ignore_eol = true
        test_check_next(token_type) if (current_token == :TK_EOL) and (ignore_eol)

        current_token.type == token_type ? (next_token; true) : (false)
    end

    def check_next token_type, ignore_eol = true
        return (next_token; check_next(token_type)) if (current_token.type == :TK_EOL) and (ignore_eol)

        current_token.type == token_type ? (next_token; true) : (puts token_type; unexpected_token; false)
    end

    def multiple_check_next tokens_type, ignore_eol = true
        return (next_token; multiple_check_next(tokens_type)) if (current_token.type == :TK_EOL) and (ignore_eol)

        tokens_type.include?(current_token.type) ? (next_token; true) : (unexpected_token; false)
    end

    def multiple_test_check_next tokens_type, ignore_eol = true
        return (next_token; multiple_test_check_next(tokens_type)) if (current_token.type == :TK_EOL) and (ignore_eol)

        tokens_type.include?(current_token.type) ? (next_token; true) : (false)
    end

    def check_end
        (test_check_next :TK_EOF) or (test_check_next :TK_EOL) or (test_check_next :SEMICOLON)
    end

    def eat_eol
        next_token while current_token.type == :TK_EOL
    end

    #----------------------------------------------------------------------------------------#
    #----------------------------------------------------------------------------------------#
    #                                   Grammar Rules                                        #
    #----------------------------------------------------------------------------------------#
    #----------------------------------------------------------------------------------------#

    def function_list
        list = []

        while true
            case current_token.type
            when :TK_DEF
                list << function
            when :TK_EOL
                next_token; next
            when :TK_EOF
                return list
            else
               # unexpected_token
            end
        end
    end

    def arglist essential = false, args = []
        argument = current_token

        if essential == true
            args << argument if multiple_check_next [:TK_IDENTIFIER, :TK_NUMBER], false
        else
            args << argument if multiple_test_check_next [:TK_IDENTIFIER, :TK_NUMBER], false
        end

        if current_token.type == :TK_COMMA
            next_token
            arglist true, args
        end

        return args
    end

    def type_definition essential = false, type_list = []
        type = current_token

        if essential == true
            type_list << type if check_next :TK_INT, false
        else
            type_list << type if test_check_next :TK_INT, false
        end

        if current_token.type == :TK_MINUS
            next_token
            check_next :TK_GREATER

            type_definition true, type_list
        end

        return type_list
    end

    def function
        next_token

        function_name = current_token.value
        func = Function.new function_name

        if (test_check_next :TK_IDENTIFIER, false)
            check_next :TK_DCOLON

            func_header = FunctionHeader.new type_definition

            while check_next :TK_OPENPAR
                args = arglist

                check_next :TK_CLOSEPAR, false

                check_next :TK_EQUAL, false

                stat = statement_block

                func.definitions << FunctionDefinition.new(args, stat)
                func.header = func_header

                eat_eol

                break if current_token.type != :TK_OPENPAR
            end

            check_next :TK_END
        else
            unexpected_token
        end

        return func
    end

    def statement_block
        statement_list = []

        if test_check_next :TK_OPENBRAC
            while current_token.type != TK_CLOSEBRAC
                statement_list << statement
            end
        else
            while current_token.type != :TK_EOL
                statement_list << statement
                
                break if current_token.type != :TK_SEMICOLON

                next_token
            end
        end

        return statement_list
    end

    def call_args args_list = []
        args_list << statement

        if current_token.type == :TK_COMMA
            next_token
            call_args args_list
        end

        return args_list
    end

    def simple_expr
        case current_token.type
        when :TK_IDENTIFIER
            ident = current_token
            next_token

            if test_check_next :TK_OPENPAR
                func = FunctionCall.new(ident.value)
                
                if !test_check_next :TK_CLOSEPAR
                    func.args = call_args
                end

                check_next(:TK_CLOSEPAR)

                return func
            else
                return Identifier.new(ident.value)
            end
        when :TK_NUMBER
            number = Number.new(current_token.value)
            next_token
            return number
        end
    end

    Priorities = { :TK_PLUS => [1, :left], :TK_MINUS => [1, :left],  
                   :"*"  => [2, :left], :"/" => [2, :left],
                   :"**" => [3, :right] }

    def is_binop? token
        Priorities[token] || [0, nil]
    end

    def expression lhs, limit = 0
        while true
            operator = is_binop?(current_token.type)

            if (operator[0] < limit) or (operator[0] == 0) 
                return lhs
            end

            bin_operator = current_token.type 
            next_token 

            rhs = simple_expr 

            next_operator = is_binop?(current_token.type) 

            if next_operator[0] == 0 
                return BinaryExpression.new lhs, rhs, bin_operator
            end

            if operator[1] == :right
                if (next_operator[0] >= operator[0]) 
                    rhs = subexpr rhs, operator[0] 
                end
            else
                if (next_operator[0] > operator[0])
                    rhs = subexpr rhs, operator[0] 
                end
            end

            lhs = BinaryExpression.new lhs, rhs, bin_operator
        end
    end

    def expr_statement
        expression simple_expr
    end

    def statement
        expr_statement
    end
end

f = File.open("test.nl", "r") 
l = Lexer.new f.read
p = Parser.new(l)
p.parse.each do |func_list|
    func_list.codegen
end
f.close