i = 1
j = 1
k = 1

while i <= 15
	while j <= 15
		while k <= 15
			puts (k + i + j)
			k += 2
		end

		j += 2
		k = 1
	end

	j = 1
	i += 2
end