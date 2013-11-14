; strcspn - search a string for a set of characters
; $Id: strcspn.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of s
; 	hl = address of reject
; output:
; 	hl = number of characters in the initial segment of s which are not in
; 	 the string reject
strcspn:
	push	de		; s
	
	ld	b,d
	ld	c,e		; t = s
	
.loop	ld	a,(bc)
	or	a
	jr	z,.done		; end of s?
	
	push	hl		; save reject
	ld	e,a
	call	strchr		; is this character in reject?
	pop	hl
	
	inc	bc		; ++t
	jp	c,.loop		; loop if character is not in reject string
	
.done	ld	h,b
	ld	l,c		; hl = t
	pop	de		; de = s
	sbc	hl,de		; return t - s
	ret

;size_t strcspn(const char *s, const char *reject)
;{
;	char *t = s;
;	while (*t && !strchr(reject, *t++))
;		;
;	return t - s;
;}
