class Token
	attr_accessor :type
	attr_accessor :line
	attr_accessor :column
	attr_accessor :value

	def initialize
		@type = :EOF
		@line = 0
		@column = 0
	end
end