require './Parser.rb'
require './Lexer.rb'

f = File.open("example.pl", "r")
content = f.read

#lexer = Lexer.new content

#while ((t = lexer.next_token).type != :EOF)
#	puts t.inspect
#end

parser = Parser.new(Lexer.new content)
code = parser.begin_parsing
code.each do |c|
	puts c.inspect
end