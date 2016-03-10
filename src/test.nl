defina fib :: inteiro -> inteiro
	(0) = 0
	(1) = 1
	(x) = fib(x - 1) + fib(x - 2)
fim

defina principal :: inteiro
	() = fib(4)
fim