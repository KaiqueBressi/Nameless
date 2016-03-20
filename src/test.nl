defina module :: inteiro -> inteiro
	(x) | x < 0 = x - x * 2
	(x) | x > 0 = x
fim

defina lcm :: inteiro -> inteiro -> inteiro
	(a, b) = module(a * b) / gcd(a, b)
fim

defina gcd :: inteiro -> inteiro -> inteiro
	(a, a) = a
	(a, b) | a > b  = gcd(a - b, b)
	(a, b) | b > a  = gcd(a, b - a)
fim

defina principal :: inteiro
	() = lcm(10, 88)
fim