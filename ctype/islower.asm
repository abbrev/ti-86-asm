islower:
	cp	'a'
	ret	c
	cp	'z'+1
	jr	nc,.notlower
	cp	a	; set the zero flag
	ret
.notlower
	or	a	; clear zero flag
	ret
