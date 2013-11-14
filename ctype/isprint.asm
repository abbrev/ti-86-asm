isprint:
	cp	32
	ret	c
	cp	128
	jr	nc,.notprint
	cp	a	; set the zero flag
	ret
.notprint
	or	a	; clear zero flag
	ret
