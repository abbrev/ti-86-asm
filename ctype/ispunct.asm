ispunct:
	call	isprint
	ret	nz
	call	isspace
	jr	z,.notpunct
	call	isalnum
	jr	z,.notpunct
	cp	a		; set zero flag
	ret
.notpunct
	cp	'.'		; clear zero flag
	ret
