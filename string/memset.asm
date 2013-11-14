; memset - fill memory with a constant byte
; $Id: memset.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	hl = address of s
; 	bc = n (number of bytes to copy)
; 	e = c (byte to fill)
; output:
; 	hl = address of s
memset:
	ld	a,b
	or	c
	ret	z		; test for n=0
	push	hl		; s
	
	ld	(hl),e
	dec	bc
	ld	a,b
	or	c
	jr	z,.end
	ld	d,h
	ld	e,l
	inc	de
	ldir
.end	pop	hl		; s
	ret
