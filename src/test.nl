defina fib :: inteiro -> inteiro
	(0) = 1
	(1) = 1
	(x) = fib(x - 2) + fib(x - 1) 
fim

defina principal :: inteiro
	() = fib(7)
fim