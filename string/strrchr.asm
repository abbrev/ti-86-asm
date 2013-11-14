; strrchr - locate character in string
; $Id: strrchr.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	hl = address of s
; 	e = c (byte to find)
; output:
; 	hl = address of last matching byte (NULL if not found)
; 	Z80 extension: carry is set if byte is not found
strrchr:
	ld	c,e
	ex	de,hl
	ld	hl,0		; char not found yet
	
.char	ld	a,(de)
	cp	c
	jp	nz,.notc
	ld	h,d
	ld	l,e		; save address of c
.notc	inc	de
	or	a
	jp	nz,.char
	ld	a,h
	or	l
	ret	nz
	scf
	ret

;char *strrchr(const char *s, int c)
;{
;	char *p = NULL;
;	do
;		if (*s == c)
;			p = s;
;	while (*s++);
;	return p;
;}
