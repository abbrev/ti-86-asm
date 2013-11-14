; strcmp - compare two strings
; $Id: strcmp.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of s1
; 	hl = address of s2
; output:
; 	a < 0 if (s1 < s2)
; 	a = 0 if (s1 = s2)
; 	a > 0 if (s1 > s2)
strcoll:
strcmp:
	ld	a,(de)		; get char from string 1
	or	a		; is it NUL byte?
	jr	z,.end		; if so, jump to end
	sub	(hl)		; compare to char from string 2
	inc	de		; ++string 1
	inc	hl		; ++string 2
	jp	z,strcmp	; chars are the same, so try next char
	ret
.end	sub	(hl)
	ret	; return difference
