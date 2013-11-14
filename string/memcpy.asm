; memcpy - copy memory area
; $Id: memcpy.asm,v 1.2 2007/02/15 18:19:47 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; 	bc = n (number of bytes to copy)
; output:
; 	hl = address of dest
memcpy:
	push	de		; dest
	ld	a,b
	or	c
	jr	z,.end		; test for n=0
	ldir
.end	pop	hl		; dest
	ret
