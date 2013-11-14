; strncpy - copy a string
; $Id: strncpy.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; 	bc = n (maximum number of chars to copy)
; output:
; 	hl = address of dest
strncpy:
	push	de		; dest
	ld	a,b
	or	c
	jr	z,.end
	xor	a
	jp	.char
.testc	cp	(hl)		; end of src?
	jr	z,.pad
.char	ldi			; (hl)->(de), ++de, ++hl, --bc
	jp	pe,.testc
	pop	hl		; dest
	ret
	
.pad	; pad end of dest with zero bytes
	ld	(de),a
	dec	bc
	ld	a,b
	or	c
	jr	z,.end
	ld	h,d
	ld	l,e
	inc	de
	ldir
.end	pop	hl		; dest
	ret
