isupper:
	cp	'A'
	ret	c
	cp	'Z'+1
	jr	nc,.notupper
	cp	a	; set the zero flag
	ret
.notupper
	or	a	; clear zero flag
	ret
