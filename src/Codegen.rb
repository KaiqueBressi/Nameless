class Function
	attr_accessor :name
	attr_accessor :definitions
	attr_accessor :header

	def initialize name, definitions = [], header = []
		@name = name
		@definitions = definitions
		@header = header
	end
end

class FunctionDefinition
	attr_accessor :argcount
	attr_accessor :arglist
	attr_accessor :block
	attr_accessor :bytecode

	def initialize arglist, block
		@arglist = arglist
		@block = block
		@argcount = arglist.size
		@bytecode = []
		codegen
		puts bytecode.inspect
	end

	def codegen
		for statement in block
			bytecode.concat(statement.codegen)
		end

		bytecode << :VM_RETV
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
		[]
	end
end

class Identifier
	attr_accessor :name

	def initialize name
		@name = name
	end

	def codegen
		code = []
		code << :VM_PUSH
		code << :"#{name}"

		return code
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
		end

		return code
	end
end