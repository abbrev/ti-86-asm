isalnum:
	call	isalpha
	ret	z
	jp	isdigit
