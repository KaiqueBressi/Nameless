defina fat :: inteiro -> inteiro
	(x) = x * fat(x - 1) 
	(0) = 0
	(1) = 1
fim

defina principal :: inteiro
	() = fat(20)
fim