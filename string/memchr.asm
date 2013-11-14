; memchr - scan memory for a character
; $Id: memchr.asm,v 1.2 2007/02/15 18:19:47 christop Exp $
; 
; input:
; 	hl = address of s
; 	bc = n (number of bytes in s)
; 	e = c (byte to find)
; output:
; 	hl = address of matching byte (NULL if not found)
; 	Z80 extension: carry is set if byte is not found
memchr:
	ld	a,b
	or	c
	jr	z,.not		; test for n=0
	ld	a,e
	cpir
	jr	nz,.not
	dec	hl		; we found the byte; return address to it
	or	a
	ret
.not	ld	hl,0		; we didn't find the byte; return NULL
	scf
	ret
