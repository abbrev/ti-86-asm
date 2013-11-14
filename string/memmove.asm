; memmove - copy memory area
; $Id: memmove.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; 	bc = n (number of bytes to copy)
; output:
; 	hl = address of dest
memmove:
	push	de		; dest
	ld	a,b
	or	c
	jr	z,.end		; test for n=0
	
	; if hl >= de, we do ldir
	; else if hl < de, we add bc-1 to hl and de, then do lddr
	if 0
	push	hl
	sbc	hl,de
	pop	hl
	else
	ld	a,h
	cp	d
	jr	c,.down
	jr	nz,.up
	ld	a,l
	cp	e
	endif
	
	jr	c,.down
.up	ldir
.end	pop	hl		; dest
	ret

.down	add	hl,bc
	dec	hl		; src += n-1
	
	ex	de,hl
	add	hl,bc
	dec	hl
	ex	de,hl		; dest += n-1
	
	lddr
	pop	hl		; dest
	ret
