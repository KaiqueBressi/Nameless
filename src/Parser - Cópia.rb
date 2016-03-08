require './Token.rb'
require './Lexer.rb'

class Parser
    def initialize lexer
        @lexer = lexer
        @tokens = []

        next_token 1
    end

    def begin_parsing
        return stat_list
    end

    def unexpected_token
        raise "syntax error #{current_token.line}: unexpected " + current_token.type.to_s
    end

    def syntax_error error
        raise error
    end

    def next_token distance = 0
        consume_token if distance == 0

        while (distance >= @tokens.size)
            @tokens << @lexer.next_token
        end

        return @tokens[0]
    end

    def consume_token
        @tokens.shift
    end

    def current_token
        @tokens[0]
    end

    def check token
        if current_token.type != token
            return unexpected_token
        end
    end

    def check_next token, ignore = true
        next_token while (token.type == :NEWLINE) && ignore

        check token
        next_token
    end

    def test_next token
        if current_token.type == token
            next_token
            return true
        end

        return false
    end

    def test_end
        if (test_next :NEWLINE) or (test_next :";")
            return true
        end

        return false
    end

    #
    # Grammar Rules
    #

    def test_then_block
        next_token 
        expr
        
        if !(test_end) and (!test_next :THEN)
            unexpected_token
        end

        block
    end

    def if_stat
        test_then_block

        if (current_token.type == :ELSIF)
            test_then_block
        end

        if test_next :ELSE
            block
        end

        check_next :END
    end

    def while_stat
        next_token 
        expr

        test_next :DO
        
        unexpected_token if !test_end

        block
        check_next :END
    end

    def until_stat
        next_token 
        expr

        test_next :DO

        unexpected_token if !test_end

        block
        check_next :END
    end

    def for_stat
    end

    def block
        stat_list
    end

    def primary_expr
        case current_token.type
        when :"("
            next_token
            exprAst = expr
            check_next :")"
            return exprAst
        when :IDENTIFIER
            name = current_token.value
            next_token 
            return nil
        else
            unexpected_token
        end
    end

    def suffixed_expr        
        lhs = primary_expr

        case current_token.type
        when :"("
            next_token
            check_next :")"
            return "teste"
        else
            return lhs
        end
    end

    def simple_expr
        case current_token.type
        when :NUMBER
            number_value = current_token.value
            next_token
            return number_value
        when :FLOAT
            float_value = current_token.value
            next_token
            return Codegen::Double.new float_value
        when :STRING
            next_token
        when :TRUE
            next_token
        when :FALSE
            next_token 
        when :NIL
            next_token 
        else
            suffixed_expr
        end
    end

    Priorities = { :"+" =>  [1, :left], :"-" => [1, :left],  
                   :"*" =>  [2, :left], :"/" => [2, :left],
                   :"**" => [3, :right] }

    def is_binop? token
        return Priorities[token] || [0, nil]
    end

    def subexpr lhs, limit = 0
        while true
            operator = is_binop?(current_token.type)

            if (operator[0] < limit) || (operator[0] == 0) 
                return lhs
            end

            bin_operator = current_token.type 
            next_token 

            rhs = simple_expr 

            next_operator = is_binop?(current_token.type) 

            if next_operator[0] == 0 
                return [lhs, bin_operator, rhs]
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

            lhs = [lhs, bin_operator, rhs]
        end
    end

    def expr
        lhs = simple_expr
        subexpr lhs
    end

    def expr_stat
        lhs = suffixed_expr

        if test_next :"="
            rhs = expr
        else
            if lhs.class == String 

            else
                unexpected_token
            end
        end
    end

    def statement
        case current_token.type
        when :IF
            return if_stat
        when :WHILE
            return while_stat
        else
            return expr_stat
        end
    end

    def function
        next_token

        if (test_next :IDENTIFIER) || (test_next :CONSTANT)

        end
    end

    def block_follow? token
        case token.type
        when :ELSE, :ELSIF, :END, :EOF
            return true
        end

        return false
    end

    def stat_list
        case current_token.type
        when :DEF
        when :NEWLINE

    end
=begin
    def stat_list
        list = []

        while (!block_follow?(current_token))
            if current_token.type == :RETURN
                list.push statement 

                if !test_end and (!test_next :EOF) 
                    unexpected_token
                end

                break
            end

            list.push statement

            if !test_end and (!test_next :EOF) 
                unexpected_token
            end
        end

        return list
    end
=end
end

def to_math(array)
    math = array.inspect
    math.gsub!(/\[/, "(")
    math.gsub!(/\]/, ")")
    math.gsub!(/(\,|\:)/, "")
    math.gsub!(/\*\*/, "^")
    return math
end

Parser.new(Lexer.new "abc = 1 ** 1 ** 1 ** 2 * 5 + 10 + 5 * 4 - 2 / 5").begin_parsing.each do |t|
   puts to_math(t)
end