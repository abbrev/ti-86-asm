isalpha:
	call	isupper
	ret	z
	jp	islower
