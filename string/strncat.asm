; strncat - concatenate two strings
; $Id: strncat.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; 	bc = n (maximum number of chars to copy from src)
; output:
; 	hl = address of dest
strncat:
	push	de		; dest
	
	ld	a,b
	or	c
	jr	z,.end
	
	push	bc		; n
	
	; find the end of dest
	ex	de,hl
	xor	a
	ld	b,a
	ld	c,a
	cpir
	dec	hl		; cpir goes a byte past the end
	ex	de,hl
	
	pop	bc
	
	xor	a
	jp	.char
.testc	cp	(hl)		; end of src?
	jr	z,.end
.char	ldi			; (hl)->(de), ++de, ++hl, --bc
	jp	pe,.testc
	
.end	ld	(hl),a
	pop	hl	; dest
	ret
