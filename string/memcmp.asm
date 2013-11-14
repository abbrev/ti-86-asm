; memcmp - compare memory areas
; $Id: memcmp.asm,v 1.2 2007/02/15 18:19:47 christop Exp $
; 
; input:
; 	de = s1
; 	hl = s2
; 	bc = n
; output:
; 	a < 0 if (s1 < s2)
; 	a = 0 if (s1 = s2)
; 	a > 0 if (s1 > s2)
memcmp:
	jp	.testbc
.cmpc	ld	a,(de)		; get char from s1
	sub	(hl)		; compare to char from s2
	ret	nz		; chars differ? return
	inc	de		; ++s1
	inc	hl		; ++s2
	dec	bc		; --n
.testbc	ld	a,b		; n == 0?
	or	c
	jp	nz,.cmpc	; n != 0? test next chars
	ret			; A = 0 at this point, so just return
