; strncmp - compare two strings
; $Id: strncmp.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of s1
; 	hl = address of s2
; 	bc = n (maximum number of chars to compare)
; output:
; 	a < 0 if (s1 < s2) in the first n characters
; 	a = 0 if (s1 = s2) in the first n characters
; 	a > 0 if (s1 > s2) in the first n characters
strncmp:
	jp	.testbc
.cmpc	ld	a,(de)		; get char from s1
	or	a		; is it NUL byte?
	jr	z,.end		; if so, jump to end
	sub	(hl)		; compare to char from s2
	ret	nz		; chars differ? return
	inc	de		; ++s1
	inc	hl		; ++s2
	dec	bc		; --n
.testbc	ld	a,b		; n == 0?
	or	c
	jp	nz,.cmpc	; n != 0? test next chars
	ret			; A = 0 at this point, so just return
.end	sub	(hl)
	ret

;int strncmp(const char *s1, const char *s2, size_t n)
;{
;	int c;
;	for (; n; ++s1, ++s2, --n) {
;		c = *s1;
;		if (c == '\0')
;			return c-*s2;
;		
;		c-=*s2;
;		if (c)
;			return c;
;	}
;	return 0;
;}
