class Function
	attr_accessor :name
	attr_accessor :definitions
	attr_accessor :header

	def initialize name, definitions = [], header = nil
		@name = name
		@definitions = definitions
		@header = header
	end

	def codegen
		for func_definition in definitions
			if func_definition.arglist.count != (header.type_list.count - 1)
				raise "Número de argumentos diferente do que da declaração"
			end

			if func_definition.arglist.count > 0
				func_definition.arglist.each do |argument|
					case argument
					when :TK_IDENTIFIER
					when :TK_NUMBER
						if header.type_list[k - 1].type != :TK_INT
							raise "Definição da função incompativel com seus respectivos tipos"
						end
					end
				end				
			end

			func_definition.codegen
		end
	end
end

class FunctionDefinition
	attr_accessor :argcount
	attr_accessor :condition
	attr_accessor :arglist
	attr_accessor :block
	attr_accessor :bytecode

	def initialize arglist, block, condition = nil
		@arglist = arglist
		@block = block
		@argcount = arglist.size
		@bytecode = []
		@condition = condition.codegen if condition != nil
	end

	def codegen
		for statement in block
			bytecode.concat(statement.codegen)
		end

		bytecode << :VM_RETV
	end
end

class FunctionCall
	attr_accessor :name
	attr_accessor :args

	def initialize name, args = {}
		@name = name
		@args = args
	end

	def codegen
		code = []

		args.each do |a|
			code.concat(a.codegen)
		end

		return code.concat([:VM_CALL, name])
	end
end

class FunctionHeader
	attr_accessor :type_list

	def initialize type_list
		@type_list = type_list
	end
end

class Number
	attr_accessor :value

	def initialize value
		@value = value
	end

	def codegen
		return [:VM_PUSH, value]
	end
end

class Identifier
	attr_accessor :name

	def initialize name = ""
		@name = name
	end

	def codegen
		return [:VM_PUSH, "#{name}"]
	end
end

class BinaryExpression
	attr_accessor :first_expression
	attr_accessor :second_expression
	attr_accessor :operation

	def initialize first_expression, second_expression, operation
		@first_expression = first_expression
		@second_expression = second_expression
		@operation = operation
	end

	def codegen
		code = []
		code.concat(first_expression.codegen)
		code.concat(second_expression.codegen)

		case operation
		when :TK_PLUS
			code << :VM_ADD
		when :TK_MINUS
			code << :VM_SUB
		when :TK_MUL
			code << :VM_MUL
		when :TK_DIV
			code << :VM_DIV
		when :TK_MOD
			code << :VM_MOD
		when :TK_LESSER
			code << :VM_LESSER
		when :TK_GREATER
			code << :VM_GREATER
		when :TK_DEQUAL
			code << :VM_EQUAL
		when :TK_AND
			code << :VM_AND
		when :TK_OR
			code << :VM_OR
		end

		return code
	end
end