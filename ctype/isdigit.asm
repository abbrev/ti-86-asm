isdigit:
	cp	'0'
	ret	c
	cp	'9'+1
	jr	nc,.notdigit
	cp	a	; set the zero flag
	ret
.notdigit
	or	a	; clear zero flag
	ret
