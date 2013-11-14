; strlen - calculate the length of a string
; $Id: strlen.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	hl = address of s
; output:
; 	hl = number of characters in s
; 	bc is destroyed
strlen:
	ld	d,h
	ld	e,l	; s
	xor	a
	ld	b,a
	ld	c,a	; stops us if we wrap around to the beginning of s :)
	cpir		; find the 0 byte
	dec	hl	; cpir goes a byte past the end
	
	sbc	hl,de	; length = (address of 0 byte) - s
	ret
