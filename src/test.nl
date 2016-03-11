defina fat :: inteiro -> inteiro
	(0) = 0
	(x) = x * fat(x - 1) 
	(1) = 1
fim

defina principal :: inteiro
	() = fat(20)
fim