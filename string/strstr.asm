; strstr - locate a substring
; $Id: strstr.asm,v 1.2 2007/02/15 18:19:49 christop Exp $
; 
; input:
; 	de = address of haystack
; 	hl = address of needle
; output:
; 	hl = address of needle in haystack
strstr:
	push	hl		; save needle
	push	de		; save haystack
	call	strlen
	ld	b,h
	ld	c,l		; bc = strlen(needle)
	pop	de
	pop	hl
	
	;init
	;s=haystack		; de = s
	jr	.test
.for	;stmt
	ld	a,(de)
	and	a
	jr	z,.null		; if (*s == '\0') return NULL;
	
	;incr
	inc	de		; ++s
.test	;test
	push	hl		; save needle
	push	de		; save s
	push	bc		; save length
	call	strncmp
	pop	bc
	pop	de
	pop	hl
	jr	nz,.for
	
	ex	de,hl
	ret
	
.null	ld	h,a		; return NULL
	ld	l,a
	ret


;char *strstr(const char *haystack, const char *needle)
;{
;	int len = strlen(needle);
;	char *s;
;	for (s = (char *)haystack; strncmp(s, needle, len); ++s) {
;		if (*s == '\0')
;			return NULL;
;	}
;	return s;
;}
