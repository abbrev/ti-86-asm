; strpbrk - search a string for any of a set of characters
; $Id: strpbrk.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of s
; 	hl = address of accept
; output:
; 	hl = address of character in s that matches one of the characters in
; 	 accept, or NULL if no such character is found
; 	Z80 extension: carry is set if character is not found
strpbrk:
	push	de		; s
	
	ld	b,d
	ld	c,e		; t = s
	
.loop	ld	a,(bc)
	or	a
	jr	z,.end
	
	push	hl		; save accept
	ld	e,a
	call	strchr		; is this character in accept?
	pop	hl
	
	inc	bc		; ++t
	jp	c,.loop		; loop if a character in accept is not found
	
	ld	h,b
	ld	l,c		; hl = t
	ret
	
.end	ld	h,a
	ld	l,a		; hl = 0
	scf
	ret

;char *strpbrk(const char *s, const char *accept)
;{
;	char *t = s;
;	for (t = s; *t; ++t)
;		if (strchr(accept, *t))
;			return t;
;	return NULL;
;}
