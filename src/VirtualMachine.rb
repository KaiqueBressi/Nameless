class VirtualMachine
	attr_accessor :stack
	attr_accessor :func_list

	def initialize func_list = []
		@func_list = func_list
		@stack = []
	end

	def get_from_stack count
		arr = []
		count.times { arr.unshift(stack.pop) }
		return arr
	end

	def interpreter bytecode, arglist = {}
		current_op = 0

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
				arg_one, arg_two = get_from_stack 2
				stack << arg_one * arg_two
				current_op += 1
			when :VM_DIV
				arg_one, arg_two = get_from_stack 2
				stack << arg_one / arg_two
				current_op += 1
			when :VM_MOD
				arg_one, arg_two = get_from_stack 2
				stack << arg_one % arg_two
				current_op += 1
			when :VM_SUB
				arg_one, arg_two = get_from_stack 2
				stack << arg_one - arg_two
				current_op += 1
			when :VM_ADD
				arg_one, arg_two = get_from_stack 2
				stack << arg_one + arg_two
				current_op += 1
			when :VM_LESSER
				arg_one, arg_two = get_from_stack 2
				stack << (arg_one < arg_two)
				current_op += 1
			when :VM_GREATER
				#puts stack.inspect
				arg_one, arg_two = get_from_stack 2
				stack << (arg_one > arg_two)
				current_op += 1
			when :VM_AND
				arg_one, arg_two = get_from_stack 2
				stack << arg_one and arg_two
				current_op += 1
			when :VM_EQUAL
				arg_one, arg_two = get_from_stack 2
				stack << (arg_one == arg_two)
				current_op += 1
			when :VM_OR
				arg_one, arg_two = get_from_stack 2
				stack << arg_one and arg_two
				current_op += 1
			when :VM_CALL
				func_name = bytecode[current_op + 1]
				func = find_function(func_name)

				last_literal_count = 0

				if func
					matched_definition = find_definition(func)

					if matched_definition == nil
						raise "Nenhuma definição válida na função \"" + func.name + "\""
 					end

					call_args = Hash.new
					
					for i in 0..(matched_definition.arglist.count - 1)
						arg = matched_definition.arglist[i]

						if arg.type == :TK_IDENTIFIER
							call_args[arg.value] = stack[stack.count - ((matched_definition.arglist.count - i))] 
						end
					end

					matched_definition.arglist.count.times { stack.pop }

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

	def find_definition func
		matched_definition = nil

		last_literal_count = 0

		func.definitions.each do |definition|
			literal_count = 0
			arglist = definition.arglist

			hash_args = Hash.new

			arg_def = arglist.map.with_index do |arg, i| 
				if arg.type == :TK_IDENTIFIER
					if hash_args[arg.value] != nil
						hash_args[arg.value]
					else
						hash_args[arg.value] = stack[stack.count - (definition.arglist.count - i)]
					end
				else
					literal_count += 1
					arg.value
				end
			end
			
			if arg_def == stack[(stack.count - definition.arglist.count)..stack.count]
				if matched_definition != nil	
					if literal_count >= last_literal_count
						cond = check_condition(definition)

						if cond
							if literal_count == last_literal_count
								raise "Definição ambiguia na função " + func.name
							end

							matched_definition = definition
							last_literal_count = literal_count
						elsif cond != false
							raise "Condição inválida na função " + func.name
						end
					end
				else
					cond = check_condition(definition)

					if cond
						matched_definition = definition
					elsif cond != false
						raise "Condição inválida na função " + func.name
					end
				end
			end
		end

		return matched_definition
	end

	def check_condition definition
		arg_def = stack[(stack.count - definition.arglist.count)..stack.count]
		call_args = Hash[definition.arglist.map{|a| a.value}.zip(arg_def)]

		if definition.condition != nil
			interpreter(definition.condition, call_args)

			return_value = get_from_stack 1

			return return_value[0]
		end
	
		return true
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