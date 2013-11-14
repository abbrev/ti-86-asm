; input: HL = address of string
; output: HL = integer version of string
atoi:
	ex	de,hl
	ld	hl,0		; result = 0
	ld	c,h		; neg = 0
	
	jr	.space1		; while (isspace(*s))
.space2	inc	de		; ++s
.space1	ld	a,(de)
	cp	' '
	jr	z,.space2
	cp	'\f'
	jr	z,.space2
	cp	'\n'
	jr	z,.space2
	cp	'\r'
	jr	z,.space2
	cp	'\t'
	jr	z,.space2
	cp	'\v'
	jr	z,.space2
	
	cp	'-'		; switch (*s) {
	jr	nz,.notminus
	ld	c,1		; neg = 1
	jr	.incs
.notminus
	cp	'+'
	jr	nz,.notplus
.incs	inc	de		; ++s
.notplus			; }

	push	bc
.digit1				; while (isdigit(*s))
	ld	a,(de)
	sub	'0'
	jr	c,.digit2
	cp	9+1
	jr	nc,.digit2
	ld	b,h
	ld	c,l
	add	hl,hl
	add	hl,hl
	add	hl,bc
	add	hl,hl		; hl = hl*10
	add	a,l
	ld	l,a
	adc	a,h
	sub	l
	ld	h,a		; result = result * 10 + *s++ - '0'
	inc	de
	jr	.digit1
.digit2
	
	pop	bc		; if (!neg)
	ld	a,c
	or	a
	ret	z		; return result
	
	ld	a,l
	neg
	ld	l,a
	sbc	a,h
	sub	l
	ld	h,a		; HL = -HL
	
	ret			; return -result
