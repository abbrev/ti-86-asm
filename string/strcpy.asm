; strcpy - copy a string
; $Id: strcpy.asm,v 1.2 2007/02/15 18:19:48 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; output:
; 	hl = address of dest
; 	de and bc are destroyed
 if 0
; preserves BC but slower
strcpy:
	push	de
.char	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	or	a
	jp	nz,.char
	pop	hl
	ret
 else
; destroys BC but faster
strcpy:
	push	de	; dest
.char	ld	a,(hl)
	ldi
	or	a
	jp	nz,.char
	pop	hl	; dest
	ret
 endif
