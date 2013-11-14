; strchr - locate character in string
; $Id: strchr.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	hl = address of s
; 	e = c (byte to find)
; output:
; 	hl = address of matching byte (NULL if not found)
; 	Z80 extension: carry is set if byte is not found
strchr:
	ld	a,(hl)
	cp	e
	ret	z		; we found the byte; return (carry is clear)
	inc	hl
	or	a
	jp	nz,strchr
	ld	h,a
	ld	l,a		; we didn't find the byte; return NULL
	scf			; and set carry
	ret
