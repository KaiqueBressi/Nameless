class VirtualMachine
	attr_accessor :stack
	attr_accessor :func_list
	attr_accessor :test_test

	def initialize func_list = []
		@func_list = func_list
		@stack = []
	end

	def interpreter bytecode, arglist = {}
		current_op = 0

		puts stack.inspect

		while current_op <= bytecode.count - 1
			case bytecode[current_op]
			when :VM_PUSH
				argument = bytecode[current_op + 1]

				if argument.class == String
					stack << arglist[argument]
				else
					stack << argument
				end

				current_op += 2
			when :VM_MUL
				arg_one = stack[stack.count - 2]
				arg_two = stack[stack.count - 1]

				stack.pop
				stack.pop
				stack << arg_one * arg_two

				current_op += 1
			when :VM_SUB
				arg_one = stack[stack.count - 2]
				arg_two = stack[stack.count - 1]

				stack.pop
				stack.pop
				stack << arg_one - arg_two

				current_op += 1
			when :VM_ADD
				arg_one = stack[stack.count - 2]
				arg_two = stack[stack.count - 1]

				stack.pop
				stack.pop	
				stack << arg_one + arg_two

				current_op += 1
			when :VM_CALL
				func_name = bytecode[current_op + 1]
				func = find_function(func_name)

				if func
					matched_definition = nil

					i = 0

					func.definitions.each do |definition|
						@matched = true

						for i in 0..definition.arglist.count - 1
							arg = definition.arglist[i]

							case arg.type
							when :TK_NUMBER
								if stack[stack.count - (i + 1)] == arg.value
									@matched = true
								else
									@matched = false
									break
								end
							end
						end

						if i >= 2
							puts matched_definition.inspect
						end

						i += 1

						if @matched == true
							matched_definition = definition
							break
						end
					end

					call_args = Hash.new
					
					for i in 0..(matched_definition.arglist.count - 1)
						arg = matched_definition.arglist[i]

						if arg.type == :TK_IDENTIFIER
							call_args[arg.value] = stack[stack.count - (i + 1)] 
						end
					end

					matched_definition.arglist.count.times do 
						stack.pop
					end

					interpreter(matched_definition.bytecode, call_args)
					current_op += 2
				else
					raise "A função \"" + func_name + "\" não foi encontrada"
				end
			when :VM_RETV
				current_op += 1
				return nil
			end
		end
	end

	def find_function name
		func_list.each do |func|
			if func.name == name
				return func
			end
		end

		return false
	end

	def main
		main_func = find_function "principal"

		if main_func
			if main_func.definitions.count > 1
				raise "A função \"principal\" deve conter apenas uma definição"
			else
				interpreter main_func.definitions[0].bytecode
				puts stack.inspect
			end
		else
			raise "Função \"principal\" deve ser definida"
		end
	end

	def compile
		func_list.each do |func|
			func.codegen
		end
	end
end