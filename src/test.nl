defina module :: inteiro -> inteiro
	(x) = 6
	(a) = 8
fim

defina lcm :: inteiro -> inteiro -> inteiro
	(a, b) = module(a * b) / gcd(a, b)
fim

defina gcd :: inteiro -> inteiro -> inteiro
	(a, a) = a
	(a, b) | a > b  = gcd(a - b, b)
	(a, b) | b > a  = gcd(a, b - a)
fim

defina fibonacci :: inteiro -> inteiro
	(0) = 0
	(1) = 1
	(x) = fibonacci(x - 2) + fibonacci(x - 1)
fim

defina principal :: inteiro
	() = module(20)
fim