; FIXME: make this smaller
isxdigit:
	call	isdigit
	ret	z
	cp	'A'
	ret	c
	cp	'f'+1
	jr	nc,.notAF
	cp	'a'
	jr	nc,.AF
	cp	'F'+1
	jr	nc,.notAF
.AF	cp	a	; set the zero flag
	ret
.notAF	or	a	; clear zero flag
	ret
