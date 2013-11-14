; strspn - search a string for a set of characters
; $Id: strspn.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of s
; 	hl = address of accept
; output:
; 	hl = number of characters in the initial segment of s which consist only
; 	 of characters from accept
strspn:
	push	de		; s
	
	ld	b,d
	ld	c,e		; t = s
	
.loop	ld	a,(bc)
	or	a
	jr	z,.done		; end of s?
	
	push	hl		; save accept
	ld	e,a
	call	strchr		; is this character in accept?
	pop	hl
	
	inc	bc		; ++t
	jp	nc,.loop	; loop if character is in accept string
	or	a		; clear carry for the following sbc
	
.done	ld	h,b
	ld	l,c		; hl = t
	pop	de		; de = s
	sbc	hl,de		; return t - s
	ret

;size_t strspn(const char *s, const char *accept)
;{
;	char *t = s;
;	while (*t && strchr(accept, *t++))
;		;
;	return t - s;
;}
