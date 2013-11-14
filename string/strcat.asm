; strcat - concatenate two strings
; $Id: strcat.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; output:
; 	hl = address of dest
strcat:
	push	de	; dest
	
	; find the end of dest
	ex	de,hl
	xor	a
	ld	b,a
	ld	c,a
	cpir
	dec	hl	; cpir goes a byte past the end
	ex	de,hl
	
	; copy src to end of dest
	call	strcpy
	
	pop	hl	; dest
	ret
